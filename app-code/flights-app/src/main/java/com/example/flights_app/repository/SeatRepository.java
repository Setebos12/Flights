package com.example.flights_app.repository;

import com.example.flights_app.model.Seat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SeatRepository extends JpaRepository<Seat, Long> {

    interface SeatProjection {
        Long getId();
        Integer getRowNr();
        Integer getColumnNr();
        Long getSerialNumber();
        String getSeatType();
        String getClassType();
        Integer getIsBooked();
    }

    @Query(value =
        "SELECT s.id, s.row_nr, s.column_nr, s.serial_number, " +
        "st.type as seat_type, c.type as class_type, " +
        "CASE WHEN EXISTS ( " +
        "    SELECT 1 FROM boarding_pass bp " +
        "    JOIN reservations r ON bp.reservations_id = r.id " +
        "    WHERE r.flights_id = :flightId " +
        "    AND bp.seats_id = s.id AND bp.serial_number = s.serial_number " +
        ") THEN 1 ELSE 0 END as is_booked " +
        "FROM seats s " +
        "JOIN seat_type st ON s.seat_type_id = st.id " +
        "JOIN class c ON s.class_id = c.id " +
        "WHERE s.serial_number = (SELECT f.serial_number FROM flights f WHERE f.id = :flightId) " +
        "ORDER BY s.row_nr, s.column_nr",
        nativeQuery = true)
    List<SeatProjection> findSeatsForFlight(@Param("flightId") Long flightId);
}
