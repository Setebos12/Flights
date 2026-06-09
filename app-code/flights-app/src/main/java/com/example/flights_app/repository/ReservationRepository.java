package com.example.flights_app.repository;

import com.example.flights_app.model.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Long> {

    interface ReservationDetail {
        Long getReservationId();
        String getOriginCode();
        String getDestCode();
        String getAirlineName();
        BigDecimal getFlightPrice();
        String getCurrencyCode();
        String getDepartureDatetime();
        String getPaymentStatus();
        BigDecimal getPaymentAmount();
        Integer getSeatRow();
        Integer getSeatCol();
        String getSeatType();
        String getClassType();
    }

    @Query(value =
        "SELECT r.id as reservation_id, " +
        "a1.airport_code as origin_code, a2.airport_code as dest_code, " +
        "al.name as airline_name, f.price as flight_price, f.currency_code, " +
        "TO_CHAR(f.departure_date_time, 'YYYY-MM-DD HH24:MI') as departure_datetime, " +
        "NVL(ps.description, 'Unknown') as payment_status, " +
        "p.payment_amount, " +
        "s.row_nr as seat_row, s.column_nr as seat_col, " +
        "st.type as seat_type, c.type as class_type " +
        "FROM reservations r " +
        "JOIN flights f ON r.flights_id = f.id " +
        "JOIN routes rt ON f.routes_id = rt.id " +
        "JOIN airports a1 ON rt.origin_airport_id = a1.id " +
        "JOIN airports a2 ON rt.destination_airport_id = a2.id " +
        "JOIN airlines al ON f.airlines_id = al.id " +
        "LEFT JOIN payments p ON p.reservations_id = r.id " +
        "LEFT JOIN payment_status ps ON p.payment_status_id = ps.payment_status_id " +
        "LEFT JOIN boarding_pass bp ON bp.reservations_id = r.id " +
        "  AND bp.passengers_id = (SELECT u2.passengers_id FROM users u2 WHERE u2.id = :userId) " +
        "LEFT JOIN seats s ON bp.seats_id = s.id AND bp.serial_number = s.serial_number " +
        "LEFT JOIN seat_type st ON s.seat_type_id = st.id " +
        "LEFT JOIN class c ON s.class_id = c.id " +
        "WHERE r.user_id = :userId " +
        "ORDER BY r.id DESC",
        nativeQuery = true)
    List<ReservationDetail> findByUserId(@Param("userId") Long userId);

    @Query(value = "SELECT NVL(MAX(id), 0) + 1 FROM RESERVATIONS", nativeQuery = true)
    Long getNextId();

    @Modifying
    @Query(value = "INSERT INTO RESERVATIONS_PASSENGERS (RESERVATIONS_ID, PASSENGERS_ID) VALUES (:resId, :passId)", nativeQuery = true)
    void addPassenger(@Param("resId") Long reservationId, @Param("passId") Long passengerId);

    @Modifying
    @Query(value = "INSERT INTO RESERVATIONS_EXTRA_SERVICES (RESERVATIONS_ID, EXTRA_SERVICES_ID, PASSENGER_ID) VALUES (:resId, :serviceId, :passId)", nativeQuery = true)
    void addExtraService(@Param("resId") Long reservationId, @Param("serviceId") Long serviceId, @Param("passId") Long passengerId);

    @Modifying
    @Query(value = "INSERT INTO BOARDING_PASS (RESERVATIONS_ID, PASSENGERS_ID, SEATS_ID, SERIAL_NUMBER) VALUES (:resId, :passId, :seatId, :serialNumber)", nativeQuery = true)
    void insertBoardingPass(@Param("resId") Long reservationId, @Param("passId") Long passengerId, @Param("seatId") Long seatId, @Param("serialNumber") Long serialNumber);
}
