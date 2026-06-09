package com.example.flights_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.math.BigDecimal;

@Data
@AllArgsConstructor
public class ReservationResponseDTO {
    private Long reservationId;
    private String originCode;
    private String destCode;
    private String airlineName;
    private BigDecimal flightPrice;
    private String currencyCode;
    private String departureDatetime;
    private String paymentStatus;
    private BigDecimal paymentAmount;
    private Integer seatRow;
    private Integer seatCol;
    private String seatType;
    private String classType;
}
