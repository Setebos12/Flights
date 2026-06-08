package com.example.flights_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReservationRequest {
    private Long flightId;
    private List<PassengerBookingDTO> passengers;
    private List<Long> serviceIds;
}
