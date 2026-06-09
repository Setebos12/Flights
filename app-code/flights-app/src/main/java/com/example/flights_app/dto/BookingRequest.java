package com.example.flights_app.dto;

import lombok.Data;
import java.util.List;

@Data
public class BookingRequest {
    private Long flightId;
    private Long seatId;
    private Long seatSerialNumber;
    private List<Long> extraServiceIds;
}
