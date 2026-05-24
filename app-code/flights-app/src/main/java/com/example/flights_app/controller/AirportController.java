package com.example.flights_app.controller;

import com.example.flights_app.dto.AirportResponseDTO;
import com.example.flights_app.service.AirportService;
import com.example.flights_app.service.FlightService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/airports")
@RequiredArgsConstructor
public class AirportController {

    private final AirportService airportService;

    @GetMapping
    public List<AirportResponseDTO> getAirports(){
        return airportService.getAllAirports();
    }
}
