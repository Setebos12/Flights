package com.example.flights_app.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "CURRENCY")
@Data
public class Currency {

    @Id
    @Column(name = "CODE")
    private String code;
}