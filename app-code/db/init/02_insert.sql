-- =============================================================
-- INSERT data for airline database
-- Oracle Database 21c
-- Order respects FK dependencies
-- =============================================================

-- -------------------------------------------------------------
-- 1. TIME_ZONE
-- -------------------------------------------------------------
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

-- -------------------------------------------------------------
-- 2. COUNTRY
-- -------------------------------------------------------------
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

-- -------------------------------------------------------------
-- 3. CITY
-- -------------------------------------------------------------
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

-- -------------------------------------------------------------
-- 4. AIRPORTS
-- -------------------------------------------------------------
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (1,  'Warsaw Chopin Airport',                  'WAW', 1);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (2,  'Krakow John Paul II International',      'KRK', 2);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (3,  'Gdansk Lech Walesa Airport',             'GDN', 3);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (4,  'Berlin Brandenburg Airport',             'BER', 4);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (5,  'Munich Airport',                         'MUC', 5);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (6,  'Paris Charles de Gaulle Airport',        'CDG', 6);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (7,  'London Heathrow Airport',                'LHR', 7);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (8,  'John F. Kennedy International Airport',  'JFK', 8);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (9,  'Amsterdam Airport Schiphol',             'AMS', 9);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (10, 'Adolfo Suarez Madrid-Barajas Airport',   'MAD', 10);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (11, 'Leonardo da Vinci International',        'FCO', 11);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (12, 'Sheremetyevo International Airport',     'SVO', 12);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (13, 'Tokyo Narita International Airport',     'NRT', 13);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (14, 'Barcelona El Prat Airport',              'BCN', 14);
INSERT INTO airports (id, airport_name, airport_code, city_id) VALUES (15, 'Wroclaw Copernicus Airport',             'WRO', 15);

-- -------------------------------------------------------------
-- 5. CURRENCY
-- -------------------------------------------------------------
INSERT INTO currency (id, code) VALUES (1, 'PLN');
INSERT INTO currency (id, code) VALUES (2, 'EUR');
INSERT INTO currency (id, code) VALUES (3, 'GBP');
INSERT INTO currency (id, code) VALUES (4, 'USD');
INSERT INTO currency (id, code) VALUES (5, 'JPY');

-- -------------------------------------------------------------
-- 6. AIRLINES
-- -------------------------------------------------------------
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

-- -------------------------------------------------------------
-- 7. PLANES
-- -------------------------------------------------------------
INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, id) VALUES (1001, 'Boeing 737-800',     189, 9900,  26020, 6);
INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, id) VALUES (1002, 'Airbus A320',        180, 9500,  26730, 7);
INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, id) VALUES (1003, 'Boeing 787-9',       296, 9900,  56217, 1);
INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, id) VALUES (1004, 'Airbus A321neo',     220, 9900,  32940, 2);
INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, id) VALUES (1005, 'Boeing 767-300ER',   218, 9900,  63216, 3);
INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, id) VALUES (1006, 'Airbus A380-800',    555, 9999,  86671, 4);
INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, id) VALUES (1007, 'Embraer E195',       120, 7000,  13984, 5);
INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, id) VALUES (1008, 'Boeing 737 MAX 8',   178, 9900,  25816, 6);
INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, id) VALUES (1009, 'Airbus A319',        156, 8500,  26730, 8);
INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, id) VALUES (1010, 'Boeing 777-300ER',   396, 9999,  99679, 4);

-- -------------------------------------------------------------
-- 8. CLASS
-- -------------------------------------------------------------
INSERT INTO class (id, type) VALUES (1, 'Economy');
INSERT INTO class (id, type) VALUES (2, 'Premium Economy');
INSERT INTO class (id, type) VALUES (3, 'Business');
INSERT INTO class (id, type) VALUES (4, 'First Class');

-- -------------------------------------------------------------
-- 9. SEAT_TYPE
-- -------------------------------------------------------------
INSERT INTO seat_type (id, type) VALUES (1, 'Window');
INSERT INTO seat_type (id, type) VALUES (2, 'Middle');
INSERT INTO seat_type (id, type) VALUES (3, 'Aisle');

-- -------------------------------------------------------------
-- 10. SEATS  (samolot 1001 – Boeing 737-800, 6 rzedow przykladowo)
-- -------------------------------------------------------------
-- Rzad 1 – Business (klasa 3)
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (1, 1, 1, 1001, 1, 3);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (2, 1, 2, 1001, 3, 3);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (3, 1, 3, 1001, 3, 3);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (4, 1, 4, 1001, 1, 3);
-- Rzad 2 – Economy (klasa 1)
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (5, 2, 1, 1001, 1, 1);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (6, 2, 2, 1001, 2, 1);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (7, 2, 3, 1001, 3, 1);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (8, 2, 4, 1001, 3, 1);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (9, 2, 5, 1001, 2, 1);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (10, 2, 6, 1001, 1, 1);
-- Rzad 3 – Economy
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (11, 3, 1, 1001, 1, 1);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (12, 3, 2, 1001, 2, 1);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (13, 3, 3, 1001, 3, 1);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (14, 3, 4, 1001, 3, 1);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (15, 3, 5, 1001, 2, 1);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (16, 3, 6, 1001, 1, 1);
-- Samolot 1002 – Airbus A320
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (17, 1, 1, 1002, 1, 3);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (18, 1, 2, 1002, 3, 3);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (19, 1, 3, 1002, 3, 3);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (20, 1, 4, 1002, 1, 3);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (21, 2, 1, 1002, 1, 1);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (22, 2, 2, 1002, 2, 1);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (23, 2, 3, 1002, 3, 1);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (24, 2, 4, 1002, 3, 1);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (25, 2, 5, 1002, 2, 1);
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id) VALUES (26, 2, 6, 1002, 1, 1);

-- -------------------------------------------------------------
-- 11. ROUTES
-- -------------------------------------------------------------
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (1,  1,  4);   -- WAW -> BER
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (2,  1,  6);   -- WAW -> CDG
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (3,  1,  7);   -- WAW -> LHR
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (4,  1,  9);   -- WAW -> AMS
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (5,  1,  8);   -- WAW -> JFK
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (6,  4,  1);   -- BER -> WAW
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (7,  6,  1);   -- CDG -> WAW
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (8,  7,  1);   -- LHR -> WAW
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (9,  2,  6);   -- KRK -> CDG
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (10, 2,  4);   -- KRK -> BER
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (11, 3,  9);   -- GDN -> AMS
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (12, 6,  7);   -- CDG -> LHR
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (13, 7,  8);   -- LHR -> JFK
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (14, 9,  13);  -- AMS -> NRT
INSERT INTO routes (id, origin_airport_id, destination_airport_id) VALUES (15, 1,  11);  -- WAW -> FCO

-- -------------------------------------------------------------
-- 12. FLIGHTS
-- -------------------------------------------------------------
INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, id1, airlines_id)
    VALUES (1, TIMESTAMP '2026-06-01 06:00:00 +02:00', TIMESTAMP '2026-06-01 07:45:00 +02:00', 1,  1001, 299.00,  2, 1);

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, id1, airlines_id)
    VALUES (2, TIMESTAMP '2026-06-01 10:30:00 +02:00', TIMESTAMP '2026-06-01 12:45:00 +02:00', 2,  1002, 349.00,  2, 1);

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, id1, airlines_id)
    VALUES (3, TIMESTAMP '2026-06-02 08:00:00 +02:00', TIMESTAMP '2026-06-02 10:15:00 +01:00', 3,  1001, 420.00,  3, 1);

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, id1, airlines_id)
    VALUES (4, TIMESTAMP '2026-06-03 14:00:00 +02:00', TIMESTAMP '2026-06-03 16:00:00 +02:00', 4,  1002, 279.00,  2, 7);

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, id1, airlines_id)
    VALUES (5, TIMESTAMP '2026-06-05 21:00:00 +02:00', TIMESTAMP '2026-06-06 00:30:00 -05:00', 5,  1003, 1250.00, 4, 1);

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, id1, airlines_id)
    VALUES (6, TIMESTAMP '2026-06-07 09:00:00 +02:00', TIMESTAMP '2026-06-07 10:50:00 +02:00', 6,  1004, 310.00,  2, 2);

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, id1, airlines_id)
    VALUES (7, TIMESTAMP '2026-06-08 13:00:00 +02:00', TIMESTAMP '2026-06-08 15:20:00 +02:00', 7,  1005, 380.00,  2, 3);

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, id1, airlines_id)
    VALUES (8, TIMESTAMP '2026-06-10 07:30:00 +01:00', TIMESTAMP '2026-06-10 11:45:00 +02:00', 8,  1002, 395.00,  2, 4);

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, id1, airlines_id)
    VALUES (9, TIMESTAMP '2026-06-12 06:15:00 +02:00', TIMESTAMP '2026-06-12 09:00:00 +02:00', 9,  1007, 220.00,  2, 1);

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, id1, airlines_id)
    VALUES (10, TIMESTAMP '2026-06-15 16:00:00 +02:00', TIMESTAMP '2026-06-15 17:45:00 +02:00', 10, 1008, 189.00,  2, 6);

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, id1, airlines_id)
    VALUES (11, TIMESTAMP '2026-06-20 11:00:00 +02:00', TIMESTAMP '2026-06-20 13:30:00 +02:00', 11, 1009, 259.00,  2, 7);

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, id1, airlines_id)
    VALUES (12, TIMESTAMP '2026-06-22 08:45:00 +02:00', TIMESTAMP '2026-06-22 09:45:00 +01:00', 12, 1002, 199.00,  2, 3);

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, id1, airlines_id)
    VALUES (13, TIMESTAMP '2026-06-25 14:30:00 +01:00', TIMESTAMP '2026-06-25 17:45:00 -05:00', 13, 1006, 890.00,  3, 4);

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, id1, airlines_id)
    VALUES (14, TIMESTAMP '2026-07-01 22:00:00 +02:00', TIMESTAMP '2026-07-02 17:30:00 +09:00', 14, 1010, 1450.00, 2, 5);

INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, id1, airlines_id)
    VALUES (15, TIMESTAMP '2026-07-04 07:00:00 +02:00', TIMESTAMP '2026-07-04 09:15:00 +02:00', 15, 1001, 340.00,  2, 1);

-- -------------------------------------------------------------
-- 13. EXTRA_SERVICES
-- -------------------------------------------------------------
INSERT INTO extra_services (id, name, price) VALUES (1,  'Priority Boarding',        15.00);
INSERT INTO extra_services (id, name, price) VALUES (2,  'Extra Legroom Seat',       35.00);
INSERT INTO extra_services (id, name, price) VALUES (3,  'Checked Baggage 23kg',     30.00);
INSERT INTO extra_services (id, name, price) VALUES (4,  'Checked Baggage 32kg',     50.00);
INSERT INTO extra_services (id, name, price) VALUES (5,  'Meal – Standard',          12.00);
INSERT INTO extra_services (id, name, price) VALUES (6,  'Meal – Vegetarian',        12.00);
INSERT INTO extra_services (id, name, price) VALUES (7,  'Meal – Vegan',             12.00);
INSERT INTO extra_services (id, name, price) VALUES (8,  'Travel Insurance',         25.00);
INSERT INTO extra_services (id, name, price) VALUES (9,  'Airport Transfer',         45.00);
INSERT INTO extra_services (id, name, price) VALUES (10, 'Fast Track Security',      20.00);
INSERT INTO extra_services (id, name, price) VALUES (11, 'Lounge Access',            55.00);
INSERT INTO extra_services (id, name, price) VALUES (12, 'Pet in Cabin',             60.00);
INSERT INTO extra_services (id, name, price) VALUES (13, 'Sports Equipment',         40.00);
INSERT INTO extra_services (id, name, price) VALUES (14, 'Unaccompanied Minor',      80.00);
INSERT INTO extra_services (id, name, price) VALUES (15, 'Seat Selection',           10.00);

-- -------------------------------------------------------------
-- 14. USERS
-- -------------------------------------------------------------
INSERT INTO users (id, email_address, password, passengers_id) VALUES (1,  'jan.kowalski@email.pl',      'Haslo1234',   NULL);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (2,  'anna.nowak@email.pl',        'Haslo5678',   NULL);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (3,  'piotr.wisniewski@email.pl',  'Secure99!',   NULL);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (4,  'maria.kowalczyk@email.pl',   'Pass1234!',   NULL);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (5,  'tomasz.lewandowski@email.pl','TomPass77',   NULL);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (6,  'katarzyna.wojcik@email.pl',  'KatPass88',   NULL);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (7,  'marek.kaminski@email.pl',    'Marek123!',   NULL);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (8,  'agnieszka.zielinska@email.pl','Agn12345',   NULL);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (9,  'krzysztof.szymanski@email.pl','KrzPass55',  NULL);
INSERT INTO users (id, email_address, password, passengers_id) VALUES (10, 'barbara.wozniak@email.pl',   'Barbara99',   NULL);

-- -------------------------------------------------------------
-- 15. PASSENGERS
-- -------------------------------------------------------------
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (1,  'Jan',        'Kowalski',    '+48501234567', 1);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (2,  'Anna',       'Nowak',       '+48502345678', 2);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (3,  'Piotr',      'Wisniewski',  '+48503456789', 3);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (4,  'Maria',      'Kowalczyk',   '+48504567890', 4);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (5,  'Tomasz',     'Lewandowski', '+48505678901', 5);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (6,  'Katarzyna',  'Wojcik',      '+48506789012', 6);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (7,  'Marek',      'Kaminski',    '+48507890123', 7);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (8,  'Agnieszka',  'Zielinska',   '+48508901234', 8);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (9,  'Krzysztof',  'Szymanski',   '+48509012345', 9);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (10, 'Barbara',    'Wozniak',     '+48510123456', 10);
-- Pasazerowie bez kont uzytkownikow (czlonkowie rodzin itp.)
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (11, 'Zofia',      'Kowalska',    '+48511234567', NULL);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (12, 'Adam',       'Nowak',       '+48512345678', NULL);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (13, 'Ewa',        'Wiszniewska', '+48513456789', NULL);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (14, 'Robert',     'Kowalczyk',   '+48514567890', NULL);
INSERT INTO passengers (id, first_name, last_name, phone_number, user_id) VALUES (15, 'Monika',     'Lewandowska', '+48515678901', NULL);

-- Powiaz uzytkownikow z pasazerami
UPDATE users SET passengers_id = 1  WHERE id = 1;
UPDATE users SET passengers_id = 2  WHERE id = 2;
UPDATE users SET passengers_id = 3  WHERE id = 3;
UPDATE users SET passengers_id = 4  WHERE id = 4;
UPDATE users SET passengers_id = 5  WHERE id = 5;
UPDATE users SET passengers_id = 6  WHERE id = 6;
UPDATE users SET passengers_id = 7  WHERE id = 7;
UPDATE users SET passengers_id = 8  WHERE id = 8;
UPDATE users SET passengers_id = 9  WHERE id = 9;
UPDATE users SET passengers_id = 10 WHERE id = 10;

-- -------------------------------------------------------------
-- 16. PAYMENT_STATUS
-- -------------------------------------------------------------
INSERT INTO payment_status (payment_status_id, description) VALUES (1, 'Pending');
INSERT INTO payment_status (payment_status_id, description) VALUES (2, 'Completed');
INSERT INTO payment_status (payment_status_id, description) VALUES (3, 'Failed');
INSERT INTO payment_status (payment_status_id, description) VALUES (4, 'Refunded');
INSERT INTO payment_status (payment_status_id, description) VALUES (5, 'Partially Refunded');

-- -------------------------------------------------------------
-- 17. PAYMENTS
-- -------------------------------------------------------------
INSERT INTO payments (id, payment_date, payment_status_id, payment_amount, currency_id) VALUES (1,  DATE '2026-05-01', 2, 598.00,  2);
INSERT INTO payments (id, payment_date, payment_status_id, payment_amount, currency_id) VALUES (2,  DATE '2026-05-02', 2, 349.00,  2);
INSERT INTO payments (id, payment_date, payment_status_id, payment_amount, currency_id) VALUES (3,  DATE '2026-05-03', 2, 840.00,  2);
INSERT INTO payments (id, payment_date, payment_status_id, payment_amount, currency_id) VALUES (4,  DATE '2026-05-05', 2, 279.00,  2);
INSERT INTO payments (id, payment_date, payment_status_id, payment_amount, currency_id) VALUES (5,  DATE '2026-05-06', 2, 2500.00, 4);
INSERT INTO payments (id, payment_date, payment_status_id, payment_amount, currency_id) VALUES (6,  DATE '2026-05-07', 1, 310.00,  2);
INSERT INTO payments (id, payment_date, payment_status_id, payment_amount, currency_id) VALUES (7,  DATE '2026-05-08', 2, 420.00,  2);
INSERT INTO payments (id, payment_date, payment_status_id, payment_amount, currency_id) VALUES (8,  DATE '2026-05-09', 3, 395.00,  2);
INSERT INTO payments (id, payment_date, payment_status_id, payment_amount, currency_id) VALUES (9,  DATE '2026-05-10', 2, 220.00,  2);
INSERT INTO payments (id, payment_date, payment_status_id, payment_amount, currency_id) VALUES (10, DATE '2026-05-11', 4, 189.00,  2);
INSERT INTO payments (id, payment_date, payment_status_id, payment_amount, currency_id) VALUES (11, DATE '2026-05-12', 2, 259.00,  2);
INSERT INTO payments (id, payment_date, payment_status_id, payment_amount, currency_id) VALUES (12, DATE '2026-05-13', 2, 199.00,  2);
INSERT INTO payments (id, payment_date, payment_status_id, payment_amount, currency_id) VALUES (13, DATE '2026-05-14', 2, 890.00,  3);
INSERT INTO payments (id, payment_date, payment_status_id, payment_amount, currency_id) VALUES (14, DATE '2026-05-15', 1, 1450.00, 2);
INSERT INTO payments (id, payment_date, payment_status_id, payment_amount, currency_id) VALUES (15, DATE '2026-05-16', 2, 340.00,  2);

-- -------------------------------------------------------------
-- 18. RESERVATIONS
-- -------------------------------------------------------------
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

-- -------------------------------------------------------------
-- 19. RESERVATIONS_PASSENGERS
-- -------------------------------------------------------------
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (1,  1);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (1,  11);  -- rezerwacja dla 2 osob
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (2,  2);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (3,  3);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (3,  13);  -- rezerwacja dla 2 osob
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (4,  4);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (5,  5);
INSERT INTO reservations_passengers (reservations_id, passengers_id) VALUES (5,  15);  -- rezerwacja dla 2 osob
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

-- -------------------------------------------------------------
-- 20. RESERVATIONS_PAYMENTS
-- -------------------------------------------------------------
INSERT INTO reservations_payments (reservations_id, payments_id) VALUES (1,  1);
INSERT INTO reservations_payments (reservations_id, payments_id) VALUES (2,  2);
INSERT INTO reservations_payments (reservations_id, payments_id) VALUES (3,  3);
INSERT INTO reservations_payments (reservations_id, payments_id) VALUES (4,  4);
INSERT INTO reservations_payments (reservations_id, payments_id) VALUES (5,  5);
INSERT INTO reservations_payments (reservations_id, payments_id) VALUES (6,  6);
INSERT INTO reservations_payments (reservations_id, payments_id) VALUES (7,  7);
INSERT INTO reservations_payments (reservations_id, payments_id) VALUES (8,  8);
INSERT INTO reservations_payments (reservations_id, payments_id) VALUES (9,  9);
INSERT INTO reservations_payments (reservations_id, payments_id) VALUES (10, 10);
INSERT INTO reservations_payments (reservations_id, payments_id) VALUES (11, 11);
INSERT INTO reservations_payments (reservations_id, payments_id) VALUES (12, 12);
INSERT INTO reservations_payments (reservations_id, payments_id) VALUES (13, 13);
INSERT INTO reservations_payments (reservations_id, payments_id) VALUES (14, 14);
INSERT INTO reservations_payments (reservations_id, payments_id) VALUES (15, 15);

-- -------------------------------------------------------------
-- 21. RESERVATIONS_EXTRA_SERVICES
-- -------------------------------------------------------------
INSERT INTO reservations_extra_services (reservations_id, extra_services_id) VALUES (1,  1);   -- Priority Boarding
INSERT INTO reservations_extra_services (reservations_id, extra_services_id) VALUES (1,  3);   -- Checked Baggage 23kg
INSERT INTO reservations_extra_services (reservations_id, extra_services_id) VALUES (2,  3);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id) VALUES (3,  1);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id) VALUES (3,  8);   -- Travel Insurance
INSERT INTO reservations_extra_services (reservations_id, extra_services_id) VALUES (4,  15);  -- Seat Selection
INSERT INTO reservations_extra_services (reservations_id, extra_services_id) VALUES (5,  4);   -- Checked Baggage 32kg
INSERT INTO reservations_extra_services (reservations_id, extra_services_id) VALUES (5,  11);  -- Lounge Access
INSERT INTO reservations_extra_services (reservations_id, extra_services_id) VALUES (6,  10);  -- Fast Track Security
INSERT INTO reservations_extra_services (reservations_id, extra_services_id) VALUES (7,  5);   -- Meal Standard
INSERT INTO reservations_extra_services (reservations_id, extra_services_id) VALUES (8,  6);   -- Meal Vegetarian
INSERT INTO reservations_extra_services (reservations_id, extra_services_id) VALUES (9,  2);   -- Extra Legroom
INSERT INTO reservations_extra_services (reservations_id, extra_services_id) VALUES (10, 3);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id) VALUES (13, 11);  -- Lounge Access
INSERT INTO reservations_extra_services (reservations_id, extra_services_id) VALUES (14, 11);
INSERT INTO reservations_extra_services (reservations_id, extra_services_id) VALUES (14, 4);

-- -------------------------------------------------------------
-- 22. LUGGAGE
-- -------------------------------------------------------------
INSERT INTO luggage (id, weight, height, length, width, id2) VALUES (1,  18.5, 60, 40, 25, 1);
INSERT INTO luggage (id, weight, height, length, width, id2) VALUES (2,  22.0, 65, 45, 30, 2);
INSERT INTO luggage (id, weight, height, length, width, id2) VALUES (3,  15.3, 55, 38, 22, 3);
INSERT INTO luggage (id, weight, height, length, width, id2) VALUES (4,  20.0, 60, 42, 28, 4);
INSERT INTO luggage (id, weight, height, length, width, id2) VALUES (5,  12.5, 50, 35, 20, 5);
INSERT INTO luggage (id, weight, height, length, width, id2) VALUES (6,   8.0, 40, 30, 15, 6);
INSERT INTO luggage (id, weight, height, length, width, id2) VALUES (7,  25.0, 70, 50, 35, 7);
INSERT INTO luggage (id, weight, height, length, width, id2) VALUES (8,  19.5, 62, 43, 27, 8);
INSERT INTO luggage (id, weight, height, length, width, id2) VALUES (9,  11.0, 45, 32, 18, 9);
INSERT INTO luggage (id, weight, height, length, width, id2) VALUES (10, 23.0, 68, 48, 32, 10);

-- -------------------------------------------------------------
-- 23. BOARDING_PASS
-- -------------------------------------------------------------
INSERT INTO boarding_pass (reservations_id, seats_id, serial_number, departure_airport_code, arrival_airport_code,
    flight_departure_date_time, passenger_first_name, passenger_last_name, seat_row, seat_col)
VALUES (1, 5, 1001, 'WAW', 'BER', TIMESTAMP '2026-06-01 06:00:00 +02:00', 'Jan',      'Kowalski',    2, 1);

INSERT INTO boarding_pass (reservations_id, seats_id, serial_number, departure_airport_code, arrival_airport_code,
    flight_departure_date_time, passenger_first_name, passenger_last_name, seat_row, seat_col)
VALUES (1, 6, 1001, 'WAW', 'BER', TIMESTAMP '2026-06-01 06:00:00 +02:00', 'Zofia',    'Kowalska',    2, 2);

INSERT INTO boarding_pass (reservations_id, seats_id, serial_number, departure_airport_code, arrival_airport_code,
    flight_departure_date_time, passenger_first_name, passenger_last_name, seat_row, seat_col)
VALUES (2, 21, 1002, 'WAW', 'CDG', TIMESTAMP '2026-06-01 10:30:00 +02:00', 'Anna',    'Nowak',       2, 1);

INSERT INTO boarding_pass (reservations_id, seats_id, serial_number, departure_airport_code, arrival_airport_code,
    flight_departure_date_time, passenger_first_name, passenger_last_name, seat_row, seat_col)
VALUES (3, 7, 1001, 'WAW', 'LHR', TIMESTAMP '2026-06-02 08:00:00 +02:00', 'Piotr',   'Wisniewski',  2, 3);

INSERT INTO boarding_pass (reservations_id, seats_id, serial_number, departure_airport_code, arrival_airport_code,
    flight_departure_date_time, passenger_first_name, passenger_last_name, seat_row, seat_col)
VALUES (4, 22, 1002, 'WAW', 'AMS', TIMESTAMP '2026-06-03 14:00:00 +02:00', 'Maria',   'Kowalczyk',   2, 2);

INSERT INTO boarding_pass (reservations_id, seats_id, serial_number, departure_airport_code, arrival_airport_code,
    flight_departure_date_time, passenger_first_name, passenger_last_name, seat_row, seat_col)
VALUES (9, 11, 1001, 'KRK', 'CDG', TIMESTAMP '2026-06-12 06:15:00 +02:00', 'Krzysztof', 'Szymanski', 3, 1);

INSERT INTO boarding_pass (reservations_id, seats_id, serial_number, departure_airport_code, arrival_airport_code,
    flight_departure_date_time, passenger_first_name, passenger_last_name, seat_row, seat_col)
VALUES (11, 23, 1002, 'GDN', 'AMS', TIMESTAMP '2026-06-20 11:00:00 +02:00', 'Jan',    'Kowalski',    2, 3);

-- -------------------------------------------------------------
-- 24. ROUTE_STATISTICS
-- -------------------------------------------------------------
INSERT INTO route_statistics (routes_id, year, month, total_passengers, total_revenue) VALUES (1,  2025, 1,  4521,  1234567.50);
INSERT INTO route_statistics (routes_id, year, month, total_passengers, total_revenue) VALUES (1,  2025, 2,  4102,  1123456.00);
INSERT INTO route_statistics (routes_id, year, month, total_passengers, total_revenue) VALUES (1,  2025, 3,  5230,  1456789.75);
INSERT INTO route_statistics (routes_id, year, month, total_passengers, total_revenue) VALUES (2,  2025, 1,  6321,  2345678.00);
INSERT INTO route_statistics (routes_id, year, month, total_passengers, total_revenue) VALUES (2,  2025, 2,  5987,  2213456.50);
INSERT INTO route_statistics (routes_id, year, month, total_passengers, total_revenue) VALUES (3,  2025, 1,  7845,  3123456.25);
INSERT INTO route_statistics (routes_id, year, month, total_passengers, total_revenue) VALUES (3,  2025, 2,  7234,  2987654.00);
INSERT INTO route_statistics (routes_id, year, month, total_passengers, total_revenue) VALUES (5,  2025, 1,  2103,  2623456.00);
INSERT INTO route_statistics (routes_id, year, month, total_passengers, total_revenue) VALUES (5,  2025, 2,  1987,  2484567.50);
INSERT INTO route_statistics (routes_id, year, month, total_passengers, total_revenue) VALUES (13, 2025, 1,  5412,  4823456.75);

COMMIT;
