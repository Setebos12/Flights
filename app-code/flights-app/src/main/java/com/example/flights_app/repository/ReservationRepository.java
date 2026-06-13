package com.example.flights_app.repository;

import com.example.flights_app.model.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Long> {

    @Procedure(procedureName = "create_reservation", outputParameterName = "p_new_reservation_id")
    Long createReservation(
            @Param("p_user_id") Long userId,
            @Param("p_flight_id") Long flightId,
            @Param("p_passenger_count") Integer passengerCount
    );

    @Procedure(procedureName = "add_passenger_and_boarding_pass", outputParameterName = "p_new_passenger_id")
    Long addPassengerAndBoardingPass(
            @Param("p_reservation_id") Long reservationId,
            @Param("p_flight_id") Long flightId,
            @Param("p_first_name") String firstName,
            @Param("p_last_name") String lastName,
            @Param("p_seat_row") Integer seatRow,
            @Param("p_seat_col") Integer seatCol
    );

    @Procedure(procedureName = "cancel_reservation")
    void cancelReservation(
            @Param("p_reservation_id") Long reservationId,
            @Param("p_user_id") Long userId
    );

        @Procedure(procedureName = "pay_for_reservation")
    void payReservation(
            @Param("p_reservation_id") Long reservationId,
            @Param("p_user_id") Long userId
    );
}