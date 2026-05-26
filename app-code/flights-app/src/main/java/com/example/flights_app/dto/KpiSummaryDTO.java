package com.example.flights_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
public class KpiSummaryDTO {
    private Long totalFlights;
    private Long totalPassengers;
    private BigDecimal totalRevenue;
    private BigDecimal avgOccupancyPct;
    private String topRouteOrigin;
    private String topRouteDest;
    private String topAirline;
    private String revenueCurrency;
}
