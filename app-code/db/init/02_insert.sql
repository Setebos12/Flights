ALTER TRIGGER payment_calculation ENABLE;
ALTER TRIGGER prejoin_payments ENABLE;
ALTER TRIGGER prejoin_flights ENABLE;
ALTER TRIGGER prejoin_flights_currency ENABLE;
ALTER TRIGGER prejoin_flights_seat_count ENABLE;
ALTER TRIGGER prejoin_boarding_pass ENABLE;
ALTER TRIGGER flights_booked_seats_I ENABLE;
ALTER TRIGGER flights_booked_seats_D ENABLE;
ALTER TRIGGER flights_booked_seats_U ENABLE;
ALTER TRIGGER route_statistics_count_passengers_I ENABLE;
ALTER TRIGGER route_statistics_count_revenue_I ENABLE;
ALTER TRIGGER planes_generate_seats ENABLE;

INSERT INTO time_zone (id, code, utc_difference) VALUES (1,  'UTC',   0);
INSERT INTO time_zone (id, code, utc_difference) VALUES (2,  'CET',   1);
INSERT INTO time_zone (id, code, utc_difference) VALUES (3,  'EET',   2);
INSERT INTO time_zone (id, code, utc_difference) VALUES (4,  'GMT',   0);
INSERT INTO time_zone (id, code, utc_difference) VALUES (5,  'EST',  -5);
INSERT INTO time_zone (id, code, utc_difference) VALUES (6,  'CST',  -6);
INSERT INTO time_zone (id, code, utc_difference) VALUES (7,  'MSK',   3);
INSERT INTO time_zone (id, code, utc_difference) VALUES (8,  'IST',   5);
INSERT INTO time_zone (id, code, utc_difference) VALUES (9,  'JST',   9);
INSERT INTO time_zone (id, code, utc_difference) VALUES (10, 'AEST', 10);


INSERT INTO country (id, name, time_zone_id) VALUES (1,  'Poland',         2);
INSERT INTO country (id, name, time_zone_id) VALUES (2,  'Germany',        2);
INSERT INTO country (id, name, time_zone_id) VALUES (3,  'France',         2);
INSERT INTO country (id, name, time_zone_id) VALUES (4,  'United Kingdom', 4);
INSERT INTO country (id, name, time_zone_id) VALUES (5,  'United States',  5);
INSERT INTO country (id, name, time_zone_id) VALUES (6,  'Netherlands',    2);
INSERT INTO country (id, name, time_zone_id) VALUES (7,  'Spain',          2);
INSERT INTO country (id, name, time_zone_id) VALUES (8,  'Italy',          2);
INSERT INTO country (id, name, time_zone_id) VALUES (9,  'Russia',         7);
INSERT INTO country (id, name, time_zone_id) VALUES (10, 'Japan',          9);


INSERT INTO city (id, name, country_id) VALUES (1,  'Warsaw',      1);
INSERT INTO city (id, name, country_id) VALUES (2,  'Krakow',      1);
INSERT INTO city (id, name, country_id) VALUES (3,  'Gdansk',      1);
INSERT INTO city (id, name, country_id) VALUES (4,  'Berlin',      2);
INSERT INTO city (id, name, country_id) VALUES (5,  'Munich',      2);
INSERT INTO city (id, name, country_id) VALUES (6,  'Paris',       3);
INSERT INTO city (id, name, country_id) VALUES (7,  'London',      4);
INSERT INTO city (id, name, country_id) VALUES (8,  'New York',    5);
INSERT INTO city (id, name, country_id) VALUES (9,  'Amsterdam',   6);
INSERT INTO city (id, name, country_id) VALUES (10, 'Madrid',      7);
INSERT INTO city (id, name, country_id) VALUES (11, 'Rome',        8);
INSERT INTO city (id, name, country_id) VALUES (12, 'Moscow',      9);
INSERT INTO city (id, name, country_id) VALUES (13, 'Tokyo',       10);
INSERT INTO city (id, name, country_id) VALUES (14, 'Barcelona',   7);
INSERT INTO city (id, name, country_id) VALUES (15, 'Wroclaw',     1);


INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (1,  'Warsaw Chopin Airport',                 'WAW', 1);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (2,  'Krakow John Paul II International',     'KRK', 2);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (3,  'Gdansk Lech Walesa Airport',            'GDN', 3);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (4,  'Berlin Brandenburg Airport',            'BER', 4);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (5,  'Munich Airport',                        'MUC', 5);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (6,  'Paris Charles de Gaulle Airport',       'CDG', 6);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (7,  'London Heathrow Airport',               'LHR', 7);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (8,  'John F. Kennedy International Airport', 'JFK', 8);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (9,  'Amsterdam Airport Schiphol',            'AMS', 9);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (10, 'Adolfo Suarez Madrid-Barajas Airport',  'MAD', 10);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (11, 'Leonardo da Vinci International',       'FCO', 11);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (12, 'Sheremetyevo International Airport',    'SVO', 12);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (13, 'Tokyo Narita International Airport',    'NRT', 13);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (14, 'Barcelona El Prat Airport',             'BCN', 14);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (15, 'Wroclaw Copernicus Airport',            'WRO', 15);


INSERT INTO currency (code) VALUES ('PLN');
INSERT INTO currency (code) VALUES ('EUR');
INSERT INTO currency (code) VALUES ('GBP');
INSERT INTO currency (code) VALUES ('USD');
INSERT INTO currency (code) VALUES ('JPY');


INSERT INTO airlines (id, name) VALUES (1,  'LOT Polish Airlines');
INSERT INTO airlines (id, name) VALUES (2,  'Lufthansa');
INSERT INTO airlines (id, name) VALUES (3,  'Air France');
INSERT INTO airlines (id, name) VALUES (4,  'British Airways');
INSERT INTO airlines (id, name) VALUES (5,  'KLM Royal Dutch Airlines');
INSERT INTO airlines (id, name) VALUES (6,  'Ryanair');
INSERT INTO airlines (id, name) VALUES (7,  'Wizz Air');
INSERT INTO airlines (id, name) VALUES (8,  'easyJet');
INSERT INTO airlines (id, name) VALUES (9,  'Iberia');
INSERT INTO airlines (id, name) VALUES (10, 'Alitalia');


INSERT INTO class (id, type) VALUES (1, 'Economy');
INSERT INTO class (id, type) VALUES (2, 'Premium Economy');
INSERT INTO class (id, type) VALUES (3, 'Business');
INSERT INTO class (id, type) VALUES (4, 'First Class');

INSERT INTO seat_type (id, type) VALUES (1, 'Window');
INSERT INTO seat_type (id, type) VALUES (2, 'Middle');
INSERT INTO seat_type (id, type) VALUES (3, 'Aisle');


INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, airlines_id)
VALUES (1001, 'Boeing 737-800', 189, 9900, 26020, 6);

INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, airlines_id)
VALUES (1002, 'Airbus A320', 78, 9500, 26730, 7);

INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, airlines_id)
VALUES (1003, 'Boeing 787-9', 103, 9900, 56217, 1);

INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, airlines_id)
VALUES (1004, 'Airbus A321neo', 100, 9900, 32940, 2);

INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, airlines_id)
VALUES (1005, 'Boeing 767-300ER', 99, 9900, 63216, 3);

INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, airlines_id)
VALUES (1006, 'Airbus A380-800', 49, 9999, 86671, 4);

INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, airlines_id)
VALUES (1007, 'Embraer E195', 117, 7000, 13984, 5);

INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, airlines_id)
VALUES (1008, 'Boeing 737 MAX 8', 71, 9900, 25816, 6);

INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, airlines_id)
VALUES (1009, 'Airbus A319', 35, 8500, 26730, 8);

INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, airlines_id)
VALUES (1010, 'Boeing 777-300ER', 109, 9999, 99679, 4);




INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (1,  1,  4);
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (2,  1,  6);
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (3,  1,  7);
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (4,  1,  9);
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (5,  1,  8);
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (6,  4,  1);
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (7,  6,  1);
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (8,  7,  1);
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (9,  2,  6);
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (10, 2,  4);
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (11, 3,  9);
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (12, 6,  7);
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (13, 7,  8);
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (14, 9,  13);
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (15, 1,  11);


INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, currency_code)
    VALUES (1,  TIMESTAMP '2026-06-01 06:00:00 +02:00', TIMESTAMP '2026-06-01 07:45:00 +02:00', 1,  1001, 299.00,  'EUR');

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, currency_code)
    VALUES (2,  TIMESTAMP '2026-06-01 10:30:00 +02:00', TIMESTAMP '2026-06-01 12:45:00 +02:00', 2,  1002, 349.00,  'EUR');

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, currency_code)
    VALUES (3,  TIMESTAMP '2026-06-02 08:00:00 +02:00', TIMESTAMP '2026-06-02 10:15:00 +01:00', 3,  1001, 420.00,  'GBP');

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, currency_code)
    VALUES (4,  TIMESTAMP '2026-06-03 14:00:00 +02:00', TIMESTAMP '2026-06-03 16:00:00 +02:00', 4,  1002, 279.00,  'USD');

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, currency_code)
    VALUES (5,  TIMESTAMP '2026-06-05 21:00:00 +02:00', TIMESTAMP '2026-06-06 00:30:00 -05:00', 5,  1003, 1250.00,  'USD');

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, currency_code)
    VALUES (6,  TIMESTAMP '2026-06-07 09:00:00 +02:00', TIMESTAMP '2026-06-07 10:50:00 +02:00', 6,  1004, 310.00,  'EUR');

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, currency_code)
    VALUES (7,  TIMESTAMP '2026-06-08 13:00:00 +02:00', TIMESTAMP '2026-06-08 15:20:00 +02:00', 7,  1005, 380.00,  'EUR');

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, currency_code)
    VALUES (8,  TIMESTAMP '2026-06-10 07:30:00 +01:00', TIMESTAMP '2026-06-10 11:45:00 +02:00', 8,  1002, 395.00,  'EUR');

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, currency_code)
    VALUES (9,  TIMESTAMP '2026-06-12 06:15:00 +02:00', TIMESTAMP '2026-06-12 09:00:00 +02:00', 9,  1007, 220.00,  'EUR');

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, currency_code)
    VALUES (10, TIMESTAMP '2026-06-15 16:00:00 +02:00', TIMESTAMP '2026-06-15 17:45:00 +02:00', 10, 1008, 189.00,  'EUR');

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, currency_code)
    VALUES (11, TIMESTAMP '2026-06-20 11:00:00 +02:00', TIMESTAMP '2026-06-20 13:30:00 +02:00', 11, 1009, 259.00,  'EUR');

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, currency_code)
    VALUES (12, TIMESTAMP '2026-06-22 08:45:00 +02:00', TIMESTAMP '2026-06-22 09:45:00 +01:00', 12, 1002, 199.00,  'EUR');

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, currency_code)
    VALUES (13, TIMESTAMP '2026-06-25 14:30:00 +01:00', TIMESTAMP '2026-06-25 17:45:00 -05:00', 13, 1006, 890.00,  'GBP');

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, currency_code)
    VALUES (14, TIMESTAMP '2026-07-01 22:00:00 +02:00', TIMESTAMP '2026-07-02 17:30:00 +09:00', 14, 1010, 1450.00,  'EUR');

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, currency_code)
    VALUES (15, TIMESTAMP '2026-07-04 07:00:00 +02:00', TIMESTAMP '2026-07-04 09:15:00 +02:00', 15, 1001, 340.00,  'EUR');


INSERT INTO extra_services (id, name, price) VALUES (1,  'Priority Boarding',       15.00);
INSERT INTO extra_services (id, name, price) VALUES (2,  'Extra Legroom Seat',      35.00);
INSERT INTO extra_services (id, name, price) VALUES (3,  'Small Cabin Bag',         0.00);
INSERT INTO extra_services (id, name, price) VALUES (4,  'Large Cabin Bag',         45.00);
INSERT INTO extra_services (id, name, price) VALUES (5,  'Checked Baggage - Small', 50.00);
INSERT INTO extra_services (id, name, price) VALUES (6,  'Checked Baggage - Medium',70.00);
INSERT INTO extra_services (id, name, price) VALUES (7,  'Checked Baggage - Large', 100.00);
INSERT INTO extra_services (id, name, price) VALUES (8,  'Meal - Standard',         12.00);
INSERT INTO extra_services (id, name, price) VALUES (9,  'Meal - Vegetarian',       12.00);
INSERT INTO extra_services (id, name, price) VALUES (10, 'Meal - Vegan',            12.00);
INSERT INTO extra_services (id, name, price) VALUES (11, 'Travel Insurance',        25.00);
INSERT INTO extra_services (id, name, price) VALUES (12, 'Airport Transfer',        45.00);
INSERT INTO extra_services (id, name, price) VALUES (13, 'Fast Track Security',     20.00);
INSERT INTO extra_services (id, name, price) VALUES (14, 'Lounge Access',           55.00);
INSERT INTO extra_services (id, name, price) VALUES (15, 'Pet in Cabin',            60.00);
INSERT INTO extra_services (id, name, price) VALUES (16, 'Sports Equipment',        40.00);
INSERT INTO extra_services (id, name, price) VALUES (17, 'Unaccompanied Minor',     80.00);
INSERT INTO extra_services (id, name, price) VALUES (18, 'Seat Selection',          10.00);


INSERT INTO luggage (id, weight, height, length, width) VALUES (3, 10.0, 40, 30, 20);
INSERT INTO luggage (id, weight, height, length, width) VALUES (4, 10.0, 55, 40, 25);
INSERT INTO luggage (id, weight, height, length, width) VALUES (5, 15.0, 60, 45, 25);
INSERT INTO luggage (id, weight, height, length, width) VALUES (6, 20.0, 75, 50, 30);
INSERT INTO luggage (id, weight, height, length, width) VALUES (7, 32.0, 80, 60, 35);


INSERT INTO users (id, email_address, password, passengers_id) VALUES (1,  'jan.kowalski@email.pl',       '$2a$12$YnMp19uX9YJ3WIDp9yV9WOa4XmCstqVdf6XnFpxmI65yP7gZly6O6', 1);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (2,  'anna.nowak@email.pl',         '$2b$12$YOtoHSjhWJdzKpuWP7cETeso0v99peDGomtolJb5Ohqi6u83CjH/y', 2);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (3,  'piotr.wisniewski@email.pl',   '$2b$12$bQSVDh0gmRFGqHyxfImIOOHFs4qF1.DKpVA6Ib1x9YoPpqXZJPyfi', 3);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (4,  'maria.kowalczyk@email.pl',    '$2b$12$cbkq.v8GHQVXLmp0fLFQIelHQwfz59YZ8FFaMGIOkqXlr2tVnUIDi', 4);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (5,  'tomasz.lewandowski@email.pl', '$2b$12$vO8WTKYrC4Au1HuTO3nuZ.rF0jHklrJxv9NV95doWTF/k0dYNOhSe', 5);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (6,  'katarzyna.wojcik@email.pl',   '$2b$12$BndKta3R2bKFyp0V0/U2SeZatWAp8aT7nIYQYuyLYvC.J4GfULkbi', 6);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (7,  'marek.kaminski@email.pl',     '$2b$12$Y0i7f5qWVLZPPtXHK4EuZ.EtPcKW4cf7tAzK/jxSYk1FWtSnBwThC', 7);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (8,  'agnieszka.zielinska@email.pl','$2b$12$fh3Fql3Cl5xfAOAMb2oQieTFsSp5ctyN5JflUDcAcwJ9/XCD7XlQ2', 8);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (9,  'krzysztof.szymanski@email.pl','$2b$12$5e7sDgYDrUhSUr9/4Hc3m.e8m8M2aK5mtFHxXU.EzQG/yLrvDooY6', 9);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (10, 'barbara.wozniak@email.pl',    '$2b$12$FXgvdy/3o.LRlQ.1Spa7h.P4NGutpNqt.vZAgLBoKL8AbNgO69FD6', 10);


INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (1,  'Jan',       'Kowalski',    '+48501234567', 1);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (2,  'Anna',      'Nowak',       '+48502345678', 2);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (3,  'Piotr',     'Wisniewski',  '+48503456789', 3);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (4,  'Maria',     'Kowalczyk',   '+48504567890', 4);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (5,  'Tomasz',    'Lewandowski', '+48505678901', 5);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (6,  'Katarzyna', 'Wojcik',      '+48506789012', 6);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (7,  'Marek',     'Kaminski',    '+48507890123', 7);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (8,  'Agnieszka', 'Zielinska',   '+48508901234', 8);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (9,  'Krzysztof', 'Szymanski',   '+48509012345', 9);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (10, 'Barbara',   'Wozniak',     '+48510123456', 10);

INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (11, 'Zofia',     'Kowalska',    '+48511234567', NULL);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (12, 'Adam',      'Nowak',       '+48512345678', NULL);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (13, 'Ewa',       'Wiszniewska', '+48513456789', NULL);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (14, 'Robert',    'Kowalczyk',   '+48514567890', NULL);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (15, 'Monika',    'Lewandowska', '+48515678901', NULL);


INSERT INTO reservations (id, reservation_date, number_in_party, user_id, flights_id) VALUES (1,  DATE '2026-05-01', 2, 1,  1);
INSERT INTO reservations (id, reservation_date, number_in_party, user_id, flights_id) VALUES (2,  DATE '2026-05-02', 1, 2,  2);
INSERT INTO reservations (id, reservation_date, number_in_party, user_id, flights_id) VALUES (3,  DATE '2026-05-03', 2, 3,  3);
INSERT INTO reservations (id, reservation_date, number_in_party, user_id, flights_id) VALUES (4,  DATE '2026-05-05', 1, 4,  4);
INSERT INTO reservations (id, reservation_date, number_in_party, user_id, flights_id) VALUES (5,  DATE '2026-05-06', 2, 5,  5);
INSERT INTO reservations (id, reservation_date, number_in_party, user_id, flights_id) VALUES (6,  DATE '2026-05-07', 1, 6,  6);
INSERT INTO reservations (id, reservation_date, number_in_party, user_id, flights_id) VALUES (7,  DATE '2026-05-08', 1, 7,  7);
INSERT INTO reservations (id, reservation_date, number_in_party, user_id, flights_id) VALUES (8,  DATE '2026-05-09', 1, 8,  8);
INSERT INTO reservations (id, reservation_date, number_in_party, user_id, flights_id) VALUES (9,  DATE '2026-05-10', 1, 9,  9);
INSERT INTO reservations (id, reservation_date, number_in_party, user_id, flights_id) VALUES (10, DATE '2026-05-11', 1, 10, 10);
INSERT INTO reservations (id, reservation_date, number_in_party, user_id, flights_id) VALUES (11, DATE '2026-05-12', 1, 1,  11);
INSERT INTO reservations (id, reservation_date, number_in_party, user_id, flights_id) VALUES (12, DATE '2026-05-13', 1, 2,  12);
INSERT INTO reservations (id, reservation_date, number_in_party, user_id, flights_id) VALUES (13, DATE '2026-05-14', 1, 3,  13);
INSERT INTO reservations (id, reservation_date, number_in_party, user_id, flights_id) VALUES (14, DATE '2026-05-15', 1, 4,  14);
INSERT INTO reservations (id, reservation_date, number_in_party, user_id, flights_id) VALUES (15, DATE '2026-05-16', 1, 5,  15);


INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (1,  1);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (1,  11);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (2,  2);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (3,  3);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (3,  13);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (4,  4);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (5,  5);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (5,  15);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (6,  6);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (7,  7);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (8,  8);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (9,  9);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (10, 10);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (11, 1);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (12, 2);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (13, 3);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (14, 4);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (15, 5);


INSERT INTO reservations_extra_services (reservations_id, extra_services_id, passenger_id) VALUES (1, 1, 1);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id, passenger_id) VALUES (1, 3, 1);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id, passenger_id) VALUES (2, 3, 2);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id, passenger_id) VALUES (3, 1, 3);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id, passenger_id) VALUES (3, 8, 3);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id, passenger_id) VALUES (4, 15, 4);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id, passenger_id) VALUES (5, 4, 5);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id, passenger_id) VALUES (5, 11, 5);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id, passenger_id) VALUES (6, 10, 6);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id, passenger_id) VALUES (7, 5, 7);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id, passenger_id) VALUES (8, 6, 8);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id, passenger_id) VALUES (9, 2, 9);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id, passenger_id) VALUES (10, 3, 10);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id, passenger_id) VALUES (13, 11, 13);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id, passenger_id) VALUES (14, 11, 14);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id, passenger_id) VALUES (14, 4, 14);


INSERT INTO payment_status (payment_status_id, description) VALUES (1, 'Pending');
INSERT INTO payment_status (payment_status_id, description) VALUES (2, 'Completed');
INSERT INTO payment_status (payment_status_id, description) VALUES (3, 'Failed');
INSERT INTO payment_status (payment_status_id, description) VALUES (4, 'Refunded');
INSERT INTO payment_status (payment_status_id, description) VALUES (5, 'Partially Refunded');
INSERT INTO payment_status (payment_status_id, description) VALUES (6, 'Cancelled');

INSERT INTO payments (id, payment_date, payment_status_id, currency_code, reservations_id) VALUES (1,  DATE '2026-05-01', 2,  'EUR', 1);
INSERT INTO payments (id, payment_date, payment_status_id, currency_code, reservations_id) VALUES (2,  DATE '2026-05-02', 2,  'EUR', 2);
INSERT INTO payments (id, payment_date, payment_status_id, currency_code, reservations_id) VALUES (3,  DATE '2026-05-03', 2,  'EUR', 3);
INSERT INTO payments (id, payment_date, payment_status_id, currency_code, reservations_id) VALUES (4,  DATE '2026-05-05', 2,  'EUR', 4);
INSERT INTO payments (id, payment_date, payment_status_id, currency_code, reservations_id) VALUES (5,  DATE '2026-05-06', 2,  'USD', 5);
INSERT INTO payments (id, payment_date, payment_status_id, currency_code, reservations_id) VALUES (6,  DATE '2026-05-07', 1,  'EUR', 6);
INSERT INTO payments (id, payment_date, payment_status_id, currency_code, reservations_id) VALUES (7,  DATE '2026-05-08', 2,  'EUR', 7);
INSERT INTO payments (id, payment_date, payment_status_id, currency_code, reservations_id) VALUES (8,  DATE '2026-05-09', 3,  'EUR', 8);
INSERT INTO payments (id, payment_date, payment_status_id, currency_code, reservations_id) VALUES (9,  DATE '2026-05-10', 2,  'EUR', 9);
INSERT INTO payments (id, payment_date, payment_status_id, currency_code, reservations_id) VALUES (10, DATE '2026-05-11', 4,  'EUR', 10);
INSERT INTO payments (id, payment_date, payment_status_id, currency_code, reservations_id) VALUES (11, DATE '2026-05-12', 2,  'EUR', 11);
INSERT INTO payments (id, payment_date, payment_status_id, currency_code, reservations_id) VALUES (12, DATE '2026-05-13', 2,  'EUR', 12);
INSERT INTO payments (id, payment_date, payment_status_id, currency_code, reservations_id) VALUES (13, DATE '2026-05-14', 2,  'GBP', 13);
INSERT INTO payments (id, payment_date, payment_status_id, currency_code, reservations_id) VALUES (14, DATE '2026-05-15', 1,  'EUR', 14);
INSERT INTO payments (id, payment_date, payment_status_id, currency_code, reservations_id) VALUES (15, DATE '2026-05-16', 2,  'EUR', 15);


INSERT INTO boarding_pass (reservations_id, passengers_id, seats_id, serial_number) VALUES (1,  1,    7, 1001);
INSERT INTO boarding_pass (reservations_id, passengers_id, seats_id, serial_number) VALUES (1,  11,   8, 1001);
INSERT INTO boarding_pass (reservations_id, passengers_id, seats_id, serial_number) VALUES (2,  2,  196, 1002);
INSERT INTO boarding_pass (reservations_id, passengers_id, seats_id, serial_number) VALUES (3,  3,    9, 1001);
INSERT INTO boarding_pass (reservations_id, passengers_id, seats_id, serial_number) VALUES (4,  4,  197, 1002);
INSERT INTO boarding_pass (reservations_id, passengers_id, seats_id, serial_number) VALUES (9,  9, 1665, 1007);
INSERT INTO boarding_pass (reservations_id, passengers_id, seats_id, serial_number) VALUES (11, 1, 1965, 1009);


COMMIT;