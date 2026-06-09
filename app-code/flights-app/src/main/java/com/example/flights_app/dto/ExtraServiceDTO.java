package com.example.flights_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.math.BigDecimal;

@Data
@AllArgsConstructor
public class ExtraServiceDTO {
    private Long id;
    private String name;
    private BigDecimal price;
}
