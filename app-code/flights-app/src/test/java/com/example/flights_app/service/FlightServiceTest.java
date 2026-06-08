package com.example.flights_app.service;

import com.example.flights_app.dto.FlightResponseDTO;
import com.example.flights_app.model.Airline;
import com.example.flights_app.model.Airport;
import com.example.flights_app.model.City;
import com.example.flights_app.model.Country;
import com.example.flights_app.model.Currency;
import com.example.flights_app.model.Flight;
import com.example.flights_app.model.Plane;
import com.example.flights_app.model.Route;
import com.example.flights_app.repository.FlightRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class FlightServiceTest {

    @Mock
    private FlightRepository flightRepository;

    @InjectMocks
    private FlightService flightService;

    @Test
    void searchFlights_returnsMappedFlightResponse() {
        Country country = new Country();
        country.setId(300L);
        country.setName("United States");

        City originCity = new City();
        originCity.setId(20L);
        originCity.setName("Warsaw");
        originCity.setCountry(country);

        City destinationCity = new City();
        destinationCity.setId(21L);
        destinationCity.setName("New York");
        destinationCity.setCountry(country);

        Airport originAirport = new Airport();
        originAirport.setId(2L);
        originAirport.setAirportCode("WAW");
        originAirport.setAirportName("Warsaw Chopin");
        originAirport.setCity(originCity);

        Airport destinationAirport = new Airport();
        destinationAirport.setId(3L);
        destinationAirport.setAirportCode("JFK");
        destinationAirport.setAirportName("John F. Kennedy");
        destinationAirport.setCity(destinationCity);

        Route route = new Route();
        route.setId(5L);
        route.setOriginAirport(originAirport);
        route.setDestinationAirport(destinationAirport);

        Plane plane = new Plane();
        plane.setSerialNumber(1000L);
        plane.setModel("Boeing 737");

        Airline airline = new Airline();
        airline.setId(15L);
        airline.setName("FlyFast");

        Currency currency = new Currency();
        currency.setCode("USD");

        Flight flight = new Flight();
        flight.setId(11L);
        flight.setDepartureDatetime(OffsetDateTime.of(2026, 6, 15, 10, 0, 0, 0, ZoneOffset.UTC));
        flight.setArrivalDatetime(OffsetDateTime.of(2026, 6, 15, 14, 0, 0, 0, ZoneOffset.UTC));
        flight.setRoute(route);
        flight.setPlane(plane);
        flight.setPrice(BigDecimal.valueOf(259.99));
        flight.setAirline(airline);
        flight.setCurrency(currency);
        flight.setBookedSeatsCount(120);
        flight.setSeatCount(180);

        when(flightRepository.findFlights("WAW", "JFK", LocalDate.of(2026, 6, 15), BigDecimal.valueOf(200), BigDecimal.valueOf(300)))
                .thenReturn(List.of(flight));

        List<FlightResponseDTO> result = flightService.searchFlights(
                "WAW", "JFK", LocalDate.of(2026, 6, 15), BigDecimal.valueOf(200), BigDecimal.valueOf(300)
        );

        assertThat(result).hasSize(1);
        FlightResponseDTO dto = result.get(0);
        assertThat(dto.getOriginAirportCode()).isEqualTo("WAW");
        assertThat(dto.getDestinationAirportCode()).isEqualTo("JFK");
        assertThat(dto.getPlaneModel()).isEqualTo("Boeing 737");
        assertThat(dto.getPrice()).isEqualByComparingTo("259.99");
        assertThat(dto.getAirlineName()).isEqualTo("FlyFast");
        assertThat(dto.getCurrencyCode()).isEqualTo("USD");
        assertThat(dto.getBookedSeatsCount()).isEqualTo(120);
        assertThat(dto.getSeatCount()).isEqualTo(180);
    }
}
