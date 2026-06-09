package com.example.flights_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class SeatDTO {
    private Integer row;
    private Integer col;
    private String label;
    private String status;
    private String seatType;
    private String className;
}
