package com.example.flights_app.controller;

import com.example.flights_app.dto.ReservationConfirmationDTO;
import com.example.flights_app.dto.ReservationRequest;
import com.example.flights_app.dto.SeatMapResponseDTO;
import com.example.flights_app.service.ReservationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;

@RestController
@RequestMapping
@RequiredArgsConstructor
public class ReservationController {

    private final ReservationService reservationService;

    @GetMapping("/api/flights/{flightId}/seat-map")
    public SeatMapResponseDTO getSeatMap(@PathVariable Long flightId) {
        return reservationService.getSeatMap(flightId);
    }

    @PostMapping("/api/reservations")
    public ReservationConfirmationDTO createReservation(@RequestBody ReservationRequest request, Principal principal) {
        if (principal == null) {
            throw new RuntimeException("Authentication required for reservation");
        }
        return reservationService.createReservation(request, principal.getName());
    }
}
