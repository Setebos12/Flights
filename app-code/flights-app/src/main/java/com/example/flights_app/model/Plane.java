package com.example.flights_app.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "PLANES")
@Data
public class Plane {

    @Id
    @Column(name = "SERIAL_NUMBER")
    private Long serialNumber;

    @Column(name = "MODEL")
    private String model;

    @Column(name = "SEAT_COUNT")
    private Integer seatCount;

    @Column(name = "LOAD_CAPACITY")
    private Integer loadCapacity;

    @Column(name = "FUEL_CAPACITY")
    private Integer fuelCapacity;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "AIRLINES_ID")
    private Airline airline;
}