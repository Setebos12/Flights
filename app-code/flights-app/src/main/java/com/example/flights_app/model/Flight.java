package com.example.flights_app.model;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Entity
@Table(name = "FLIGHTS")
@Data
public class Flight {

    @Id
    @Column(name = "ID")
    private Long id;

    @Column(name = "DEPARTURE_DATE_TIME")
    private OffsetDateTime departureDatetime;   // data i czas ze strefa np. 2026-06-01 10:00 +02:00

    @Column(name = "ARRIVAL_DATE_TIME")
    private OffsetDateTime arrivalDatetime;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ROUTES_ID")
    private Route route;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "SERIAL_NUMBER")
    private Plane plane;

    @Column(name = "PRICE")
    private BigDecimal price;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "AIRLINES_ID")
    private Airline airline;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CURRENCY_ID")
    private Currency currency;

    @Column(name = "BOOKED_SEATS_COUNT")
    private Integer bookedSeatsCount;

    @Column(name = "P_SEAT_COUNT")
    private Integer seatCount;

}