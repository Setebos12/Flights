package com.example.flights_app.service;

import com.example.flights_app.dto.AirportResponseDTO;
import com.example.flights_app.model.Airport;
import com.example.flights_app.repository.AirportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AirportService {

    private final AirportRepository airportRepository;

    private AirportResponseDTO toDTO(Airport a) {
        return new AirportResponseDTO(
                a.getId(),
                a.getAirportCode(),
                a.getAirportName(),
                a.getCity().getName(),
                a.getCity().getCountry().getName()
        );
    }

    public List<AirportResponseDTO> getAllAirports() {
        List<Airport> airports = airportRepository.findAllByOrderByAirportNameAsc();

        return airports.stream()
                .map(this::toDTO)
                .toList();
    }
}