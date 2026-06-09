-- generowanie miejsc przy dodaniu samolotu

CREATE OR REPLACE TRIGGER planes_generate_seats
AFTER INSERT ON planes
FOR EACH ROW
DECLARE
v_id        NUMBER;
    v_seat_type NUMBER;
    v_class_id  NUMBER;
    v_full_rows NUMBER := TRUNC(:new.seat_count / 6);
    v_remainder NUMBER := MOD(:new.seat_count, 6);

    PROCEDURE insert_seat(p_row NUMBER, p_col NUMBER) IS
BEGIN
        v_id := v_id + 1;
CASE p_col
            WHEN 1 THEN v_seat_type := 1;
WHEN 6 THEN v_seat_type := 1;
WHEN 2 THEN v_seat_type := 2;
WHEN 5 THEN v_seat_type := 2;
ELSE        v_seat_type := 3;
END CASE;
        IF p_row <= 2 THEN v_class_id := 3; ELSE v_class_id := 1; END IF;
INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id)
VALUES (v_id, p_row, p_col, :new.serial_number, v_seat_type, v_class_id);
END;
BEGIN
SELECT NVL(MAX(id), 0) INTO v_id FROM seats;

FOR r IN 1 .. v_full_rows LOOP
        FOR c IN 1 .. 6 LOOP
            insert_seat(r, c);
END LOOP;
END LOOP;

    IF v_remainder > 0 THEN
        FOR c IN 1 .. v_remainder LOOP
            insert_seat(v_full_rows + 1, c);
END LOOP;
END IF;
END;
/

-- kolumna wyliczana payment amount

CREATE OR REPLACE TRIGGER payment_calculation
BEFORE INSERT OR UPDATE ON payments
FOR EACH ROW
DECLARE
    v_flight_price flights.price%TYPE;
    v_extra_sum NUMBER(9,2);
BEGIN
    SELECT (f.price * r.number_in_party) INTO v_flight_price
    FROM flights f
    JOIN reservations r ON f.id = r.flights_id
    WHERE r.id = :new.reservations_id;

    SELECT NVL(SUM(es.price), 0) INTO v_extra_sum
    FROM extra_services es
    JOIN reservations_extra_services res ON es.id = res.extra_services_id
    WHERE res.reservations_id = :new.reservations_id;

    :new.payment_amount := v_flight_price + v_extra_sum;
END;
/

-- pre-joiny kluczy obcych

CREATE OR REPLACE TRIGGER prejoin_payments
BEFORE INSERT OR UPDATE OF currency_code ON payments
FOR EACH ROW
BEGIN
    SELECT f.CURRENCY_CODE INTO :new.CURRENCY_CODE
    FROM FLIGHTS f
    JOIN RESERVATIONS r on r.FLIGHTS_ID = f.ID
    WHERE r.ID = :new.RESERVATIONS_ID;
END;
/

CREATE OR REPLACE TRIGGER prejoin_flights
BEFORE INSERT OR UPDATE OF serial_number ON flights
FOR EACH ROW
BEGIN
    SELECT airlines_id INTO :new.airlines_id
    FROM planes
    WHERE serial_number = :new.serial_number;
END;
/

-- pre-joiny atrybutów

CREATE OR REPLACE TRIGGER prejoin_flights_seat_count
BEFORE INSERT OR UPDATE OF serial_number ON flights
FOR EACH ROW
BEGIN
    SELECT seat_count INTO :new.p_seat_count
    FROM planes
    WHERE serial_number = :new.serial_number;
END;
/

CREATE OR REPLACE TRIGGER prejoin_boarding_pass
BEFORE INSERT ON boarding_pass
FOR EACH ROW
DECLARE
    v_passenger_name passengers.first_name%TYPE;
    v_passenger_last_name passengers.last_name%TYPE;
    v_seat_row seats.row_nr%TYPE;
    v_seat_col seats.column_nr%TYPE;
    v_flight_dep_time flights.departure_date_time%TYPE;
    v_origin_code airports.airport_code%TYPE;
    v_dest_code airports.airport_code%TYPE;
BEGIN
    SELECT p.first_name, p.last_name INTO v_passenger_name, v_passenger_last_name
    FROM passengers p
    JOIN reservations_passengers rp ON p.id = rp.passengers_id
    WHERE rp.reservations_id = :new.reservations_id AND rp.passengers_id = :new.passengers_id;

    SELECT row_nr, column_nr INTO v_seat_row, v_seat_col
    FROM seats
    WHERE id = :new.seats_id and serial_number = :new.serial_number;

    SELECT f.departure_date_time INTO v_flight_dep_time
    FROM flights f
    JOIN reservations r ON f.id = r.flights_id
    WHERE r.id = :new.reservations_id;

    SELECT a1.airport_code, a2.airport_code INTO v_origin_code, v_dest_code
    FROM flights f
    JOIN routes rt ON f.routes_id = rt.id
    JOIN airports a1 ON rt.origin_airport_id = a1.id
    JOIN airports a2 ON rt.destination_airport_id = a2.id
    JOIN reservations r ON f.id = r.flights_id
    WHERE r.id = :new.reservations_id;

    :new.passenger_first_name := v_passenger_name;
    :new.passenger_last_name := v_passenger_last_name;
    :new.seat_row := v_seat_row;
    :new.seat_col := v_seat_col;
    :new.flight_departure_date_time := v_flight_dep_time;
    :new.arrival_airport_code := v_dest_code;
    :new.departure_airport_code := v_origin_code;
END;
/

-- kolumny agregujące

CREATE OR REPLACE TRIGGER flights_booked_seats_I
BEFORE INSERT ON reservations_passengers
FOR EACH ROW
BEGIN
    UPDATE flights
    SET booked_seats_count = NVL(booked_seats_count, 0) + 1
    WHERE id = (SELECT flights_id FROM reservations WHERE id = :new.reservations_id);
END;
/

CREATE OR REPLACE TRIGGER flights_booked_seats_D
BEFORE DELETE ON reservations_passengers
FOR EACH ROW
BEGIN
    UPDATE flights
    SET booked_seats_count = NVL(booked_seats_count, 0) - 1
    WHERE id = (SELECT flights_id FROM reservations WHERE id = :old.reservations_id);
END;
/

CREATE OR REPLACE TRIGGER flights_booked_seats_U
BEFORE UPDATE OF reservations_id ON reservations_passengers
FOR EACH ROW
BEGIN
    UPDATE flights
    SET booked_seats_count = NVL(booked_seats_count, 0) - 1
    WHERE id = (SELECT flights_id FROM reservations WHERE id = :old.reservations_id);

    UPDATE flights
    SET booked_seats_count = NVL(booked_seats_count, 0) + 1
    WHERE id = (SELECT flights_id FROM reservations WHERE id = :new.reservations_id);
END;
/
-- tabela agregująca

CREATE OR REPLACE TRIGGER route_statistics_count_passengers_I
AFTER INSERT ON reservations_passengers
FOR EACH ROW
DECLARE
    v_route_id routes.id%TYPE;
    v_departure_time flights.departure_date_time%TYPE;
    v_year NUMBER(4);
    v_month NUMBER(2);
BEGIN
    SELECT f.routes_id, f.departure_date_time INTO v_route_id, v_departure_time
    FROM flights f
    JOIN reservations r ON f.id = r.flights_id
    WHERE r.id = :new.reservations_id;

    v_year := EXTRACT(YEAR FROM v_departure_time);
    v_month := EXTRACT(MONTH FROM v_departure_time);

    -- całkowita statystyka
    UPDATE route_statistics
    SET total_passengers = NVL(total_passengers, 0) + 1
    WHERE routes_id = v_route_id AND year = 0 AND month = 0;

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO route_statistics (routes_id, year, month, total_passengers, total_revenue)
        VALUES (v_route_id, 0, 0, 1, 0);
    END IF;

    -- statystyka roczna
    UPDATE route_statistics
    SET total_passengers = NVL(total_passengers, 0) + 1
    WHERE routes_id = v_route_id AND year = v_year AND month = 0;

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO route_statistics (routes_id, year, month, total_passengers, total_revenue)
        VALUES (v_route_id, v_year, 0, 1, 0);
    END IF;

    -- statystyka miesięczna
    UPDATE route_statistics
    SET total_passengers = NVL(total_passengers, 0) + 1
    WHERE routes_id = v_route_id AND year = v_year AND month = v_month;

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO route_statistics (routes_id, year, month, total_passengers, total_revenue)
        VALUES (v_route_id, v_year, v_month, 1, 0);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER route_statistics_count_revenue_I
AFTER INSERT ON payments
FOR EACH ROW
DECLARE
    v_route_id routes.id%TYPE;
    v_departure_time flights.departure_date_time%TYPE;
    v_year NUMBER(4);
    v_month NUMBER(2);
BEGIN
    SELECT f.routes_id, f.departure_date_time
    INTO v_route_id, v_departure_time
    FROM reservations r
    JOIN flights f ON r.flights_id = f.id
    WHERE r.id = :new.reservations_id;

    v_year := EXTRACT(YEAR FROM v_departure_time);
    v_month := EXTRACT(MONTH FROM v_departure_time);

    UPDATE route_statistics
    SET total_revenue = NVL(total_revenue, 0) + :new.payment_amount
    WHERE routes_id = v_route_id
    AND ((year = 0 AND month = 0)
    OR (year = v_year AND month = 0)
    OR (year = v_year AND month = v_month));
END;
/
