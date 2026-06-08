package com.example.flights_app.controller;

import com.example.flights_app.dto.AirportResponseDTO;
import com.example.flights_app.service.AirportService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.hamcrest.Matchers.hasSize;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(AirportController.class)
class AirportControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private AirportService airportService;

    @Test
    void getAirports_returnsAirportDtoList() throws Exception {
        AirportResponseDTO airport = new AirportResponseDTO(
                1L,
                "WAW",
                "Warsaw Chopin",
                "Warsaw",
                "Poland"
        );

        when(airportService.getAllAirports()).thenReturn(List.of(airport));

        mockMvc.perform(get("/api/airports").accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].airportCode").value("WAW"))
                .andExpect(jsonPath("$[0].cityName").value("Warsaw"));
    }
}
