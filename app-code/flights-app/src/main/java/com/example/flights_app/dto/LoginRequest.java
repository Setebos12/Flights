package com.example.flights_app.dto;

import lombok.Data;

@Data
public class LoginRequest {
    private String email;
    private String password;
}