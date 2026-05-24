package com.example.flights_app.repository;

import com.example.flights_app.model.Flight;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public interface FlightRepository extends JpaRepository<Flight, Long> {

    @Query(value = """
    SELECT f.* FROM flights f
    JOIN routes r ON r.id = f.routes_id
    JOIN airports oa ON oa.id = r.origin_airport_id
    JOIN airports da ON da.id = r.destination_airport_id
    WHERE (:originCode IS NULL OR oa.airport_code = :originCode)
    AND (:destinationCode IS NULL OR da.airport_code = :destinationCode)
    AND (:date IS NULL OR TRUNC(f.departure_date_time) = :date)
    AND (:minPrice IS NULL OR f.price >= :minPrice)
    AND (:maxPrice IS NULL OR f.price <= :maxPrice)
    ORDER BY f.departure_date_time ASC
""", nativeQuery = true)
    // cast na date bez godziny i strefy czasowej
    // opcja sortowania po kwocie
    List<Flight> findFlights(
            @Param("originCode") String originCode,
            @Param("destinationCode") String destinationCode,
            @Param("date") LocalDate date,
            @Param("minPrice") BigDecimal minPrice,
            @Param("maxPrice") BigDecimal maxPrice
    );
}
