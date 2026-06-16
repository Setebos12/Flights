package com.example.flights_app.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Native queries against analytics data.
 * Seasonality, top-routes, revenue and KPI now read from the
 * aggregate table route_statistics instead of heavy views.
 * Occupancy, airline ranking and price distribution still use their views.
 */
@Repository
public class AnalyticsRepository {

    private final JdbcTemplate jdbc;

    public AnalyticsRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    // ── Occupancy ──────────────────────────────────────────────────────────────

    /**
     * Returns per-flight occupancy, optionally filtered by airline, route, year, month.
     */
    public List<Map<String, Object>> findOccupancy(Long airlineId, Long routeId,
                                                    Integer year, Integer month) {
        StringBuilder sql = new StringBuilder("""
            SELECT flight_id, departure_date_time, arrival_date_time,
                   origin_code, origin_name, dest_code, dest_name,
                   airline_id, airline_name, plane_model,
                   booked_seats, total_seats, occupancy_pct,
                   dep_year, dep_month, price, currency_code
            FROM v_flight_occupancy
            WHERE 1=1
            """);
        if (airlineId != null) sql.append(" AND airline_id = ").append(airlineId);
        if (routeId   != null) sql.append(" AND flight_id IN (SELECT id FROM flights WHERE routes_id = ").append(routeId).append(")");
        if (year      != null) sql.append(" AND dep_year = ").append(year);
        if (month     != null) sql.append(" AND dep_month = ").append(month);
        sql.append(" ORDER BY departure_date_time ASC");
        return jdbc.queryForList(sql.toString());
    }

    /**
     * Aggregated occupancy summary per airline.
     */
    public List<Map<String, Object>> findOccupancySummary() {
        return jdbc.queryForList("""
            SELECT airline_id, airline_name,
                   COUNT(*)                        AS total_flights,
                   SUM(booked_seats)               AS total_passengers,
                   ROUND(AVG(occupancy_pct), 2)    AS avg_occupancy_pct,
                   SUM(total_seats)                AS total_capacity
            FROM v_flight_occupancy
            GROUP BY airline_id, airline_name
            ORDER BY avg_occupancy_pct DESC NULLS LAST
            """);
    }

    // ── Seasonality / Popularity (route_statistics) ───────────────────────────

    /**
     * Route popularity with seasonality from route_statistics table.
     * Reads monthly rows (year > 0 AND month > 0).
     */
    public List<Map<String, Object>> findRouteSeasonality(Integer year, String originCode,
                                                          String destCode) {
        StringBuilder sql = new StringBuilder("""
            SELECT rs.routes_id AS route_id,
                   oa.airport_code AS origin_code, oc.name AS origin_city,
                   da.airport_code AS dest_code,   dc.name AS dest_city,
                   rs.year  AS dep_year,
                   rs.month AS dep_month,
                   rs.total_passengers,
                   rs.total_revenue
            FROM route_statistics rs
            JOIN routes r    ON r.id  = rs.routes_id
            JOIN airports oa ON oa.id = r.origin_airport_id
            JOIN city oc     ON oc.id = oa.city_id
            JOIN airports da ON da.id = r.destination_airport_id
            JOIN city dc     ON dc.id = da.city_id
            WHERE rs.month > 0 AND rs.year > 0
            """);
        if (year       != null) sql.append(" AND rs.year = ").append(year);
        if (originCode != null && !originCode.isBlank())
            sql.append(" AND oa.airport_code = '").append(originCode.toUpperCase()).append("'");
        if (destCode   != null && !destCode.isBlank())
            sql.append(" AND da.airport_code = '").append(destCode.toUpperCase()).append("'");
        sql.append(" ORDER BY rs.year ASC, rs.month ASC, rs.total_passengers DESC NULLS LAST");
        return jdbc.queryForList(sql.toString());
    }

    /**
     * Top routes by passenger count from route_statistics (all-time rows: year=0, month=0).
     */
    public List<Map<String, Object>> findTopRoutes(int limit) {
        String sql =
            "SELECT oa.airport_code AS origin_code, oc.name AS origin_city," +
            "       da.airport_code AS dest_code, dc.name AS dest_city," +
            "       rs.total_passengers, rs.total_revenue" +
            " FROM route_statistics rs" +
            " JOIN routes r    ON r.id  = rs.routes_id" +
            " JOIN airports oa ON oa.id = r.origin_airport_id" +
            " JOIN city oc     ON oc.id = oa.city_id" +
            " JOIN airports da ON da.id = r.destination_airport_id" +
            " JOIN city dc     ON dc.id = da.city_id" +
            " WHERE rs.year = 0 AND rs.month = 0" +
            " ORDER BY rs.total_passengers DESC NULLS LAST" +
            " FETCH FIRST " + limit + " ROWS ONLY";
        return jdbc.queryForList(sql);
    }

    // ── Revenue (route_statistics) ────────────────────────────────────────────

    /**
     * Revenue per route from route_statistics, optionally filtered by year.
     */
    public List<Map<String, Object>> findRouteRevenue(Integer year) {
        StringBuilder sql = new StringBuilder("""
            SELECT rs.routes_id AS route_id,
                   oa.airport_code AS origin_code, oc.name AS origin_city,
                   da.airport_code AS dest_code,   dc.name AS dest_city,
                   rs.year  AS pay_year,
                   rs.month AS pay_month,
                   rs.total_passengers,
                   rs.total_revenue
            FROM route_statistics rs
            JOIN routes r    ON r.id  = rs.routes_id
            JOIN airports oa ON oa.id = r.origin_airport_id
            JOIN city oc     ON oc.id = oa.city_id
            JOIN airports da ON da.id = r.destination_airport_id
            JOIN city dc     ON dc.id = da.city_id
            WHERE rs.month > 0 AND rs.year > 0
            """);
        if (year != null) sql.append(" AND rs.year = ").append(year);
        sql.append(" ORDER BY rs.year ASC, rs.month ASC, rs.total_revenue DESC NULLS LAST");
        return jdbc.queryForList(sql.toString());
    }

    // ── KPI Summary (route_statistics) ────────────────────────────────────────

    public Map<String, Object> findKpiSummary() {
        return jdbc.queryForMap("""
            SELECT
                (SELECT COUNT(*) FROM flights)                                  AS total_flights,
                (SELECT NVL(SUM(total_passengers), 0)
                   FROM route_statistics
                  WHERE year = 0 AND month = 0)                                 AS total_passengers,
                (SELECT NVL(SUM(total_revenue), 0)
                   FROM route_statistics
                  WHERE year = 0 AND month = 0)                                 AS total_revenue,
                (SELECT ROUND(AVG(occupancy_pct), 2) FROM v_flight_occupancy)   AS avg_occupancy_pct,
                (SELECT oa.airport_code || ' → ' || da.airport_code
                   FROM route_statistics rs
                   JOIN routes r    ON r.id  = rs.routes_id
                   JOIN airports oa ON oa.id = r.origin_airport_id
                   JOIN airports da ON da.id = r.destination_airport_id
                  WHERE rs.year = 0 AND rs.month = 0
                  ORDER BY rs.total_passengers DESC NULLS LAST
                  FETCH FIRST 1 ROWS ONLY)                                      AS top_route,
                (SELECT airline_name
                   FROM v_airline_ranking
                  ORDER BY total_revenue DESC NULLS LAST
                  FETCH FIRST 1 ROWS ONLY)                                      AS top_airline,
                (SELECT code FROM currency FETCH FIRST 1 ROWS ONLY)             AS revenue_currency
            FROM dual
            """);
    }

    // ── Airline Ranking ────────────────────────────────────────────────────────

    public List<Map<String, Object>> findAirlineRanking() {
        return jdbc.queryForList("""
            SELECT airline_id, airline_name, total_flights, total_passengers,
                   avg_occupancy_pct, NVL(total_revenue, 0) AS total_revenue
            FROM v_airline_ranking
            ORDER BY NVL(total_revenue, 0) DESC NULLS LAST
            """);
    }

    // ── Price Distribution ─────────────────────────────────────────────────────

    public List<Map<String, Object>> findPriceDistribution() {
        return jdbc.queryForList("""
            SELECT route_id, origin_code, dest_code, currency_code,
                   min_price, max_price, avg_price, median_price, flight_count
            FROM v_price_distribution
            ORDER BY flight_count DESC
            """);
    }
}
