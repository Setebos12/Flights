package com.example.flights_app.controller;

import com.example.flights_app.dto.FlightResponseDTO;
import com.example.flights_app.service.FlightService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(FlightController.class)
class FlightControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private FlightService flightService;

    @Test
    void searchFlights_returnsFlightResponseDtoList() throws Exception {
        FlightResponseDTO flight = new FlightResponseDTO(
                11L,
                OffsetDateTime.parse("2026-06-15T10:00:00Z"),
                OffsetDateTime.parse("2026-06-15T14:00:00Z"),
                "WAW",
                "Warsaw Chopin",
                "Warsaw",
                "JFK",
                "John F. Kennedy",
                "New York",
                "Boeing 737",
                BigDecimal.valueOf(259.99),
                "FlyFast",
                "USD",
                120,
                180
        );

        when(flightService.searchFlights("WAW", "JFK", null, null, null))
                .thenReturn(List.of(flight));

        mockMvc.perform(get("/api/flights/search")
                        .param("originCode", "WAW")
                        .param("destinationCode", "JFK")
                        .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].originAirportCode").value("WAW"))
                .andExpect(jsonPath("$[0].destinationAirportCode").value("JFK"))
                .andExpect(jsonPath("$[0].price").value(259.99));
    }
}
