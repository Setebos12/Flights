package com.example.flights_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
public class OccupancyDTO {
    private Long flightId;
    private String departureDatetime;
    private String arrivalDatetime;
    private String originCode;
    private String originName;
    private String destCode;
    private String destName;
    private String airlineName;
    private Long airlineId;
    private String planeModel;
    private Integer bookedSeats;
    private Integer totalSeats;
    private BigDecimal occupancyPct;
    private Integer depYear;
    private Integer depMonth;
    private BigDecimal price;
    private String currencyCode;
}
