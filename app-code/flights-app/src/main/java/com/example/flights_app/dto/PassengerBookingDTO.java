package com.example.flights_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PassengerBookingDTO {
    private String firstName;
    private String lastName;
    private String seatLabel;
}
