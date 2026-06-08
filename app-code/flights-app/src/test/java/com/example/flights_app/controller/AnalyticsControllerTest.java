package com.example.flights_app.controller;

import com.example.flights_app.dto.AirlineRankingDTO;
import com.example.flights_app.dto.KpiSummaryDTO;
import com.example.flights_app.dto.OccupancyDTO;
import com.example.flights_app.dto.RouteRevenueDTO;
import com.example.flights_app.dto.RoutePopularityDTO;
import com.example.flights_app.service.AnalyticsService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(AnalyticsController.class)
class AnalyticsControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private AnalyticsService analyticsService;

    @Test
    void getKpiSummary_returnsKpiSummary() throws Exception {
        KpiSummaryDTO summary = new KpiSummaryDTO(
                120L,
                15000L,
                BigDecimal.valueOf(380000.00),
                BigDecimal.valueOf(79.5),
                "WAW",
                "JFK",
                "SkyHigh",
                "USD"
        );

        when(analyticsService.getKpiSummary()).thenReturn(summary);

        mockMvc.perform(get("/api/analytics/kpi").accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalFlights").value(120))
                .andExpect(jsonPath("$.topRouteOrigin").value("WAW"))
                .andExpect(jsonPath("$.topAirline").value("SkyHigh"));
    }

    @Test
    void getOccupancy_returnsOccupancyList() throws Exception {
        OccupancyDTO occupancy = new OccupancyDTO(
                7L,
                "2026-07-01T10:00:00Z",
                "2026-07-01T14:30:00Z",
                "WAW",
                "Warsaw Chopin",
                "JFK",
                "John F. Kennedy",
                "SkyHigh",
                3L,
                "Airbus A320",
                145,
                180,
                BigDecimal.valueOf(80.56),
                2026,
                7,
                BigDecimal.valueOf(299.99),
                "USD"
        );

        when(analyticsService.getOccupancy(3L, 4L, 2026, 7)).thenReturn(List.of(occupancy));

        mockMvc.perform(get("/api/analytics/occupancy")
                        .param("airlineId", "3")
                        .param("routeId", "4")
                        .param("year", "2026")
                        .param("month", "7")
                        .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].originCode").value("WAW"));
    }

    @Test
    void getTopRoutes_returnsSummaries() throws Exception {
        when(analyticsService.getTopRoutes(5)).thenReturn(List.of(
                Map.of(
                        "origin_code", "WAW",
                        "dest_code", "JFK",
                        "total_passengers", 3200L
                )
        ));

        mockMvc.perform(get("/api/analytics/routes/top")
                        .param("limit", "5")
                        .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].origin_code").value("WAW"));
    }
}
