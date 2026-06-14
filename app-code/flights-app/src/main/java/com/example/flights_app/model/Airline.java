package com.example.flights_app.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "AIRLINES") // Oracle DB
@Data
public class Airline {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private Long id;

    @Column(name = "NAME")
    private String name;
}
