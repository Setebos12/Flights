package com.example.flights_app.repository;

import com.example.flights_app.model.Airport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AirportRepository extends JpaRepository<Airport, Long> {

    List<Airport> findAllByOrderByAirportNameAsc();
}