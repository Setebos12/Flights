package com.example.flights_app.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Native queries against analytics views (v_flight_occupancy, v_route_seasonality,
 * v_route_revenue, v_airline_ranking, v_price_distribution).
 * Uses JdbcTemplate for flexibility with Oracle SQL and dynamic filtering.
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

    // ── Seasonality / Popularity ───────────────────────────────────────────────

    /**
     * Route popularity with seasonality, optionally filtered by year.
     */
    public List<Map<String, Object>> findRouteSeasonality(Integer year, String originCode,
                                                          String destCode) {
        StringBuilder sql = new StringBuilder("""
            SELECT route_id, origin_code, origin_city, dest_code, dest_city,
                   dep_year, dep_month, total_flights, total_passengers,
                   avg_occupancy_pct, avg_price, currency_code
            FROM v_route_seasonality
            WHERE 1=1
            """);
        if (year       != null) sql.append(" AND dep_year = ").append(year);
        if (originCode != null && !originCode.isBlank())
            sql.append(" AND origin_code = '").append(originCode.toUpperCase()).append("'");
        if (destCode   != null && !destCode.isBlank())
            sql.append(" AND dest_code = '").append(destCode.toUpperCase()).append("'");
        sql.append(" ORDER BY dep_year ASC, dep_month ASC, total_passengers DESC");
        return jdbc.queryForList(sql.toString());
    }

    /**
     * Top routes by passenger count (all-time).
     */
    public List<Map<String, Object>> findTopRoutes(int limit) {
        String sql =
            "SELECT origin_code, origin_city, dest_code, dest_city," +
            "       SUM(total_flights)              AS total_flights," +
            "       SUM(total_passengers)           AS total_passengers," +
            "       ROUND(AVG(avg_occupancy_pct),2) AS avg_occupancy_pct" +
            " FROM v_route_seasonality" +
            " GROUP BY origin_code, origin_city, dest_code, dest_city" +
            " ORDER BY total_passengers DESC NULLS LAST" +
            " FETCH FIRST " + limit + " ROWS ONLY";
        return jdbc.queryForList(sql);
    }

    // ── Revenue ────────────────────────────────────────────────────────────────

    /**
     * Route revenue for completed payments, optionally filtered by year, airline.
     */
    public List<Map<String, Object>> findRouteRevenue(Integer year, Long airlineId) {
        StringBuilder sql = new StringBuilder("""
            SELECT route_id, origin_code, origin_city, dest_code, dest_city,
                   airline_id, airline_name, pay_year, pay_month,
                   total_payments, total_revenue, avg_payment, currency_code
            FROM v_route_revenue
            WHERE 1=1
            """);
        if (year      != null) sql.append(" AND pay_year = ").append(year);
        if (airlineId != null) sql.append(" AND airline_id = ").append(airlineId);
        sql.append(" ORDER BY pay_year ASC, pay_month ASC, total_revenue DESC NULLS LAST");
        return jdbc.queryForList(sql.toString());
    }

    // ── KPI Summary ────────────────────────────────────────────────────────────

    public Map<String, Object> findKpiSummary() {
        return jdbc.queryForMap("""
            SELECT
                (SELECT COUNT(*) FROM flights)                                  AS total_flights,
                (SELECT NVL(SUM(booked_seats_count), 0) FROM flights)           AS total_passengers,
                (SELECT NVL(SUM(payment_amount), 0) FROM payments
                  WHERE payment_status_id = 2)                                  AS total_revenue,
                (SELECT ROUND(AVG(occupancy_pct), 2) FROM v_flight_occupancy)   AS avg_occupancy_pct,
                (SELECT origin_code || ' → ' || dest_code
                   FROM (SELECT origin_code, dest_code, SUM(total_passengers) AS tp
                           FROM v_route_seasonality
                          GROUP BY origin_code, dest_code
                          ORDER BY tp DESC NULLS LAST
                          FETCH FIRST 1 ROWS ONLY))                             AS top_route,
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
