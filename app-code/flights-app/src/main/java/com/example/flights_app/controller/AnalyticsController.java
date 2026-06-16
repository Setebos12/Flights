package com.example.flights_app.controller;

import com.example.flights_app.dto.*;
import com.example.flights_app.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * REST controller exposing analytics endpoints at /api/analytics/*.
 * All endpoints return JSON and are read-only (GET).
 */
@RestController
@RequestMapping("/api/analytics")
@RequiredArgsConstructor
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    /**
     * GET /api/analytics/kpi
     * Dashboard KPI summary: total flights, passengers, revenue, avg occupancy, top route/airline.
     */
    @GetMapping("/kpi")
    public KpiSummaryDTO getKpiSummary() {
        return analyticsService.getKpiSummary();
    }

    /**
     * GET /api/analytics/occupancy?airlineId=&routeId=&year=&month=
     * Per-flight occupancy data with optional filters.
     */
    @GetMapping("/occupancy")
    public List<OccupancyDTO> getOccupancy(
            @RequestParam(required = false) Long airlineId,
            @RequestParam(required = false) Long routeId,
            @RequestParam(required = false) Integer year,
            @RequestParam(required = false) Integer month
    ) {
        return analyticsService.getOccupancy(airlineId, routeId, year, month);
    }

    /**
     * GET /api/analytics/occupancy/summary
     * Aggregated avg occupancy per airline.
     */
    @GetMapping("/occupancy/summary")
    public List<Map<String, Object>> getOccupancySummary() {
        return analyticsService.getOccupancySummary();
    }

    /**
     * GET /api/analytics/routes/seasonality?year=&originCode=&destCode=
     * Route popularity with monthly seasonality data.
     */
    @GetMapping("/routes/seasonality")
    public List<RoutePopularityDTO> getRouteSeasonality(
            @RequestParam(required = false) Integer year,
            @RequestParam(required = false) String originCode,
            @RequestParam(required = false) String destCode
    ) {
        return analyticsService.getRouteSeasonality(year, originCode, destCode);
    }

    /**
     * GET /api/analytics/routes/top?limit=10
     * Top routes by total passenger count.
     */
    @GetMapping("/routes/top")
    public List<Map<String, Object>> getTopRoutes(
            @RequestParam(defaultValue = "10") int limit
    ) {
        return analyticsService.getTopRoutes(limit);
    }

    /**
     * GET /api/analytics/routes/revenue?year=
     * Revenue per route from route_statistics.
     */
    @GetMapping("/routes/revenue")
    public List<RouteRevenueDTO> getRouteRevenue(
            @RequestParam(required = false) Integer year
    ) {
        return analyticsService.getRouteRevenue(year);
    }

    /**
     * GET /api/analytics/airlines/ranking
     * Airline ranking by total revenue, flights, occupancy.
     */
    @GetMapping("/airlines/ranking")
    public List<AirlineRankingDTO> getAirlineRanking() {
        return analyticsService.getAirlineRanking();
    }

    /**
     * GET /api/analytics/prices/distribution
     * Price distribution (min/max/avg/median) per route.
     */
    @GetMapping("/prices/distribution")
    public List<PriceDistributionDTO> getPriceDistribution() {
        return analyticsService.getPriceDistribution();
    }
}
