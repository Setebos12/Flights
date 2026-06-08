package com.example.flights_app.service;

import com.example.flights_app.dto.AirportResponseDTO;
import com.example.flights_app.model.Airport;
import com.example.flights_app.model.City;
import com.example.flights_app.model.Country;
import com.example.flights_app.repository.AirportRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AirportServiceTest {

    @Mock
    private AirportRepository airportRepository;

    @InjectMocks
    private AirportService airportService;

    @Test
    void getAllAirports_returnsOrderedDtoList() {
        Country country = new Country();
        country.setId(100L);
        country.setName("Poland");

        City city = new City();
        city.setId(10L);
        city.setName("Warsaw");
        city.setCountry(country);

        Airport airport = new Airport();
        airport.setId(1L);
        airport.setAirportCode("WAW");
        airport.setAirportName("Warsaw Chopin");
        airport.setCity(city);

        when(airportRepository.findAllByOrderByAirportNameAsc()).thenReturn(List.of(airport));

        List<AirportResponseDTO> result = airportService.getAllAirports();

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getAirportCode()).isEqualTo("WAW");
        assertThat(result.get(0).getAirportName()).isEqualTo("Warsaw Chopin");
        assertThat(result.get(0).getCityName()).isEqualTo("Warsaw");
        assertThat(result.get(0).getCountryName()).isEqualTo("Poland");
    }
}
