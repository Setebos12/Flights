package com.example.flights_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
public class RouteRevenueDTO {
    private Long routeId;
    private String originCode;
    private String originCity;
    private String destCode;
    private String destCity;
    private Long airlineId;
    private String airlineName;
    private Integer payYear;
    private Integer payMonth;
    private Long totalPayments;
    private BigDecimal totalRevenue;
    private BigDecimal avgPayment;
    private String currencyCode;
}
