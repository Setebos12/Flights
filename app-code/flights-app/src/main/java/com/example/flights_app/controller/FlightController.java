package com.example.flights_app.controller;


import com.example.flights_app.dto.FlightResponseDTO;
import com.example.flights_app.service.FlightService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/flights")
@RequiredArgsConstructor
public class FlightController {

    private final FlightService flightService;

    @GetMapping("/search")
    public List<FlightResponseDTO> searchFlights(
            @RequestParam(required = false) String originCode,
            @RequestParam(required = false) String destinationCode,

            @RequestParam(required = false)
            // ISO.DATE => "2026-05-24" -> LocalDate(2026, 5, 24)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        return flightService.searchFlights(originCode, destinationCode, date);
    }
}
