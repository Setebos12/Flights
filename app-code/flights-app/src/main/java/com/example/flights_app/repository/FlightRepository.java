package com.example.flights_app.repository;

import com.example.flights_app.model.Flight;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface FlightRepository extends JpaRepository<Flight, Long> {

    @Query("""
        SELECT f FROM Flight f
        JOIN f.route r
        JOIN r.originAirport oa
        JOIN r.destinationAirport da
        WHERE (:originCode IS NULL OR oa.airportCode = :originCode)
        AND (:destinationCode IS NULL OR da.airportCode = :destinationCode)
        AND (:date IS NULL OR
            (EXTRACT(YEAR FROM f.departureDatetime) = YEAR(:date)
            AND EXTRACT(MONTH FROM f.departureDatetime) = MONTH(:date)
            AND EXTRACT(DAY FROM f.departureDatetime) = DAY(:date)))
    """)
    // cast na date bez godziny i strefy czasowej
    List<Flight> findFlights(
            @Param("originCode") String originCode,
            @Param("destinationCode") String destinationCode,
            @Param("date") LocalDate date
    );
}
