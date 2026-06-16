package com.example.flights_app.repository;

import oracle.jdbc.OracleTypes;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Types;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Native queries against analytics data.
 * Seasonality, top-routes, revenue and KPI now read from the
 * aggregate table route_statistics instead of heavy views.
 * Occupancy and seasonality use stored procedures (get_occupancy, get_route_seasonality).
 * Other queries use native SQL against views.
 */
@Repository
public class AnalyticsRepository {

    private final JdbcTemplate jdbc;
    private final SimpleJdbcCall occupancyCall;
    private final SimpleJdbcCall seasonalityCall;

    public AnalyticsRepository(JdbcTemplate jdbc, DataSource dataSource) {
        this.jdbc = jdbc;

        this.occupancyCall = new SimpleJdbcCall(dataSource)
                .withProcedureName("get_occupancy")
                .withoutProcedureColumnMetaDataAccess()
                .declareParameters(
                        new SqlParameter("p_airline_id", Types.NUMERIC),
                        new SqlParameter("p_route_id", Types.NUMERIC),
                        new SqlParameter("p_year", Types.NUMERIC),
                        new SqlParameter("p_month", Types.NUMERIC),
                        new SqlOutParameter("p_result", OracleTypes.CURSOR,
                                (ResultSet rs, int rowNum) -> rsRowToMap(rs))
                );

        this.seasonalityCall = new SimpleJdbcCall(dataSource)
                .withProcedureName("get_route_seasonality")
                .withoutProcedureColumnMetaDataAccess()
                .declareParameters(
                        new SqlParameter("p_year", Types.NUMERIC),
                        new SqlParameter("p_origin_code", Types.VARCHAR),
                        new SqlParameter("p_dest_code", Types.VARCHAR),
                        new SqlOutParameter("p_result", OracleTypes.CURSOR,
                                (ResultSet rs, int rowNum) -> rsRowToMap(rs))
                );
    }

    /** Converts a single ResultSet row into a Map with uppercase column names. */
    @SuppressWarnings("unchecked")
    private static Map<String, Object> rsRowToMap(ResultSet rs) {
        try {
            ResultSetMetaData meta = rs.getMetaData();
            Map<String, Object> row = new LinkedHashMap<>();
            for (int i = 1; i <= meta.getColumnCount(); i++) {
                row.put(meta.getColumnLabel(i).toUpperCase(), rs.getObject(i));
            }
            return row;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    // ── Occupancy ──────────────────────────────────────────────────────────────

    /**
     * Returns per-flight occupancy via stored procedure get_occupancy.
     * Optionally filtered by airline, route, year, month.
     */
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> findOccupancy(Long airlineId, Long routeId,
                                                    Integer year, Integer month) {
        Map<String, Object> mutableParams = new java.util.HashMap<>();
        mutableParams.put("p_airline_id", airlineId);
        mutableParams.put("p_route_id", routeId);
        mutableParams.put("p_year", year);
        mutableParams.put("p_month", month);

        Map<String, Object> result = occupancyCall.execute(mutableParams);
        return (List<Map<String, Object>>) result.get("p_result");
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
     * Route popularity with seasonality via stored procedure get_route_seasonality.
     * Reads monthly rows, optionally filtered by year, origin and destination codes.
     */
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> findRouteSeasonality(Integer year, String originCode,
                                                          String destCode) {
        Map<String, Object> mutableParams = new java.util.HashMap<>();
        mutableParams.put("p_year", year);
        mutableParams.put("p_origin_code", originCode != null && !originCode.isBlank()
                ? originCode.toUpperCase() : null);
        mutableParams.put("p_dest_code", destCode != null && !destCode.isBlank()
                ? destCode.toUpperCase() : null);

        Map<String, Object> result = seasonalityCall.execute(mutableParams);
        return (List<Map<String, Object>>) result.get("p_result");
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
