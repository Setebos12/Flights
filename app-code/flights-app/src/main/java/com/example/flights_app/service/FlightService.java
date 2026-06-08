package com.example.flights_app.service;

import com.example.flights_app.dto.FlightResponseDTO;
import com.example.flights_app.model.Flight;
import com.example.flights_app.repository.FlightRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FlightService {

    private final FlightRepository flightRepository;

    private FlightResponseDTO toDTO(Flight f) {
        return new FlightResponseDTO(
                f.getId(),
                f.getDepartureDatetime(),
                f.getArrivalDatetime(),

                f.getRoute().getOriginAirport().getAirportCode(),
                f.getRoute().getOriginAirport().getAirportName(),
                f.getRoute().getOriginAirport().getCity().getName(),

                f.getRoute().getDestinationAirport().getAirportCode(),
                f.getRoute().getDestinationAirport().getAirportName(),
                f.getRoute().getDestinationAirport().getCity().getName(),

                f.getPlane().getModel(),
                f.getPrice(),
                f.getAirline().getName(),
                f.getCurrency().getCode(),
                f.getBookedSeatsCount(),
                f.getSeatCount(),
                calculateAvailableSeats(f)
        );
    }

    private Integer calculateAvailableSeats(Flight f) {
        if (f.getSeatCount() == null) {
            return null;
        }
        int booked = f.getBookedSeatsCount() != null ? f.getBookedSeatsCount() : 0;
        int available = f.getSeatCount() - booked;
        return available >= 0 ? available : 0;
    }

    public List<FlightResponseDTO> searchFlights(
            String originCode,
            String destinationCode,
            LocalDate date,
            BigDecimal minPrice,
            BigDecimal maxPrice
    ){
        List<Flight> flights = flightRepository.findFlights(originCode, destinationCode, date, minPrice, maxPrice);

        return flights.stream()
                .map(this::toDTO)
                .toList();
    }
}
