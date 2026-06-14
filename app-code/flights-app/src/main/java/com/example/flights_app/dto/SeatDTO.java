package com.example.flights_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class SeatDTO {
    private Integer row;
    private Integer col;
    private String seatType;
    private String className;
    private String status;

    public String getLabel() {
        return row + String.valueOf((char) ('A' + col - 1));
    }
}
