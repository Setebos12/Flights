package com.example.flights_app.controller;

import com.example.flights_app.dto.ReservationConfirmationDTO;
import com.example.flights_app.dto.ReservationRequest;
import com.example.flights_app.dto.SeatMapResponseDTO;
import com.example.flights_app.service.ReservationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;
import java.util.List;
import java.util.Map;

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

    @GetMapping("/api/reservations/statuses")
    public Map<Long, String> getReservationStatuses(@RequestParam List<Long> ids) {
        return reservationService.getReservationStatuses(ids);
    }

    @PostMapping("/api/reservations/{id}/cancel")
    public ResponseEntity<String> cancelReservation(@PathVariable Long id, Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).body("Authentication required");
        }
        reservationService.cancelReservation(id, principal.getName());
        return ResponseEntity.ok("Reservation cancelled");
    }

    @PostMapping("/api/reservations/{id}/pay")
    public ResponseEntity<String> payReservation(@PathVariable Long id, Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).body("Authentication required");
        }
        reservationService.payReservation(id, principal.getName());
        return ResponseEntity.ok("Payment completed");
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<String> handleRuntimeException(RuntimeException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    }
}
