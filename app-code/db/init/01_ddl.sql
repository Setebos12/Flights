CREATE TABLE time_zone (
                           id             NUMBER(2)    NOT NULL,
                           code           VARCHAR2(5)  NOT NULL,
                           utc_difference NUMBER(2)    NOT NULL
);
ALTER TABLE time_zone ADD CONSTRAINT time_zone_pk PRIMARY KEY (id);
ALTER TABLE time_zone ADD CONSTRAINT tz_utc_diff_chk  CHECK (utc_difference >= -12 AND utc_difference <= 14);
ALTER TABLE time_zone ADD CONSTRAINT tz_code_len_chk  CHECK (LENGTH(TRIM(code)) >= 2);
ALTER TABLE time_zone ADD CONSTRAINT tz_code_uq       UNIQUE (code);


CREATE TABLE country (
                         id           NUMBER(3)    NOT NULL,
                         name         VARCHAR2(128),
                         time_zone_id NUMBER(2)    NOT NULL
);
ALTER TABLE country ADD CONSTRAINT country_pk PRIMARY KEY (id);
ALTER TABLE country ADD CONSTRAINT country_time_zone_fk FOREIGN KEY (time_zone_id) REFERENCES time_zone (id);


CREATE TABLE city (
                      id         NUMBER(5)    NOT NULL,
                      name       VARCHAR2(128),
                      country_id NUMBER(3)    NOT NULL
);
ALTER TABLE city ADD CONSTRAINT city_pk PRIMARY KEY (id);
ALTER TABLE city ADD CONSTRAINT city_country_fk FOREIGN KEY (country_id) REFERENCES country (id);


CREATE TABLE currency (
                          code VARCHAR2(3) NOT NULL
);
ALTER TABLE currency ADD CONSTRAINT currency_pk       PRIMARY KEY (code);
ALTER TABLE currency ADD CONSTRAINT currency_code_uq  UNIQUE (code);
ALTER TABLE currency ADD CONSTRAINT currency_code_len_chk   CHECK (LENGTH(code) = 3);
ALTER TABLE currency ADD CONSTRAINT currency_code_upper_chk CHECK (code = UPPER(code));



CREATE TABLE payment_status (
                                payment_status_id NUMBER       NOT NULL,
                                description       VARCHAR2(256) NOT NULL
);
ALTER TABLE payment_status ADD CONSTRAINT payment_status_pk PRIMARY KEY (payment_status_id);

CREATE SEQUENCE payment_status_seq START WITH 1 NOCACHE ORDER;
CREATE OR REPLACE TRIGGER payment_status_bir
    BEFORE INSERT ON payment_status FOR EACH ROW
    WHEN (new.payment_status_id IS NULL)
BEGIN
    :new.payment_status_id := payment_status_seq.nextval;
END;
/


CREATE TABLE airlines (
                          id   NUMBER(2)    NOT NULL,
                          name VARCHAR2(128) NOT NULL
);
ALTER TABLE airlines ADD CONSTRAINT airlines_pk       PRIMARY KEY (id);
ALTER TABLE airlines ADD CONSTRAINT airlines_name_chk CHECK (LENGTH(TRIM(name)) > 0);


CREATE TABLE seat_type (
                           id   NUMBER(1)    NOT NULL,
                           type VARCHAR2(128) NOT NULL
);
ALTER TABLE seat_type ADD CONSTRAINT seat_type_pk PRIMARY KEY (id);


CREATE TABLE class (
                       id   NUMBER(2)    NOT NULL,
                       type VARCHAR2(128) NOT NULL
);
ALTER TABLE class ADD CONSTRAINT class_pk PRIMARY KEY (id);


CREATE TABLE extra_services (
                                id    NUMBER(4)    NOT NULL,
                                name  VARCHAR2(128) NOT NULL,
                                price NUMBER(5, 2)  NOT NULL
);
ALTER TABLE extra_services ADD CONSTRAINT extra_services_pk        PRIMARY KEY (id);
ALTER TABLE extra_services ADD CONSTRAINT extra_services_price_chk CHECK (price >= 0);


CREATE TABLE airports (
                          id           NUMBER(4)    NOT NULL,
                          airport_name VARCHAR2(256) NOT NULL,
                          airport_code VARCHAR2(3),
                          city_id      NUMBER(5)    NOT NULL
);
ALTER TABLE airports ADD CONSTRAINT airports_pk              PRIMARY KEY (id);
ALTER TABLE airports ADD CONSTRAINT airports_city_fk         FOREIGN KEY (city_id) REFERENCES city (id);
ALTER TABLE airports ADD CONSTRAINT airports_code_upper_chk  CHECK (airport_code IS NULL OR airport_code = UPPER(airport_code));
ALTER TABLE airports ADD CONSTRAINT airports_code_uq         UNIQUE (airport_code);


CREATE TABLE routes (
                        id                     NUMBER(4) NOT NULL,
                        origin_airport_id      NUMBER(4) NOT NULL,
                        destination_airport_id NUMBER(4) NOT NULL
);
ALTER TABLE routes ADD CONSTRAINT routes_pk                   PRIMARY KEY (id);
ALTER TABLE routes ADD CONSTRAINT routes_airports_fk          FOREIGN KEY (origin_airport_id)      REFERENCES airports (id);
ALTER TABLE routes ADD CONSTRAINT routes_airports_fkv1        FOREIGN KEY (destination_airport_id) REFERENCES airports (id);
ALTER TABLE routes ADD CONSTRAINT routes_different_airports_chk CHECK (origin_airport_id != destination_airport_id);
ALTER TABLE routes ADD CONSTRAINT routes_uq                   UNIQUE (origin_airport_id, destination_airport_id);


CREATE TABLE route_statistics (
                                  routes_id        NUMBER(4) NOT NULL,
                                  year             NUMBER(4) NOT NULL,
                                  month            NUMBER(2) NOT NULL,
                                  total_passengers NUMBER(9),
                                  total_revenue    NUMBER(14, 2)
);
ALTER TABLE route_statistics ADD CONSTRAINT route_statistics_pk      PRIMARY KEY (routes_id, year, month);
ALTER TABLE route_statistics ADD CONSTRAINT route_statistics_routes_fk FOREIGN KEY (routes_id) REFERENCES routes (id);
ALTER TABLE route_statistics ADD CONSTRAINT rs_month_chk             CHECK (month >= 0 AND month <= 12);
ALTER TABLE route_statistics ADD CONSTRAINT rs_passengers_chk        CHECK (total_passengers IS NULL OR total_passengers >= 0);
ALTER TABLE route_statistics ADD CONSTRAINT rs_revenue_chk           CHECK (total_revenue IS NULL OR total_revenue >= 0);


CREATE TABLE planes (
                        serial_number NUMBER(4)    NOT NULL,
                        model         VARCHAR2(128) NOT NULL,
                        seat_count    NUMBER(3)    NOT NULL,
                        load_capacity NUMBER(4),
                        fuel_capacity NUMBER(5),
                        airlines_id   NUMBER(2)    NOT NULL
);
ALTER TABLE planes ADD CONSTRAINT planes_pk               PRIMARY KEY (serial_number);
ALTER TABLE planes ADD CONSTRAINT planes_airlines_fk      FOREIGN KEY (airlines_id) REFERENCES airlines (id);
ALTER TABLE planes ADD CONSTRAINT planes_seat_count_chk   CHECK (seat_count > 0);
ALTER TABLE planes ADD CONSTRAINT planes_load_capacity_chk CHECK (load_capacity IS NULL OR load_capacity > 0);
ALTER TABLE planes ADD CONSTRAINT planes_fuel_capacity_chk CHECK (fuel_capacity IS NULL OR fuel_capacity > 0);


CREATE TABLE seats (
                       id            NUMBER(5) NOT NULL,
                       row_nr        NUMBER(2) NOT NULL,
                       column_nr     NUMBER(1) NOT NULL,
                       serial_number NUMBER(4) NOT NULL,
                       seat_type_id  NUMBER(1) NOT NULL,
                       class_id      NUMBER(2) NOT NULL
);
ALTER TABLE seats ADD CONSTRAINT seats_pk          PRIMARY KEY (id, serial_number);
ALTER TABLE seats ADD CONSTRAINT seats_planes_fk   FOREIGN KEY (serial_number) REFERENCES planes (serial_number);
ALTER TABLE seats ADD CONSTRAINT seats_seat_type_fk FOREIGN KEY (seat_type_id) REFERENCES seat_type (id);
ALTER TABLE seats ADD CONSTRAINT seats_class_fk    FOREIGN KEY (class_id)      REFERENCES class (id);
ALTER TABLE seats ADD CONSTRAINT seats_row_chk     CHECK (row_nr >= 1);
ALTER TABLE seats ADD CONSTRAINT seats_col_chk     CHECK (column_nr >= 1 AND column_nr <= 9);


CREATE TABLE flights (
                         id                  NUMBER(4)                NOT NULL,
                         departure_date_time TIMESTAMP WITH TIME ZONE NOT NULL,
                         arrival_date_time   TIMESTAMP WITH TIME ZONE NOT NULL,
                         routes_id           NUMBER(4)                NOT NULL,
                         serial_number       NUMBER(4)                NOT NULL,
                         price               NUMBER(7, 2)             NOT NULL,
                         airlines_id         NUMBER(2)                NOT NULL,
                         currency_code       VARCHAR2(3)              NOT NULL,
                         booked_seats_count  NUMBER(3),
                         p_seat_count        NUMBER(3)
);
ALTER TABLE flights ADD CONSTRAINT flights_pk          PRIMARY KEY (id);
ALTER TABLE flights ADD CONSTRAINT flights_routes_fk   FOREIGN KEY (routes_id)     REFERENCES routes (id);
ALTER TABLE flights ADD CONSTRAINT flights_planes_fk   FOREIGN KEY (serial_number) REFERENCES planes (serial_number);
ALTER TABLE flights ADD CONSTRAINT flights_airlines_fk FOREIGN KEY (airlines_id)   REFERENCES airlines (id);
ALTER TABLE flights ADD CONSTRAINT flights_currency_fk FOREIGN KEY (currency_code) REFERENCES currency (code);
ALTER TABLE flights ADD CONSTRAINT flights_dates_chk   CHECK (arrival_date_time > departure_date_time);
ALTER TABLE flights ADD CONSTRAINT flights_price_chk   CHECK (price > 0);


CREATE TABLE users (
                       id            NUMBER(4)    NOT NULL,
                       email_address VARCHAR2(128) NOT NULL,
                       password      VARCHAR2(128) NOT NULL,
                       passengers_id NUMBER(5)
);

ALTER TABLE users ADD CONSTRAINT users_pk              PRIMARY KEY (id);
ALTER TABLE users ADD CONSTRAINT users_email_uq        UNIQUE (email_address);
ALTER TABLE users ADD CONSTRAINT users_email_chk       CHECK (REGEXP_LIKE(email_address,
                                                                          '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$'));
ALTER TABLE users ADD CONSTRAINT users_password_len_chk CHECK (LENGTH(password) >= 8);


CREATE TABLE passengers (
                            id                      NUMBER(5)    NOT NULL,
                            first_name              VARCHAR2(128) NOT NULL,
                            last_name               VARCHAR2(128) NOT NULL,
                            phone_number            VARCHAR2(15),
                            other_passenger_details CLOB,
                            user_id                 NUMBER(4)
);
CREATE UNIQUE INDEX passengers_user_idx ON passengers (user_id ASC);
ALTER TABLE passengers ADD CONSTRAINT passengers_pk           PRIMARY KEY (id);
ALTER TABLE passengers ADD CONSTRAINT passengers_user_fk      FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE passengers ADD CONSTRAINT passengers_first_name_chk CHECK (LENGTH(TRIM(first_name)) > 0);
ALTER TABLE passengers ADD CONSTRAINT passengers_last_name_chk  CHECK (LENGTH(TRIM(last_name)) > 0);
ALTER TABLE passengers ADD CONSTRAINT passengers_phone_chk      CHECK (phone_number IS NULL OR
                                                                       REGEXP_LIKE(phone_number, '^\+?[0-9 \-]{7,15}$'));


CREATE TABLE luggage (
                            id           NUMBER(4)   NOT NULL,
                            weight       NUMBER(3,1) NOT NULL,
                            height       NUMBER(3),
                            length       NUMBER(3),
                            width        NUMBER(3)
);
ALTER TABLE luggage ADD CONSTRAINT luggage_pk            PRIMARY KEY (id);
ALTER TABLE luggage ADD CONSTRAINT luggage_extra_serv_fk FOREIGN KEY (id) REFERENCES extra_services (id);
ALTER TABLE luggage ADD CONSTRAINT luggage_weight_chk    CHECK (weight > 0);
ALTER TABLE luggage ADD CONSTRAINT luggage_height_chk    CHECK (height IS NULL OR height > 0);
ALTER TABLE luggage ADD CONSTRAINT luggage_length_chk    CHECK (length IS NULL OR length > 0);
ALTER TABLE luggage ADD CONSTRAINT luggage_width_chk     CHECK (width IS NULL OR width > 0);


CREATE TABLE reservations (
                              id               NUMBER(5) NOT NULL,
                              reservation_date DATE DEFAULT sysdate NOT NULL,
                              number_in_party  NUMBER(2) DEFAULT 1,
                              user_id          NUMBER(4) NOT NULL,
                              flights_id       NUMBER(4) NOT NULL
);
ALTER TABLE reservations ADD CONSTRAINT reservations_pk         PRIMARY KEY (id);
ALTER TABLE reservations ADD CONSTRAINT reservations_users_fk   FOREIGN KEY (user_id)    REFERENCES users (id);
ALTER TABLE reservations ADD CONSTRAINT reservations_flights_fk FOREIGN KEY (flights_id) REFERENCES flights (id);


CREATE TABLE reservations_passengers (
                                         reservations_id NUMBER(5) NOT NULL,
                                         passengers_id   NUMBER(5) NOT NULL
);
ALTER TABLE reservations_passengers ADD CONSTRAINT reservations_passengers_pk PRIMARY KEY (passengers_id, reservations_id);
ALTER TABLE reservations_passengers ADD CONSTRAINT rp_reservations_fk FOREIGN KEY (reservations_id) REFERENCES reservations (id);
ALTER TABLE reservations_passengers ADD CONSTRAINT rp_passengers_fk   FOREIGN KEY (passengers_id)   REFERENCES passengers (id);


CREATE TABLE payments (
                        id                NUMBER(5)   NOT NULL,
                        payment_date      DATE        NOT NULL,
                        payment_status_id NUMBER      NOT NULL,
                        payment_amount    NUMBER(9,2),
                        currency_code     VARCHAR2(3)   NOT NULL,
                        reservations_id   NUMBER(5)    NOT NULL
);
ALTER TABLE payments ADD CONSTRAINT payments_pk             PRIMARY KEY (id);
ALTER TABLE payments ADD CONSTRAINT payments_payment_status_fk FOREIGN KEY (payment_status_id) REFERENCES payment_status (payment_status_id);
ALTER TABLE payments ADD CONSTRAINT payments_currency_fk    FOREIGN KEY (currency_code)       REFERENCES currency (code);
ALTER TABLE payments ADD CONSTRAINT payments_amount_chk     CHECK (payment_amount IS NULL OR payment_amount >= 0);
ALTER TABLE payments ADD CONSTRAINT payments_reservations_fk FOREIGN KEY (reservations_id) REFERENCES reservations (id);


CREATE TABLE reservations_extra_services (
                                            reservations_id   NUMBER(5) NOT NULL,
                                            extra_services_id NUMBER(4) NOT NULL,
                                            passenger_id      NUMBER(5) NOT NULL
);
ALTER TABLE reservations_extra_services ADD CONSTRAINT reservs_extra_servs_pk PRIMARY KEY (reservations_id, extra_services_id, passenger_id);
ALTER TABLE reservations_extra_services ADD CONSTRAINT res_reservations_fk    FOREIGN KEY (reservations_id)   REFERENCES reservations (id);
ALTER TABLE reservations_extra_services ADD CONSTRAINT res_extra_services_fk  FOREIGN KEY (extra_services_id) REFERENCES extra_services (id);
ALTER TABLE reservations_extra_services ADD CONSTRAINT res_passenger_fk       FOREIGN KEY (passenger_id)      REFERENCES passengers (id);


CREATE TABLE boarding_pass (
                                reservations_id            NUMBER(5) NOT NULL,
                                passengers_id              NUMBER(5) NOT NULL,
                                seats_id                   NUMBER(5) NOT NULL,
                                serial_number              NUMBER(4) NOT NULL,
                                departure_airport_code     VARCHAR2(3),
                                arrival_airport_code       VARCHAR2(3),
                                flight_departure_date_time TIMESTAMP WITH TIME ZONE,
                                passenger_first_name       VARCHAR2(128),
                                passenger_last_name        VARCHAR2(128),
                                seat_row                   NUMBER(2),
                                seat_col                   NUMBER(1)
);
ALTER TABLE boarding_pass ADD CONSTRAINT boarding_pass_pk             PRIMARY KEY (seats_id, serial_number, reservations_id, passengers_id);
ALTER TABLE boarding_pass ADD CONSTRAINT boarding_pass_reservations_fk FOREIGN KEY (reservations_id) REFERENCES reservations (id);
ALTER TABLE boarding_pass ADD CONSTRAINT boarding_pass_passengers_fk   FOREIGN KEY (passengers_id)   REFERENCES passengers (id);
ALTER TABLE boarding_pass ADD CONSTRAINT boarding_pass_seats_fk       FOREIGN KEY (seats_id, serial_number) REFERENCES seats (id, serial_number);
ALTER TABLE boarding_pass ADD CONSTRAINT bp_dep_code_len_chk          CHECK (departure_airport_code IS NULL OR LENGTH(departure_airport_code) = 3);
ALTER TABLE boarding_pass ADD CONSTRAINT bp_arr_code_len_chk          CHECK (arrival_airport_code IS NULL OR LENGTH(arrival_airport_code) = 3);
ALTER TABLE boarding_pass ADD CONSTRAINT bp_different_airports_chk    CHECK (departure_airport_code != arrival_airport_code);
ALTER TABLE boarding_pass ADD CONSTRAINT bp_seat_row_chk              CHECK (seat_row IS NULL OR seat_row >= 1);
ALTER TABLE boarding_pass ADD CONSTRAINT bp_seat_col_chk              CHECK (seat_col IS NULL OR (seat_col >= 1 AND seat_col <= 9));

