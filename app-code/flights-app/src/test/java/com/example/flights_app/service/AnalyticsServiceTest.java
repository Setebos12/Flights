package com.example.flights_app.service;

import com.example.flights_app.dto.AirlineRankingDTO;
import com.example.flights_app.dto.KpiSummaryDTO;
import com.example.flights_app.dto.OccupancyDTO;
import com.example.flights_app.dto.PriceDistributionDTO;
import com.example.flights_app.repository.AnalyticsRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

import static java.util.Map.entry;
import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AnalyticsServiceTest {

    @Mock
    private AnalyticsRepository analyticsRepository;

    @InjectMocks
    private AnalyticsService analyticsService;

    @Test
    void getOccupancy_mapsRepositoryRowsToDto() {
        Map<String, Object> row = Map.ofEntries(
                entry("FLIGHT_ID", 7L),
                entry("DEPARTURE_DATE_TIME", "2026-07-01T10:00:00Z"),
                entry("ARRIVAL_DATE_TIME", "2026-07-01T14:30:00Z"),
                entry("ORIGIN_CODE", "WAW"),
                entry("ORIGIN_NAME", "Warsaw Chopin"),
                entry("DEST_CODE", "JFK"),
                entry("DEST_NAME", "John F. Kennedy"),
                entry("AIRLINE_NAME", "SkyHigh"),
                entry("AIRLINE_ID", 3L),
                entry("PLANE_MODEL", "Airbus A320"),
                entry("BOOKED_SEATS", 145),
                entry("TOTAL_SEATS", 180),
                entry("OCCUPANCY_PCT", BigDecimal.valueOf(80.56)),
                entry("DEP_YEAR", 2026),
                entry("DEP_MONTH", 7),
                entry("PRICE", BigDecimal.valueOf(299.99)),
                entry("CURRENCY_CODE", "USD")
        );

        when(analyticsRepository.findOccupancy(3L, null, 2026, 7)).thenReturn(List.of(row));

        List<OccupancyDTO> result = analyticsService.getOccupancy(3L, null, 2026, 7);

        assertThat(result).hasSize(1);
        OccupancyDTO dto = result.get(0);
        assertThat(dto.getFlightId()).isEqualTo(7L);
        assertThat(dto.getOriginCode()).isEqualTo("WAW");
        assertThat(dto.getDestCode()).isEqualTo("JFK");
        assertThat(dto.getAirlineName()).isEqualTo("SkyHigh");
        assertThat(dto.getBookedSeats()).isEqualTo(145);
        assertThat(dto.getOccupancyPct()).isEqualByComparingTo("80.56");
        assertThat(dto.getPrice()).isEqualByComparingTo("299.99");
    }

    @Test
    void getKpiSummary_parsesTopRouteAndMetrics() {
        Map<String, Object> row = Map.of(
                "TOTAL_FLIGHTS", 120L,
                "TOTAL_PASSENGERS", 14500L,
                "TOTAL_REVENUE", BigDecimal.valueOf(340000.50),
                "AVG_OCCUPANCY_PCT", BigDecimal.valueOf(78.45),
                "TOP_ROUTE", "WAW → JFK",
                "TOP_AIRLINE", "SkyHigh",
                "REVENUE_CURRENCY", "USD"
        );

        when(analyticsRepository.findKpiSummary()).thenReturn(row);

        KpiSummaryDTO result = analyticsService.getKpiSummary();

        assertThat(result.getTotalFlights()).isEqualTo(120L);
        assertThat(result.getTotalPassengers()).isEqualTo(14500L);
        assertThat(result.getTotalRevenue()).isEqualByComparingTo("340000.50");
        assertThat(result.getAvgOccupancyPct()).isEqualByComparingTo("78.45");
        assertThat(result.getTopRouteOrigin()).isEqualTo("WAW");
        assertThat(result.getTopRouteDest()).isEqualTo("JFK");
        assertThat(result.getTopAirline()).isEqualTo("SkyHigh");
        assertThat(result.getRevenueCurrency()).isEqualTo("USD");
    }

    @Test
    void getAirlineRanking_convertsRepositoryRowsToDtoList() {
        Map<String, Object> row = Map.of(
                "AIRLINE_ID", 9L,
                "AIRLINE_NAME", "CloudAir",
                "TOTAL_FLIGHTS", 45L,
                "TOTAL_PASSENGERS", 7200L,
                "AVG_OCCUPANCY_PCT", BigDecimal.valueOf(85.7),
                "TOTAL_REVENUE", BigDecimal.valueOf(158000.00)
        );

        when(analyticsRepository.findAirlineRanking()).thenReturn(List.of(row));

        List<AirlineRankingDTO> result = analyticsService.getAirlineRanking();

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getAirlineName()).isEqualTo("CloudAir");
        assertThat(result.get(0).getTotalRevenue()).isEqualByComparingTo("158000.00");
    }

    @Test
    void getPriceDistribution_convertsRepositoryRowsToDtoList() {
        Map<String, Object> row = Map.of(
                "ROUTE_ID", 12L,
                "ORIGIN_CODE", "WAW",
                "DEST_CODE", "LHR",
                "CURRENCY_CODE", "EUR",
                "MIN_PRICE", BigDecimal.valueOf(120.00),
                "MAX_PRICE", BigDecimal.valueOf(450.00),
                "AVG_PRICE", BigDecimal.valueOf(280.50),
                "MEDIAN_PRICE", BigDecimal.valueOf(275.00),
                "FLIGHT_COUNT", 23L
        );

        when(analyticsRepository.findPriceDistribution()).thenReturn(List.of(row));

        List<PriceDistributionDTO> result = analyticsService.getPriceDistribution();

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getOriginCode()).isEqualTo("WAW");
        assertThat(result.get(0).getCurrencyCode()).isEqualTo("EUR");
        assertThat(result.get(0).getAvgPrice()).isEqualByComparingTo("280.50");
    }

    @Test
    void getTopRoutes_returnsEmptyWhenNoData() {
        when(analyticsRepository.findTopRoutes(10)).thenReturn(List.of());

        List<Map<String, Object>> result = analyticsService.getTopRoutes(10);

        assertThat(result).isEmpty();
    }

    @Test
    void getRouteRevenue_handlesNullFieldsGracefully() {
        Map<String, Object> row = new HashMap<>();
        row.put("ROUTE_ID", 99L);
        row.put("ORIGIN_CODE", null);
        row.put("ORIGIN_CITY", null);
        row.put("DEST_CODE", null);
        row.put("DEST_CITY", null);
        row.put("AIRLINE_ID", null);
        row.put("AIRLINE_NAME", null);
        row.put("PAY_YEAR", null);
        row.put("PAY_MONTH", null);
        row.put("TOTAL_PAYMENTS", null);
        row.put("TOTAL_REVENUE", null);
        row.put("AVG_PAYMENT", null);
        row.put("CURRENCY_CODE", null);

        when(analyticsRepository.findRouteRevenue(null, null)).thenReturn(List.of(row));

        List<com.example.flights_app.dto.RouteRevenueDTO> result = analyticsService.getRouteRevenue(null, null);

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getOriginCode()).isNull();
        assertThat(result.get(0).getTotalRevenue()).isNull();
    }
}
