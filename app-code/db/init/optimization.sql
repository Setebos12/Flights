CREATE INDEX airports_code_idx ON airports (airport_code);
CREATE INDEX airports_name_idx ON airports (name);

CREATE INDEX user_email_idx ON users (email);

-- możliwe filtrowanie po: lotniskach, dacie odlotu, cenie
CREATE INDEX flight_date_idx ON flights(departure_date_time, price);
CREATE INDEX flight_price_idx ON flights(price);

CREATE INDEX flight_airlines_idx ON flights(airlines_id);
CREATE INDEX flight_serial_number_idx ON flights(serial_number);
CREATE INDEX flight_route_idx ON flights(route_id);

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