package com.example.flights_app.repository;

import com.example.flights_app.dto.SeatDTO;
import com.example.flights_app.model.Flight;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public interface FlightRepository extends JpaRepository<Flight, Long> {

    @Query(value = """
        SELECT * FROM v_flight_search
        WHERE (:originCode IS NULL OR origin_airport_code = :originCode)
        AND (:destinationCode IS NULL OR destination_airport_code = :destinationCode)
        AND (CAST(:date AS DATE) IS NULL OR departure_date = :date)
        AND (:minPrice IS NULL OR price >= :minPrice)
        AND (:maxPrice IS NULL OR price <= :maxPrice)
        AND departure_date_time >= SYSDATE
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

    @Query(value = "SELECT row_nr as rowNr, column_nr as colNr, type_name as seatType, class_name as className, status " +
               "FROM v_flight_seats WHERE flights_id = :flightId ORDER BY row_nr, column_nr",
       nativeQuery = true)
    List<SeatDTO> findSeatsByFlightId(
        @Param("flightId") Long flightId
    );
}
