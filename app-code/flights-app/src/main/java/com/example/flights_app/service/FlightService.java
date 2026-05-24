package com.example.flights_app.service;

import com.example.flights_app.dto.FlightResponseDTO;
import com.example.flights_app.model.Flight;
import com.example.flights_app.repository.FlightRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

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
                f.getSeatCount()
        );
    }

    public List<FlightResponseDTO> searchFlights(
            String originCode,
            String destinationCode,
            LocalDate date
    ){
        List<Flight> flights = flightRepository.findFlights(originCode, destinationCode, date);

        return flights.stream()
                .map(this::toDTO)
                .toList();
    }
}
