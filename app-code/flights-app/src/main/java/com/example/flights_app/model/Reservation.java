package com.example.flights_app.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;

@Entity
@Table(name = "RESERVATIONS")
@Data
public class Reservation {

    @Id
    @Column(name = "ID")
    private Long id;

    @Column(name = "RESERVATION_DATE")
    private LocalDate reservationDate;

    @Column(name = "NUMBER_IN_PARTY")
    private Integer numberInParty;

    @Column(name = "USER_ID")
    private Long userId;

    @Column(name = "FLIGHTS_ID")
    private Long flightsId;
}
