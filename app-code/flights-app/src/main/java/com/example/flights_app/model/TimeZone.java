package com.example.flights_app.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "TIME_ZONE")
@Data
public class TimeZone {

    @Id
    @Column(name = "ID")
    private Long id;

    @Column(name = "CODE")
    private String code;

    @Column(name = "UTC_DIFFERENCE")
    private Integer utcDifference;
}