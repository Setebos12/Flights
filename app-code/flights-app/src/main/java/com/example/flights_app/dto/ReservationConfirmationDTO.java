package com.example.flights_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
@AllArgsConstructor
public class ReservationConfirmationDTO {
    private Long reservationId;
    private Long flightId;
    private Integer passengerCount;
    private BigDecimal totalAmount;
    private List<String> seatLabels;
    private String message;
}
