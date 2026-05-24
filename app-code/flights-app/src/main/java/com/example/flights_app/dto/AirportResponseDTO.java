package com.example.flights_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AirportResponseDTO {

    private Long id;
    private String airportCode;
    private String airportName;
    private String cityName;
    private String countryName;
}