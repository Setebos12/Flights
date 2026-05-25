package com.example.flights_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
public class PriceDistributionDTO {
    private Long routeId;
    private String originCode;
    private String destCode;
    private String currencyCode;
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
    private BigDecimal avgPrice;
    private BigDecimal medianPrice;
    private Long flightCount;
}
