CREATE OR REPLACE PROCEDURE create_reservation (
    p_user_id IN NUMBER,
    p_flight_id IN NUMBER,
    p_passenger_count IN NUMBER,
    p_new_reservation_id OUT NUMBER
) AS
BEGIN
    INSERT INTO reservations (reservation_date, number_in_party, user_id, flights_id)
    VALUES (SYSDATE, p_passenger_count, p_user_id, p_flight_id)
    RETURNING id INTO p_new_reservation_id;
END;
/

CREATE OR REPLACE PROCEDURE add_passenger_and_boarding_pass (
    p_reservation_id IN NUMBER,
    p_flight_id IN NUMBER,
    p_first_name IN VARCHAR2,
    p_last_name IN VARCHAR2,
    p_seat_row IN NUMBER,
    p_seat_col IN NUMBER,
    p_new_passenger_id OUT NUMBER
) AS
    v_seat_id NUMBER;
    v_serial_number NUMBER;
BEGIN
    SELECT serial_number INTO v_serial_number FROM flights WHERE id = p_flight_id;

    BEGIN
        SELECT id INTO v_seat_id FROM seats
        WHERE serial_number = v_serial_number AND row_nr = p_seat_row AND column_nr = p_seat_col;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'Seat not found for the given flight and seat position.');
    END;

    INSERT INTO passengers (first_name, last_name)
    VALUES (TRIM(p_first_name), TRIM(p_last_name))
    RETURNING id INTO p_new_passenger_id;

    INSERT INTO reservations_passengers (reservations_id, passengers_id)
    VALUES (p_reservation_id, p_new_passenger_id);

    INSERT INTO boarding_pass (reservations_id, passengers_id, seats_id, serial_number, seat_row, seat_col)
    VALUES (p_reservation_id, p_new_passenger_id, v_seat_id, v_serial_number, p_seat_row, p_seat_col);
END;
/

CREATE OR REPLACE PROCEDURE cancel_reservation (
    p_reservation_id IN NUMBER,
    p_user_id IN NUMBER
) AS
    v_departure_date TIMESTAMP WITH TIME ZONE;
    v_payment_status NUMBER;
    v_currency_code VARCHAR2(3);
    v_number_in_party NUMBER;
    v_flight_id NUMBER;
BEGIN

    SELECT f.departure_date_time, f.currency_code, r.number_in_party, f.id
    INTO v_departure_date, v_currency_code, v_number_in_party, v_flight_id
    FROM reservations r
    JOIN flights f ON r.flights_id = f.id
    WHERE r.id = p_reservation_id;

    IF SYSDATE + INTERVAL '1' DAY > v_departure_date THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cannot cancel: less than 24 hours before departure');
    END IF;

    SELECT payment_status_id INTO v_payment_status FROM payments
    WHERE reservations_id = p_reservation_id;

    IF v_payment_status != 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Reservation is already paid or cancelled');
    END IF;

    DELETE FROM boarding_pass WHERE reservations_id = p_reservation_id;
    DELETE FROM reservations_extra_services WHERE reservations_id = p_reservation_id;
    DELETE FROM reservations_passengers WHERE reservations_id = p_reservation_id;

    UPDATE payments SET payment_status_id = 5 WHERE reservations_id = p_reservation_id;

    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE pay_for_reservation (
    p_reservation_id IN NUMBER,
    p_user_id IN NUMBER
) AS
    v_departure_date TIMESTAMP WITH TIME ZONE;
    v_payment_status NUMBER;
    v_currency_code VARCHAR2(3);
    v_number_in_party NUMBER;
    v_flight_id NUMBER;
BEGIN

    SELECT f.departure_date_time, f.currency_code, r.number_in_party, f.id
    INTO v_departure_date, v_currency_code, v_number_in_party, v_flight_id
    FROM reservations r
    JOIN flights f ON r.flights_id = f.id
    WHERE r.id = p_reservation_id;

    IF SYSDATE > v_departure_date THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cannot pay for past reservation');
    END IF;

    SELECT payment_status_id INTO v_payment_status FROM payments
    WHERE reservations_id = p_reservation_id;

    IF v_payment_status != 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Reservation is already paid or cancelled');
    END IF;

    UPDATE payments SET payment_status_id = 1 WHERE reservations_id = p_reservation_id;

    COMMIT;
END;
/