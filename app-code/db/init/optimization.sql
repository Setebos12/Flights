CREATE INDEX airports_name_idx ON airports (airport_name);

CREATE INDEX user_email_idx ON users (email_address);

-- możliwe filtrowanie po: lotniskach, dacie odlotu, cenie
CREATE INDEX flight_date_idx ON flights(departure_date_time, price);
CREATE INDEX flight_price_idx ON flights(price);

CREATE INDEX flight_airlines_idx ON flights(airlines_id);
CREATE INDEX flight_serial_number_idx ON flights(serial_number);
CREATE INDEX flight_route_idx ON flights(routes_id);

CREATE INDEX routes_origin_idx ON routes(origin_airport_id);
CREATE INDEX routes_dest_idx ON routes(destination_airport_id);

CREATE INDEX airports_city_idx ON airports(city_id);

CREATE INDEX city_country_idx ON city(country_id);

CREATE INDEX countries_timezome_idx ON country(time_zone_id);

CREATE INDEX seats_seat_type_idx ON seats(seat_type_id);
CREATE INDEX seats_class_idx ON seats(class_id);

CREATE INDEX reservations_users_idx ON reservations(user_id);
CREATE INDEX reservations_flights_idx ON reservations(flights_id);

CREATE INDEX payments_reservations_idx ON payments(reservations_id);

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