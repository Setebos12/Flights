package com.example.flights_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
@AllArgsConstructor
public class SeatMapResponseDTO {
    private Long flightId;
    private String planeModel;
    private String currencyCode;
    private BigDecimal price;
    private Integer rows;
    private Integer columns;
    private List<SeatDTO> seats;
    private List<ExtraServiceDTO> services;
}
