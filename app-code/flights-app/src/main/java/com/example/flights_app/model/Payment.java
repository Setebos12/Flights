package com.example.flights_app.model;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "PAYMENTS")
@Data
public class Payment {

    @Id
    @Column(name = "ID")
    private Long id;

    @Column(name = "PAYMENT_DATE")
    private LocalDate paymentDate;

    @Column(name = "PAYMENT_STATUS_ID")
    private Long paymentStatusId;

    @Column(name = "PAYMENT_AMOUNT")
    private BigDecimal paymentAmount;

    @Column(name = "CURRENCY_CODE")
    private String currencyCode;

    @Column(name = "RESERVATIONS_ID")
    private Long reservationsId;
}
