CREATE OR REPLACE PROCEDURE create_reservation (
    p_user_id IN NUMBER,
    p_flight_id IN NUMBER,
    p_passenger_count IN NUMBER,
    p_calculated_price IN NUMBER,
    p_currency_code IN VARCHAR2,
    p_new_reservation_id OUT NUMBER
) AS
BEGIN
    INSERT INTO reservations (reservation_date, number_in_party, user_id, flights_id)
    VALUES (SYSDATE, p_passenger_count, p_user_id, p_flight_id)
    RETURNING id INTO p_new_reservation_id;

    INSERT INTO payments (payment_date, payment_status_id, payment_amount, currency_code, reservations_id)
    VALUES (SYSDATE, 1, p_calculated_price, p_currency_code, p_new_reservation_id);
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

    INSERT INTO boarding_pass (reservations_id, passengers_id, seats_id, serial_number, passenger_first_name, passenger_last_name, seat_row, seat_col)
    VALUES (p_reservation_id, p_new_passenger_id, v_seat_id, v_serial_number, TRIM(p_first_name), TRIM(p_last_name), p_seat_row, p_seat_col);
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

    IF v_payment_status != 1 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Reservation is already paid or cancelled');
    END IF;

    DELETE FROM boarding_pass WHERE reservations_id = p_reservation_id;
    DELETE FROM reservations_extra_services WHERE reservations_id = p_reservation_id;
    DELETE FROM reservations_passengers WHERE reservations_id = p_reservation_id;

    UPDATE payments SET payment_status_id = 6 WHERE reservations_id = p_reservation_id;

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

    IF v_payment_status != 1 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Reservation is already paid or cancelled');
    END IF;

    UPDATE payments SET payment_status_id = 2 WHERE reservations_id = p_reservation_id;

    COMMIT;
END;
/

-- ── Procedury analityczne ────────────────────────────────────────────────────

-- Obłożenie lotów z opcjonalnymi filtrami (airline, route, year, month)
-- Zastępuje dynamiczne budowanie SQL w Javie — bezpieczniejsze i stabilniejszy plan
CREATE OR REPLACE PROCEDURE get_occupancy (
    p_airline_id IN NUMBER   DEFAULT NULL,
    p_route_id   IN NUMBER   DEFAULT NULL,
    p_year       IN NUMBER   DEFAULT NULL,
    p_month      IN NUMBER   DEFAULT NULL,
    p_result     OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_result FOR
        SELECT flight_id, departure_date_time, arrival_date_time,
               origin_code, origin_name, dest_code, dest_name,
               airline_id, airline_name, plane_model,
               booked_seats, total_seats, occupancy_pct,
               dep_year, dep_month, price, currency_code
        FROM v_flight_occupancy
        WHERE (p_airline_id IS NULL OR airline_id = p_airline_id)
          AND (p_route_id IS NULL   OR flight_id IN (
                  SELECT id FROM flights WHERE routes_id = p_route_id))
          AND (p_year IS NULL       OR dep_year = p_year)
          AND (p_month IS NULL      OR dep_month = p_month)
        ORDER BY departure_date_time ASC;
END;
/

-- Sezonowość tras z opcjonalnymi filtrami (year, origin_code, dest_code)
CREATE OR REPLACE PROCEDURE get_route_seasonality (
    p_year        IN NUMBER   DEFAULT NULL,
    p_origin_code IN VARCHAR2 DEFAULT NULL,
    p_dest_code   IN VARCHAR2 DEFAULT NULL,
    p_result      OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_result FOR
        SELECT rs.routes_id AS route_id,
               oa.airport_code AS origin_code, oc.name AS origin_city,
               da.airport_code AS dest_code,   dc.name AS dest_city,
               rs.year  AS dep_year,
               rs.month AS dep_month,
               rs.total_passengers,
               rs.total_revenue
        FROM route_statistics rs
        JOIN routes r    ON r.id  = rs.routes_id
        JOIN airports oa ON oa.id = r.origin_airport_id
        JOIN city oc     ON oc.id = oa.city_id
        JOIN airports da ON da.id = r.destination_airport_id
        JOIN city dc     ON dc.id = da.city_id
        WHERE rs.month > 0 AND rs.year > 0
          AND (p_year IS NULL        OR rs.year = p_year)
          AND (p_origin_code IS NULL OR oa.airport_code = UPPER(p_origin_code))
          AND (p_dest_code IS NULL   OR da.airport_code = UPPER(p_dest_code))
        ORDER BY rs.year ASC, rs.month ASC, rs.total_passengers DESC NULLS LAST;
END;
/