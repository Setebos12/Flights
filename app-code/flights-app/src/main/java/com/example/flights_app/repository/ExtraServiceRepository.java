package com.example.flights_app.repository;

import com.example.flights_app.model.ExtraService;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ExtraServiceRepository extends JpaRepository<ExtraService, Long> {
}
