CREATE INDEX airports_name_idx ON airports (airport_name);

-- możliwe filtrowanie po: lotniskach, dacie odlotu, cenie
CREATE INDEX flight_date_price_idx ON flights(departure_date_time, price);
CREATE INDEX flight_price_idx ON flights(price);

CREATE INDEX flight_airlines_idx ON flights(airlines_id);
CREATE INDEX flight_serial_number_idx ON flights(serial_number);
CREATE INDEX flight_route_idx ON flights(routes_id);

CREATE INDEX routes_dest_idx ON routes(destination_airport_id);

CREATE INDEX airports_city_idx ON airports(city_id);

CREATE INDEX city_country_idx ON city(country_id);

CREATE INDEX countries_timezome_idx ON country(time_zone_id);

CREATE INDEX seats_seat_type_idx ON seats(seat_type_id);
CREATE INDEX seats_class_idx ON seats(class_id);
CREATE INDEX seats_serial_nr ON seats(serial_number);

CREATE INDEX reservations_users_idx ON reservations(user_id);
CREATE INDEX reservations_flights_idx ON reservations(flights_id);

CREATE INDEX payments_reservations_idx ON payments(reservations_id);

-- PRIMARY KEY (seats_id, serial_number, reservations_id, passengers_id) warto dodać indeksy na inne kombinacje
CREATE INDEX boarding_pass_lookup_idx ON boarding_pass(reservations_id, seats_id, serial_number);
CREATE INDEX boarding_pass_passenger_idx ON boarding_pass(passengers_id, reservations_id);

CREATE OR REPLACE VIEW v_flight_search AS
SELECT
    f.*,
    TRUNC(f.departure_date_time) AS departure_date, -- obliczenia pod zapytania aplikacji
    r.id AS route_id,
    oa.airport_code AS origin_airport_code,
    oa.airport_name AS origin_airport_name,
    da.airport_code AS destination_airport_code,
    da.airport_name AS destination_airport_name
FROM
    flights f
INNER JOIN routes r ON r.id = f.routes_id
INNER JOIN airports oa ON oa.id = r.origin_airport_id
INNER JOIN airports da ON da.id = r.destination_airport_id;

CREATE OR REPLACE VIEW v_flight_seats AS
SELECT
    f.id AS flights_id,
    s.row_nr,
    s.column_nr,
    st.type AS type_name,
    c.type AS class_name,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM boarding_pass bp
            JOIN reservations r ON bp.reservations_id = r.id
            WHERE r.flights_id = f.id
              AND bp.seats_id = s.id
              AND bp.serial_number = s.serial_number
        ) THEN 'occupied'
        ELSE 'available'
    END AS status
FROM flights f
JOIN seats s ON f.serial_number = s.serial_number
LEFT JOIN seat_type st ON s.seat_type_id = st.id
LEFT JOIN class c ON s.class_id = c.id;

-- ── Indeksy analityczne ──────────────────────────────────────────────────────

-- Filtrowanie po roku/miesiącu odlotu w v_flight_occupancy
-- Wyrażenie odpowiada definicji kolumn dep_year / dep_month w widoku
CREATE INDEX flights_dep_year_idx ON flights (
    EXTRACT(YEAR FROM CAST(departure_date_time AS DATE))
);
CREATE INDEX flights_dep_month_idx ON flights (
    EXTRACT(MONTH FROM CAST(departure_date_time AS DATE))
);

-- Zapytania do route_statistics filtrują po (year, month) bez routes_id,
-- PK = (routes_id, year, month) nie jest wtedy optymalnie wykorzystywany
CREATE INDEX rs_year_month_idx ON route_statistics (year, month);

-- Top routes: filtr year=0, month=0 + ORDER BY total_passengers DESC
CREATE INDEX rs_alltime_passengers_idx ON route_statistics (
    year, month, total_passengers DESC
);

-- v_airline_ranking / v_route_revenue filtrują payment_status_id = 2
CREATE INDEX payments_status_idx ON payments (payment_status_id);