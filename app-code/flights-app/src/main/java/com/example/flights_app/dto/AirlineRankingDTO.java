package com.example.flights_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
public class AirlineRankingDTO {
    private Long airlineId;
    private String airlineName;
    private Long totalFlights;
    private Long totalPassengers;
    private BigDecimal avgOccupancyPct;
    private BigDecimal totalRevenue;
}
