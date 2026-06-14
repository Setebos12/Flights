package com.example.flights_app.service;

import com.example.flights_app.dto.ExtraServiceDTO;
import com.example.flights_app.dto.PassengerBookingDTO;
import com.example.flights_app.dto.ReservationConfirmationDTO;
import com.example.flights_app.dto.ReservationRequest;
import com.example.flights_app.dto.SeatDTO;
import com.example.flights_app.dto.SeatMapResponseDTO;
import com.example.flights_app.model.ExtraService;
import com.example.flights_app.model.Flight;
import com.example.flights_app.model.User;
import com.example.flights_app.repository.ExtraServiceRepository;
import com.example.flights_app.repository.FlightRepository;
import com.example.flights_app.repository.ReservationRepository;
import com.example.flights_app.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReservationService {

    private final JdbcTemplate jdbcTemplate;
    private final FlightRepository flightRepository;
    private final UserRepository userRepository;
    private final ExtraServiceRepository extraServiceRepository;
    private final ReservationRepository reservationRepository;

    public SeatMapResponseDTO getSeatMap(Long flightId) {
        Flight flight = flightRepository.findById(flightId)
                .orElseThrow(() -> new RuntimeException("Flight not found"));

        System.out.println("Flight found: " + flight.getId());
        List<SeatDTO> seats = flightRepository.findSeatsByFlightId(flightId);

        int maxRow = seats.stream().mapToInt(SeatDTO::getRow).max().orElse(0);
        int maxCol = seats.stream().mapToInt(SeatDTO::getCol).max().orElse(0);

        List<ExtraServiceDTO> services = extraServiceRepository.findAll().stream()
                .map(service -> new ExtraServiceDTO(service.getId(), service.getServiceName(), service.getPrice()))
                .toList();

        return new SeatMapResponseDTO(
                flight.getId(),
                flight.getPlane().getModel(),
                flight.getCurrency().getCode(),
                flight.getPrice(),
                maxRow,
                maxCol,
                seats,
                services
        );
    }

    @Transactional
    public ReservationConfirmationDTO createReservation(ReservationRequest request, String userEmail) {
        Flight flight = flightRepository.findById(request.getFlightId())
                .orElseThrow(() -> new RuntimeException("Flight not found"));

        User user = userRepository.findByEmailAddress(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<PassengerBookingDTO> passengers = request.getPassengers();

        List<String> createdSeats = new ArrayList<>();
        List<Long> chosenServiceIds = request.getServiceIds() != null ? request.getServiceIds() : List.of();
        List<ExtraService> chosenServices = chosenServiceIds.isEmpty()
                ? List.of()
                : extraServiceRepository.findAllById(chosenServiceIds);
        BigDecimal totalAmount = flight.getPrice().multiply(BigDecimal.valueOf(passengers.size()));
        BigDecimal servicesTotal = chosenServices.stream()
                .map(ExtraService::getPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .multiply(BigDecimal.valueOf(passengers.size()));

        totalAmount = totalAmount.add(servicesTotal);

        Long reservationId = reservationRepository.createReservation(
                user.getId(), flight.getId(), passengers.size(), totalAmount, flight.getCurrency().getCode()
        );

        for (PassengerBookingDTO passenger : passengers) {
            String seatLabel = passenger.getSeatLabel().trim().toUpperCase();

            Long passengerId = reservationRepository.addPassengerAndBoardingPass(
                    reservationId, flight.getId(), passenger.getFirstName(),
                    passenger.getLastName(), parseRow(seatLabel), parseColumn(seatLabel)
            );

            for (ExtraService service : chosenServices) {
                jdbcTemplate.update(
                        "INSERT INTO RESERVATIONS_EXTRA_SERVICES (RESERVATIONS_ID, EXTRA_SERVICES_ID, PASSENGER_ID) VALUES (?, ?, ?)",
                        reservationId, service.getId(), passengerId
                );
            }
            createdSeats.add(seatLabel);
        }

        return new ReservationConfirmationDTO(reservationId, flight.getId(), passengers.size(), totalAmount, createdSeats, "Success");
    }

    public Map<Long, String> getReservationStatuses(List<Long> reservationIds) {
        if (reservationIds == null || reservationIds.isEmpty()) return Map.of();

        return reservationRepository.findReservationStatusesRaw(reservationIds)
            .stream()
            .collect(Collectors.toMap(
                row -> ((Number) row[0]).longValue(),
                row -> (String) row[1]
            ));
    }

    @Transactional
    public void cancelReservation(Long reservationId, String username) {
        User user = userRepository.findByEmailAddress(username).orElseThrow();
        reservationRepository.cancelReservation(reservationId, user.getId());
    }

    @Transactional
    public void payReservation(Long reservationId, String username) {
        User user = userRepository.findByEmailAddress(username).orElseThrow();
        reservationRepository.payReservation(reservationId, user.getId());
    }

    private int parseRow(String seatLabel) {
        String rowPart = seatLabel.replaceAll("[A-I]$", "");
        return Integer.parseInt(rowPart);
    }

    private int parseColumn(String seatLabel) {
        char column = seatLabel.charAt(seatLabel.length() - 1);
        return column - 'A' + 1;
    }
}
