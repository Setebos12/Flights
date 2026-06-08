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
import com.example.flights_app.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.security.Principal;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class ReservationService {

    private final JdbcTemplate jdbcTemplate;
    private final FlightRepository flightRepository;
    private final UserRepository userRepository;
    private final ExtraServiceRepository extraServiceRepository;

    public SeatMapResponseDTO getSeatMap(Long flightId) {
        Flight flight = flightRepository.findById(flightId)
                .orElseThrow(() -> new RuntimeException("Flight not found"));

        Long serialNumber = flight.getPlane().getSerialNumber();
        List<SeatDTO> seats = jdbcTemplate.query(
                "SELECT s.ROW_NR, s.COLUMN_NR, st.TYPE AS TYPE_NAME " +
                        "FROM SEATS s " +
                        "LEFT JOIN SEAT_TYPE st ON s.SEAT_TYPE_ID = st.ID " +
                        "WHERE s.SERIAL_NUMBER = ? " +
                        "ORDER BY s.ROW_NR, s.COLUMN_NR",
                new Object[]{serialNumber},
                (rs, rowNum) -> {
                    int row = rs.getInt("ROW_NR");
                    int col = rs.getInt("COLUMN_NR");
                    String label = row + String.valueOf((char) ('A' + col - 1));
                    return new SeatDTO(row, col, label, "available", rs.getString("TYPE_NAME"));
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
                    seats.add(new SeatDTO(row, col, label, "available", null));
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

        if (request.getPassengers() == null || request.getPassengers().isEmpty()) {
            throw new RuntimeException("At least one passenger is required");
        }

        Set<String> seatLabels = new HashSet<>();
        List<PassengerBookingDTO> passengers = request.getPassengers();
        for (PassengerBookingDTO passenger : passengers) {
            if (passenger.getFirstName() == null || passenger.getFirstName().trim().isEmpty()) {
                throw new RuntimeException("Passenger first name is required");
            }
            if (passenger.getLastName() == null || passenger.getLastName().trim().isEmpty()) {
                throw new RuntimeException("Passenger last name is required");
            }
            if (passenger.getSeatLabel() == null || passenger.getSeatLabel().trim().isEmpty()) {
                throw new RuntimeException("Passenger seat label is required");
            }
            String label = passenger.getSeatLabel().trim().toUpperCase();
            if (!label.matches("^[1-9][0-9]*[A-I]$")) {
                throw new RuntimeException("Invalid seat label: " + label);
            }
            if (!seatLabels.add(label)) {
                throw new RuntimeException("Duplicate seat selected: " + label);
            }
        }

        List<Long> chosenServiceIds = request.getServiceIds() != null ? request.getServiceIds() : List.of();
        List<ExtraService> chosenServices = chosenServiceIds.isEmpty()
                ? List.of()
                : extraServiceRepository.findAllById(chosenServiceIds);

        int passengerCount = passengers.size();
        String reservationIdSql = "SELECT NVL(MAX(ID),0)+1 FROM RESERVATIONS";
        Long reservationId = jdbcTemplate.queryForObject(reservationIdSql, Long.class);
        jdbcTemplate.update(
                "INSERT INTO RESERVATIONS (ID, USER_ID, FLIGHTS_ID, NUMBER_IN_PARTY) VALUES (?, ?, ?, ?)",
                reservationId, user.getId(), flight.getId(), passengerCount
        );

        Set<String> occupied = new HashSet<>();
        jdbcTemplate.query(
                "SELECT bp.SEAT_ROW, bp.SEAT_COL " +
                        "FROM BOARDING_PASS bp " +
                        "JOIN RESERVATIONS r ON bp.RESERVATIONS_ID = r.ID " +
                        "WHERE r.FLIGHTS_ID = ?",
                new Object[]{flight.getId()},
                (ResultSet rs) -> {
                    while (rs.next()) {
                        occupied.add(rs.getInt("SEAT_ROW") + String.valueOf((char) ('A' + rs.getInt("SEAT_COL") - 1)));
                    }
                    return null;
                }
        );

        List<String> reservedSeats = new ArrayList<>();
        for (PassengerBookingDTO passenger : passengers) {
            String seatLabel = passenger.getSeatLabel().trim().toUpperCase();
            if (occupied.contains(seatLabel)) {
                throw new RuntimeException("Seat already booked: " + seatLabel);
            }
            reservedSeats.add(seatLabel);
        }

        String passengerNextIdSql = "SELECT NVL(MAX(ID),0)+1 FROM PASSENGERS";
        List<String> createdSeats = new ArrayList<>();

        BigDecimal totalAmount = flight.getPrice().multiply(BigDecimal.valueOf(passengerCount));
        BigDecimal servicesTotal = chosenServices.stream()
                .map(ExtraService::getPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .multiply(BigDecimal.valueOf(passengerCount));
        totalAmount = totalAmount.add(servicesTotal);

        for (PassengerBookingDTO passenger : passengers) {
            Long passengerId = jdbcTemplate.queryForObject(passengerNextIdSql, Long.class);
            jdbcTemplate.update(
                    "INSERT INTO PASSENGERS (ID, FIRST_NAME, LAST_NAME, PHONE_NUMBER, OTHER_PASSENGER_DETAILS, USER_ID) VALUES (?, ?, ?, ?, ?, ?)",
                    passengerId,
                    passenger.getFirstName().trim(),
                    passenger.getLastName().trim(),
                    null,
                    null,
                    null
            );
            jdbcTemplate.update(
                    "INSERT INTO RESERVATIONS_PASSENGERS (RESERVATIONS_ID, PASSENGERS_ID) VALUES (?, ?)",
                    reservationId,
                    passengerId
            );

            int row = parseRow(passenger.getSeatLabel());
            int col = parseColumn(passenger.getSeatLabel());
            Long seatId = jdbcTemplate.queryForObject(
                    "SELECT ID FROM SEATS WHERE SERIAL_NUMBER = ? AND ROW_NR = ? AND COLUMN_NR = ?",
                    Long.class,
                    flight.getPlane().getSerialNumber(),
                    row,
                    col
            );

            jdbcTemplate.update(
                    "INSERT INTO BOARDING_PASS (RESERVATIONS_ID, PASSENGERS_ID, SEATS_ID, SERIAL_NUMBER, DEPARTURE_AIRPORT_CODE, ARRIVAL_AIRPORT_CODE, FLIGHT_DEPARTURE_DATE_TIME, PASSENGER_FIRST_NAME, PASSENGER_LAST_NAME, SEAT_ROW, SEAT_COL) " +
                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    reservationId,
                    passengerId,
                    seatId,
                    flight.getPlane().getSerialNumber(),
                    flight.getRoute().getOriginAirport().getAirportCode(),
                    flight.getRoute().getDestinationAirport().getAirportCode(),
                    flight.getDepartureDatetime(),
                    passenger.getFirstName().trim(),
                    passenger.getLastName().trim(),
                    row,
                    col
            );

            for (ExtraService service : chosenServices) {
                jdbcTemplate.update(
                        "INSERT INTO RESERVATIONS_EXTRA_SERVICES (RESERVATIONS_ID, EXTRA_SERVICES_ID, PASSENGER_ID) VALUES (?, ?, ?)",
                        reservationId,
                        service.getId(),
                        passengerId
                );
            }
            createdSeats.add(passenger.getSeatLabel().trim().toUpperCase());
            occupied.add(passenger.getSeatLabel().trim().toUpperCase());
        }

        jdbcTemplate.update(
                "UPDATE FLIGHTS SET BOOKED_SEATS_COUNT = NVL(BOOKED_SEATS_COUNT,0) + ? WHERE ID = ?",
                passengerCount,
                flight.getId()
        );

        return new ReservationConfirmationDTO(
                reservationId,
                flight.getId(),
                passengerCount,
                totalAmount,
                createdSeats,
                "Reservation completed successfully"
        );
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
