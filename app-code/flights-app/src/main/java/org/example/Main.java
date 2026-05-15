package org.example;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class Main {
    public static void main(String[] args) {
        String url = System.getenv("DB_URL");
        String user = System.getenv("DB_USER");
        String password = System.getenv("DB_PASSWORD");

        System.out.println("Łączenie z bazą danych...");

        try (Connection conn = DriverManager.getConnection(url, user, password);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT 'Połączono!' FROM dual")) {

            if (rs.next()) {
                System.out.println(rs.getString(1));
            }

        } catch (Exception e) {
            System.err.println("Błąd połączenia: " + e.getMessage());
        }
    }
}