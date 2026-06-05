package com.example.flights_app.repository;

import com.example.flights_app.model.Passenger;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface PassengerRepository extends JpaRepository<Passenger, Long> {

    @Query(value = "SELECT NVL(MAX(id), 0) + 1 FROM PASSENGERS", nativeQuery = true)
    Long getNextId();
}
