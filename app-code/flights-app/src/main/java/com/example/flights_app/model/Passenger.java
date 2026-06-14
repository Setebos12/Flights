package com.example.flights_app.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "PASSENGERS")
@Data
public class Passenger {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private Long id;

    @Column(name = "FIRST_NAME")
    private String firstName;

    @Column(name = "LAST_NAME")
    private String lastName;

    @Column(name = "PHONE_NUMBER")
    private String phoneNumber;

    @Column(name = "USER_ID")
    private Long userId;
}
