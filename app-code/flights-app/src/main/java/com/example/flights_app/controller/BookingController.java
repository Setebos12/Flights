package com.example.flights_app.controller;

import com.example.flights_app.dto.BookingRequest;
import com.example.flights_app.dto.BookingResponse;
import com.example.flights_app.dto.ExtraServiceDTO;
import com.example.flights_app.dto.ReservationResponseDTO;
import com.example.flights_app.dto.SeatDTO;
import com.example.flights_app.model.Payment;
import com.example.flights_app.model.Reservation;
import com.example.flights_app.model.User;
import com.example.flights_app.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
public class BookingController {

    private final SeatRepository seatRepository;
    private final ExtraServiceRepository extraServiceRepository;
    private final ReservationRepository reservationRepository;
    private final PaymentRepository paymentRepository;
    private final UserRepository userRepository;
    private final PassengerRepository passengerRepository;

    @GetMapping("/api/flights/{flightId}/seats")
    public List<SeatDTO> getSeats(@PathVariable Long flightId) {
        return seatRepository.findSeatsForFlight(flightId).stream()
                .map(p -> new SeatDTO(
                        p.getId(), p.getRowNr(), p.getColumnNr(),
                        p.getSerialNumber(), p.getSeatType(), p.getClassType(),
                        p.getIsBooked() == 0))
                .collect(Collectors.toList());
    }

    @GetMapping("/api/reservations/me")
    public List<ReservationResponseDTO> getMyReservations() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmailAddress(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return reservationRepository.findByUserId(user.getId()).stream()
                .map(r -> new ReservationResponseDTO(
                        r.getReservationId(), r.getOriginCode(), r.getDestCode(),
                        r.getAirlineName(), r.getFlightPrice(), r.getCurrencyCode(),
                        r.getDepartureDatetime(), r.getPaymentStatus(), r.getPaymentAmount(),
                        r.getSeatRow(), r.getSeatCol(), r.getSeatType(), r.getClassType()))
                .collect(Collectors.toList());
    }

    @GetMapping("/api/extra-services")
    public List<ExtraServiceDTO> getExtraServices() {
        return extraServiceRepository.findAll().stream()
                .map(s -> new ExtraServiceDTO(s.getId(), s.getName(), s.getPrice()))
                .collect(Collectors.toList());
    }

    @PostMapping("/api/reservations")
    @Transactional
    public ResponseEntity<?> createBooking(@RequestBody BookingRequest request) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByEmailAddress(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Long passengerId = passengerRepository.findById(user.getPassengersId())
                .orElseThrow(() -> new RuntimeException("Passenger not found"))
                .getId();

        Long reservationId = reservationRepository.getNextId();

        // reservation
        Reservation reservation = new Reservation();
        reservation.setId(reservationId);
        reservation.setReservationDate(LocalDate.now());
        reservation.setNumberInParty(1);
        reservation.setUserId(user.getId());
        reservation.setFlightsId(request.getFlightId());
        reservationRepository.save(reservation);

        // triggers booked_seats_count update on flights
        reservationRepository.addPassenger(reservationId, passengerId);

        // extra services - before payment-> trigger
        if (request.getExtraServiceIds() != null) {
            for (Long serviceId : request.getExtraServiceIds()) {
                reservationRepository.addExtraService(reservationId, serviceId, passengerId);
            }
        }

        // boarding pass
        reservationRepository.insertBoardingPass(
                reservationId, passengerId, request.getSeatId(), request.getSeatSerialNumber());

        // payment - trigger calculates amount
        Long paymentId = paymentRepository.getNextId();
        Payment payment = new Payment();
        payment.setId(paymentId);
        payment.setPaymentDate(LocalDate.now());
        payment.setPaymentStatusId(2L); // completed
        payment.setPaymentAmount(null); // set by payment_calculation trigger
        payment.setCurrencyCode("EUR"); // overwritten by prejoin_payments
        payment.setReservationsId(reservationId);
        paymentRepository.save(payment);

        return ResponseEntity.ok(new BookingResponse(reservationId, "Booking confirmed"));
    }
}
