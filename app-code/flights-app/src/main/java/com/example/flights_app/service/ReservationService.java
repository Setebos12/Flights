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
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import org.springframework.dao.EmptyResultDataAccessException;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.security.Principal;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
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

        Long serialNumber = flight.getPlane().getSerialNumber();
        List<SeatDTO> seats = jdbcTemplate.query(
                "SELECT s.ROW_NR, s.COLUMN_NR, st.TYPE AS TYPE_NAME, c.TYPE AS CLASS_NAME " +
                        "FROM SEATS s " +
                        "LEFT JOIN SEAT_TYPE st ON s.SEAT_TYPE_ID = st.ID " +
                        "LEFT JOIN CLASS c ON s.CLASS_ID = c.ID " +
                        "WHERE s.SERIAL_NUMBER = ? " +
                        "ORDER BY s.ROW_NR, s.COLUMN_NR",
                new Object[]{serialNumber},
                (rs, rowNum) -> {
                    int row = rs.getInt("ROW_NR");
                    int col = rs.getInt("COLUMN_NR");
                    String label = row + String.valueOf((char) ('A' + col - 1));
                    return new SeatDTO(row, col, label, "available", rs.getString("TYPE_NAME"), rs.getString("CLASS_NAME"));
                }
        );

        Set<String> occupied = new HashSet<>();
        jdbcTemplate.query(
                "SELECT bp.SEAT_ROW, bp.SEAT_COL " +
                        "FROM BOARDING_PASS bp " +
                        "JOIN RESERVATIONS r ON bp.RESERVATIONS_ID = r.ID " +
                        "WHERE r.FLIGHTS_ID = ?",
                new Object[]{flightId},
                (ResultSet rs) -> {
                    while (rs.next()) {
                        occupied.add(rs.getInt("SEAT_ROW") + String.valueOf((char) ('A' + rs.getInt("SEAT_COL") - 1)));
                    }
                    return null;
                }
        );

        for (SeatDTO seat : seats) {
            if (occupied.contains(seat.getLabel())) {
                seat.setStatus("occupied");
            }
        }

        int maxRow = seats.stream().mapToInt(SeatDTO::getRow).max().orElse(0);
        int maxCol = seats.stream().mapToInt(SeatDTO::getCol).max().orElse(0);

        if (seats.isEmpty()) {
            int seatCount = flight.getSeatCount() != null ? flight.getSeatCount() : (flight.getPlane().getSeatCount() != null ? flight.getPlane().getSeatCount() : 24);
            int columns = 4;
            int rows = (seatCount + columns - 1) / columns;
            for (int row = 1; row <= rows; row++) {
                for (int col = 1; col <= columns; col++) {
                    int index = (row - 1) * columns + col;
                    if (index > seatCount) break;
                    String label = row + String.valueOf((char) ('A' + col - 1));
                    seats.add(new SeatDTO(row, col, label, "available", null, null));
                }
            }
            maxRow = rows;
            maxCol = columns;
        }

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

        Long reservationId = reservationRepository.createReservationHeader(
                user.getId(), flight.getId(), passengers.size()
        );

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
