package com.example.flights_app.dto;


import lombok.AllArgsConstructor;
import lombok.Data;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Data
@AllArgsConstructor
public class FlightResponseDTO {

    private Long id;
    private OffsetDateTime departureDatetime;
    private OffsetDateTime arrivalDatetime;

    // Route
    private String originAirportCode;
    private String originAirportName;
    private String originCity;

    private String destinationAirportCode;
    private String destinationAirportName;
    private String destinationCity;

    // Plane
    private String planeModel;

    private BigDecimal price;

    // Airline
    private String airlineName;

    // Currency
    private String currencyCode;

    private Integer bookedSeatsCount;
    private Integer seatCount;
    private Integer availableSeats;
}
