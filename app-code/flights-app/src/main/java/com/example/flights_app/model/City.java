package com.example.flights_app.model;


import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "CITY")
@Data
public class City {

    @Id
    @Column(name = "ID")
    private Long id;

    @Column(name = "NAME")
    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "COUNTRY_ID")
    private Country country;
}
