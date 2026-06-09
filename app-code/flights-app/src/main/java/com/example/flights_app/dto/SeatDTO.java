package com.example.flights_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class SeatDTO {
    private Long id;
    private Integer rowNr;
    private Integer colNr;
    private Long serialNumber;
    private String seatType;
    private String classType;
    private boolean available;
}
