package com.example.flights_app.service;

import com.example.flights_app.dto.*;
import com.example.flights_app.repository.AnalyticsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AnalyticsService {

    private final AnalyticsRepository analyticsRepository;

    // ── helpers ────────────────────────────────────────────────────────────────

    private BigDecimal toBD(Object val) {
        if (val == null) return null;
        if (val instanceof BigDecimal bd) return bd;
        return new BigDecimal(val.toString());
    }

    private Long toLong(Object val) {
        if (val == null) return null;
        if (val instanceof Long l) return l;
        return ((Number) val).longValue();
    }

    private Integer toInt(Object val) {
        if (val == null) return null;
        if (val instanceof Integer i) return i;
        return ((Number) val).intValue();
    }

    private String toStr(Object val) {
        return val == null ? null : val.toString();
    }

    // ── Occupancy ──────────────────────────────────────────────────────────────

    public List<OccupancyDTO> getOccupancy(Long airlineId, Long routeId,
                                            Integer year, Integer month) {
        return analyticsRepository.findOccupancy(airlineId, routeId, year, month)
                .stream()
                .map(r -> new OccupancyDTO(
                        toLong(r.get("FLIGHT_ID")),
                        toStr(r.get("DEPARTURE_DATE_TIME")),
                        toStr(r.get("ARRIVAL_DATE_TIME")),
                        toStr(r.get("ORIGIN_CODE")),
                        toStr(r.get("ORIGIN_NAME")),
                        toStr(r.get("DEST_CODE")),
                        toStr(r.get("DEST_NAME")),
                        toStr(r.get("AIRLINE_NAME")),
                        toLong(r.get("AIRLINE_ID")),
                        toStr(r.get("PLANE_MODEL")),
                        toInt(r.get("BOOKED_SEATS")),
                        toInt(r.get("TOTAL_SEATS")),
                        toBD(r.get("OCCUPANCY_PCT")),
                        toInt(r.get("DEP_YEAR")),
                        toInt(r.get("DEP_MONTH")),
                        toBD(r.get("PRICE")),
                        toStr(r.get("CURRENCY_CODE"))
                ))
                .toList();
    }

    public List<Map<String, Object>> getOccupancySummary() {
        return analyticsRepository.findOccupancySummary();
    }

    // ── Seasonality / Popularity ───────────────────────────────────────────────

    public List<RoutePopularityDTO> getRouteSeasonality(Integer year, String originCode,
                                                        String destCode) {
        return analyticsRepository.findRouteSeasonality(year, originCode, destCode)
                .stream()
                .map(r -> new RoutePopularityDTO(
                        toLong(r.get("ROUTE_ID")),
                        toStr(r.get("ORIGIN_CODE")),
                        toStr(r.get("ORIGIN_CITY")),
                        toStr(r.get("DEST_CODE")),
                        toStr(r.get("DEST_CITY")),
                        toInt(r.get("DEP_YEAR")),
                        toInt(r.get("DEP_MONTH")),
                        toLong(r.get("TOTAL_FLIGHTS")),
                        toLong(r.get("TOTAL_PASSENGERS")),
                        toBD(r.get("AVG_OCCUPANCY_PCT")),
                        toBD(r.get("AVG_PRICE")),
                        toStr(r.get("CURRENCY_CODE"))
                ))
                .toList();
    }

    public List<Map<String, Object>> getTopRoutes(int limit) {
        return analyticsRepository.findTopRoutes(limit);
    }

    // ── Revenue ────────────────────────────────────────────────────────────────

    public List<RouteRevenueDTO> getRouteRevenue(Integer year, Long airlineId) {
        return analyticsRepository.findRouteRevenue(year, airlineId)
                .stream()
                .map(r -> new RouteRevenueDTO(
                        toLong(r.get("ROUTE_ID")),
                        toStr(r.get("ORIGIN_CODE")),
                        toStr(r.get("ORIGIN_CITY")),
                        toStr(r.get("DEST_CODE")),
                        toStr(r.get("DEST_CITY")),
                        toLong(r.get("AIRLINE_ID")),
                        toStr(r.get("AIRLINE_NAME")),
                        toInt(r.get("PAY_YEAR")),
                        toInt(r.get("PAY_MONTH")),
                        toLong(r.get("TOTAL_PAYMENTS")),
                        toBD(r.get("TOTAL_REVENUE")),
                        toBD(r.get("AVG_PAYMENT")),
                        toStr(r.get("CURRENCY_CODE"))
                ))
                .toList();
    }

    // ── KPI ────────────────────────────────────────────────────────────────────

    public KpiSummaryDTO getKpiSummary() {
        Map<String, Object> r = analyticsRepository.findKpiSummary();
        String topRoute = toStr(r.get("TOP_ROUTE"));
        String[] routeParts = topRoute != null ? topRoute.split(" → ") : new String[]{"—", "—"};
        return new KpiSummaryDTO(
                toLong(r.get("TOTAL_FLIGHTS")),
                toLong(r.get("TOTAL_PASSENGERS")),
                toBD(r.get("TOTAL_REVENUE")),
                toBD(r.get("AVG_OCCUPANCY_PCT")),
                routeParts.length > 0 ? routeParts[0] : "—",
                routeParts.length > 1 ? routeParts[1] : "—",
                toStr(r.get("TOP_AIRLINE")),
                toStr(r.get("REVENUE_CURRENCY"))
        );
    }

    // ── Airline Ranking ────────────────────────────────────────────────────────

    public List<AirlineRankingDTO> getAirlineRanking() {
        return analyticsRepository.findAirlineRanking()
                .stream()
                .map(r -> new AirlineRankingDTO(
                        toLong(r.get("AIRLINE_ID")),
                        toStr(r.get("AIRLINE_NAME")),
                        toLong(r.get("TOTAL_FLIGHTS")),
                        toLong(r.get("TOTAL_PASSENGERS")),
                        toBD(r.get("AVG_OCCUPANCY_PCT")),
                        toBD(r.get("TOTAL_REVENUE"))
                ))
                .toList();
    }

    // ── Price Distribution ─────────────────────────────────────────────────────

    public List<PriceDistributionDTO> getPriceDistribution() {
        return analyticsRepository.findPriceDistribution()
                .stream()
                .map(r -> new PriceDistributionDTO(
                        toLong(r.get("ROUTE_ID")),
                        toStr(r.get("ORIGIN_CODE")),
                        toStr(r.get("DEST_CODE")),
                        toStr(r.get("CURRENCY_CODE")),
                        toBD(r.get("MIN_PRICE")),
                        toBD(r.get("MAX_PRICE")),
                        toBD(r.get("AVG_PRICE")),
                        toBD(r.get("MEDIAN_PRICE")),
                        toLong(r.get("FLIGHT_COUNT"))
                ))
                .toList();
    }
}
