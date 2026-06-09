package com.example.flights_app.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "SEATS")
@Data
public class Seat {

    @Id
    @Column(name = "ID")
    private Long id;

    @Column(name = "ROW_NR")
    private Integer rowNr;

    @Column(name = "COLUMN_NR")
    private Integer colNr;

    @Column(name = "SERIAL_NUMBER")
    private Long serialNumber;

    @Column(name = "SEAT_TYPE_ID")
    private Long seatTypeId;

    @Column(name = "CLASS_ID")
    private Long classId;
}
