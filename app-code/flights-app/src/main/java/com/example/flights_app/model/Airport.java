package com.example.flights_app.model;

import jakarta.persistence.*;

import lombok.Data;

@Entity
@Table(name = "AIRPORTS")
@Data
public class Airport {

    @Id
    @Column(name = "ID")
    private Long id;

    @Column(name = "AIRPORT_NAME")
    private String airportName;

    @Column(name = "AIRPORT_CODE")
    private String airportCode;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CITY_ID")
    private City city;

}
