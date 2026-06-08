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
import static org.junit.jupiter.api.Assertions.assertThrows;

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

    @Test
    void searchFlights_mapsZeroPriceCorrectly() {
        Flight flight = new Flight();
        flight.setId(21L);
        flight.setPrice(BigDecimal.ZERO);

        Route route = new Route();
        Airport a1 = new Airport(); a1.setAirportCode("AAA"); a1.setAirportName("A1"); City c1 = new City(); c1.setName("C1"); a1.setCity(c1);
        Airport a2 = new Airport(); a2.setAirportCode("BBB"); a2.setAirportName("B1"); City c2 = new City(); c2.setName("C2"); a2.setCity(c2);
        route.setOriginAirport(a1); route.setDestinationAirport(a2);
        flight.setRoute(route);

        Plane plane = new Plane();
        plane.setSerialNumber(555L);
        plane.setModel("TestPlane");
        flight.setPlane(plane);
        Airline airline = new Airline();
        airline.setId(99L);
        airline.setName("ZeroAir");
        flight.setAirline(airline);
        Currency currency = new Currency();
        currency.setCode("USD");
        flight.setCurrency(currency);

        when(flightRepository.findFlights(null, null, null, null, null)).thenReturn(List.of(flight));

        List<FlightResponseDTO> result = flightService.searchFlights(null, null, null, null, null);
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getPrice()).isEqualByComparingTo("0");
    }

    @Test
    void searchFlights_preservesBookedSeatsEvenIfExceedsCapacity() {
        Flight flight = new Flight();
        flight.setId(22L);
        flight.setBookedSeatsCount(250);
        flight.setSeatCount(200);

        Route route = new Route();
        Airport a1 = new Airport(); a1.setAirportCode("CCC"); a1.setAirportName("C1"); City c1 = new City(); c1.setName("C1"); a1.setCity(c1);
        Airport a2 = new Airport(); a2.setAirportCode("DDD"); a2.setAirportName("D1"); City c2 = new City(); c2.setName("C2"); a2.setCity(c2);
        route.setOriginAirport(a1); route.setDestinationAirport(a2);
        flight.setRoute(route);

        Plane plane = new Plane();
        plane.setSerialNumber(556L);
        plane.setModel("OversellPlane");
        flight.setPlane(plane);
        Airline airline = new Airline();
        airline.setId(100L);
        airline.setName("OversellAir");
        flight.setAirline(airline);
        Currency currency = new Currency();
        currency.setCode("USD");
        flight.setCurrency(currency);

        when(flightRepository.findFlights(null, null, null, null, null)).thenReturn(List.of(flight));

        List<FlightResponseDTO> result = flightService.searchFlights(null, null, null, null, null);
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getBookedSeatsCount()).isEqualTo(250);
        assertThat(result.get(0).getSeatCount()).isEqualTo(200);
    }
}
