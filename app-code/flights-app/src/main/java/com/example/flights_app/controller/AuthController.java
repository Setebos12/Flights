package com.example.flights_app.controller;

import com.example.flights_app.dto.AuthResponse;
import com.example.flights_app.dto.LoginRequest;
import com.example.flights_app.dto.RegisterRequest;
import com.example.flights_app.model.Passenger;
import com.example.flights_app.model.User;
import com.example.flights_app.repository.PassengerRepository;
import com.example.flights_app.repository.UserRepository;
import com.example.flights_app.service.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final UserRepository userRepository;
    private final PassengerRepository passengerRepository;
    private final PasswordEncoder passwordEncoder;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
            );

            User user = userRepository.findByEmailAddress(request.getEmail())
                    .orElseThrow(() -> new RuntimeException("User not found after authentication"));

            String token = jwtService.generateToken(request.getEmail());
            boolean isAdmin = Integer.valueOf(1).equals(user.getIsAdmin());

            return ResponseEntity.ok(new AuthResponse(token, user.getEmailAddress(), user.getId(), isAdmin));
        } catch (Exception e) {
            return ResponseEntity.status(401).body("Invalid email or password");
        }
    }

    @PostMapping("/register")
    @Transactional
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        if (userRepository.findByEmailAddress(request.getEmail()).isPresent()) {
            return ResponseEntity.status(409).body("Email already in use");
        }

        Long userId = userRepository.getNextId();
        Long passengerId = passengerRepository.getNextId();

        User user = new User();
        user.setId(userId);
        user.setEmailAddress(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setIsAdmin(0);
        userRepository.save(user);

        Passenger passenger = new Passenger();
        passenger.setId(passengerId);
        passenger.setFirstName(request.getFirstName());
        passenger.setLastName(request.getLastName());
        passenger.setPhoneNumber(request.getPhoneNumber());
        passenger.setUserId(userId);
        passengerRepository.save(passenger);

        user.setPassengersId(passengerId);
        userRepository.save(user);

        String token = jwtService.generateToken(request.getEmail());
        return ResponseEntity.ok(new AuthResponse(token, user.getEmailAddress(), userId, false));
    }
}