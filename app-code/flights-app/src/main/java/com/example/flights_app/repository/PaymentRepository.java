package com.example.flights_app.repository;

import com.example.flights_app.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {

    @Query(value = "SELECT NVL(MAX(id), 0) + 1 FROM PAYMENTS", nativeQuery = true)
    Long getNextId();
}
