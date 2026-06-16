SET SERVEROUTPUT ON;

-- planes_create_seats
DECLARE
    v_seat_count NUMBER;
    v_test_serial NUMBER := 8888;
BEGIN
    INSERT INTO planes (serial_number, model, seat_count, load_capacity, fuel_capacity, airlines_id)
    VALUES (v_test_serial, 'A123', 10, 5000, 20000, 1);

    SELECT COUNT(*) INTO v_seat_count
    FROM seats
    WHERE serial_number = v_test_serial;

    IF v_seat_count = 10 THEN
        DBMS_OUTPUT.PUT_LINE('OK: Trigger poprawnie wygenerował 10 foteli.');
    ELSE
        RAISE_APPLICATION_ERROR(-20101, 'FAIL: Oczekiwano 10 foteli, wygenerowano: ' || v_seat_count);
    END IF;

    ROLLBACK;
END;
/

-- payment_calculation i prejoin_payments
DECLARE
    v_payment_amount payments.payment_amount%TYPE;
    v_currency_code  payments.currency_code%TYPE;
BEGIN
    INSERT INTO payments (id, payment_date, payment_status_id, reservations_id)
    VALUES (9999, SYSDATE, 1, 1);

    SELECT payment_amount, currency_code INTO v_payment_amount, v_currency_code
    FROM payments
    WHERE id = 9999;

    IF v_payment_amount = 613.00 AND v_currency_code = 'EUR' THEN
        DBMS_OUTPUT.PUT_LINE('OK: poprawnie wyliczono kwotę: ' || v_payment_amount || ' ' || v_currency_code);
    ELSE
        RAISE_APPLICATION_ERROR(-20102, 'FAIL: Błędne wyliczenie płatności. Kwota: ' || v_payment_amount || ', Waluta: ' || v_currency_code);
    END IF;

    ROLLBACK;
END;
/

-- prejoin_flights i prejoin_flights_seat_count
DECLARE
    v_airlines_id flights.airlines_id%TYPE;
    v_seat_count  flights.p_seat_count%TYPE;
BEGIN
    INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, airlines_id, currency_code, p_seat_count)
    VALUES (9999, TIMESTAMP '2026-09-01 10:00:00 +02:00', TIMESTAMP '2026-09-01 12:00:00 +02:00', 1, 1001, 100.00, 0, 'EUR', 0);

    SELECT airlines_id, p_seat_count INTO v_airlines_id, v_seat_count
    FROM flights
    WHERE id = 9999;

    IF v_airlines_id = 6 AND v_seat_count = 189 THEN
        DBMS_OUTPUT.PUT_LINE('OK: Prejoiny poprawnie uzupełniły linie lotnicze (ID: '||v_airlines_id||') i liczbę miejsc ('||v_seat_count||').');
    ELSE
        RAISE_APPLICATION_ERROR(-20103, 'FAIL: Prejoiny lotu przydzieliły złe dane. Linia: '||v_airlines_id||', Miejsca: '||v_seat_count);
    END IF;

    ROLLBACK;
END;
/

-- flights_booked_seats
DECLARE
    v_count_before NUMBER;
    v_count_after  NUMBER;
BEGIN
    SELECT booked_seats_count INTO v_count_before FROM flights WHERE id = 2;

    INSERT INTO reservations_passengers (reservations_id, passengers_id)
    VALUES (2, 12);

    SELECT booked_seats_count INTO v_count_after FROM flights WHERE id = 2;

    IF v_count_after > v_count_before THEN
        DBMS_OUTPUT.PUT_LINE('OK: Licznik booked_seats_count zwiększył się poprawnie z '||v_count_before||' do '||v_count_after||'.');
    ELSE
        RAISE_APPLICATION_ERROR(-20104, 'FAIL: Licznik miejsc nie drgnął! Przed: '||v_count_before||', Po: '||v_count_after);
    END IF;


    SELECT booked_seats_count INTO v_count_before FROM flights WHERE id = 1;
    DELETE FROM reservations_passengers WHERE reservations_id = 1 AND passengers_id = 11;
    SELECT booked_seats_count INTO v_count_after FROM flights WHERE id = 1;

    IF v_count_after = v_count_before - 1 THEN
        DBMS_OUTPUT.PUT_LINE('OK: Trigger _D poprawnie zmniejszył licznik miejsc o 1.');
    ELSE
        RAISE_APPLICATION_ERROR(-20206, 'FAIL: Trigger _D nie zmniejszył licznika! Przed: '||v_count_before||', Po: '||v_count_after);
    END IF;


    SELECT booked_seats_count INTO v_count_before FROM flights WHERE id = 2;

    UPDATE reservations_passengers
    SET reservations_id = 2
    WHERE reservations_id = 1 AND passengers_id = 1;

    SELECT booked_seats_count INTO v_count_after FROM flights WHERE id = 2;

    IF v_count_after = v_count_before + 1 THEN
        DBMS_OUTPUT.PUT_LINE('OK: Trigger _U poprawnie zwiększył licznik lotu docelowego o 1.');
    ELSE
        RAISE_APPLICATION_ERROR(-20207, 'FAIL: Trigger _U nie zaktualizował liczników poprawnie!');
    END IF;

    ROLLBACK;
END;
/

-- route_statistics_count_passengers_I
DECLARE
    v_stat_global NUMBER;
    v_stat_month  NUMBER;
BEGIN
    INSERT INTO reservations_passengers (reservations_id, passengers_id)
    VALUES (1, 12);

    SELECT total_passengers INTO v_stat_global
    FROM route_statistics
    WHERE routes_id = 1 AND year = 0 AND month = 0;

    SELECT total_passengers INTO v_stat_month
    FROM route_statistics
    WHERE routes_id = 1 AND year = 2026 AND month = 6;

    IF v_stat_global >= 1 AND v_stat_month >= 1 THEN
        DBMS_OUTPUT.PUT_LINE('OK: Statystyki tras automatycznie zaagregowały nowego pasażera.');
    ELSE
        RAISE_APPLICATION_ERROR(-20105, 'FAIL: Brak aktualizacji w tabeli route_statistics!');
    END IF;

    ROLLBACK;
END;
/

-- route_statistics_count_revenue_I
DECLARE
    v_rev_before NUMBER(14,2);
    v_rev_after  NUMBER(14,2);
BEGIN

    BEGIN
        SELECT total_revenue INTO v_rev_before
        FROM route_statistics
        WHERE routes_id = 1 AND year = 2026 AND month = 6;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_rev_before := 0;
    END;

    INSERT INTO payments (id, payment_date, payment_status_id, currency_code, payment_amount, reservations_id)
    VALUES (9999, SYSDATE, 2, 'EUR', 500.00, 1);

    SELECT total_revenue INTO v_rev_after
    FROM route_statistics
    WHERE routes_id = 1 AND year = 2026 AND month = 6;

    IF v_rev_after > v_rev_before THEN
        DBMS_OUTPUT.PUT_LINE('OK: Finanse trasy automatycznie wzrosły z kwoty '||v_rev_before||' do '||v_rev_after||'.');
    ELSE
        RAISE_APPLICATION_ERROR(-20208, 'FAIL: Statystyki przychodów nie zsumowały płatności! Przed: '||v_rev_before||', Po: '||v_rev_after);
    END IF;

    ROLLBACK;
END;
/

-- prejoin_boarding_pass
DECLARE
    v_bp boarding_pass%ROWTYPE;
BEGIN
    INSERT INTO boarding_pass (reservations_id, passengers_id, seats_id, serial_number)
    VALUES (3, 13, 10, 1001);

    SELECT * INTO v_bp
    FROM boarding_pass
    WHERE reservations_id = 3 AND passengers_id = 13 AND seats_id = 10;

    IF v_bp.passenger_first_name = 'Ewa' AND v_bp.departure_airport_code = 'WAW' AND v_bp.arrival_airport_code = 'LHR' THEN
        DBMS_OUTPUT.PUT_LINE('OK: Karta pokładowa została automatycznie wypełniona danymi: '
                             || v_bp.passenger_first_name || ' ' || v_bp.passenger_last_name
                             || ' [' || v_bp.departure_airport_code || ' -> ' || v_bp.arrival_airport_code || ']');
    ELSE
        RAISE_APPLICATION_ERROR(-20209, 'FAIL: Karta pokładowa zawiera puste lub błędne dane po autouzupełnieniu!');
    END IF;

    ROLLBACK;
END;
/

-- prejoin_boarding_pass - nieistniejący pasażer
DECLARE
    v_error_code NUMBER;
BEGIN
    INSERT INTO boarding_pass (reservations_id, passengers_id, seats_id, serial_number)
    VALUES (1, 999, 7, 1001);

    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20210, 'FAIL: Baza pozwoliła wygenerować bilet dla nieprzypisanego pasażera.');
EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        IF v_error_code = -20001 THEN
            DBMS_OUTPUT.PUT_LINE('OK: Trigger prawidłowo wyrzucił błąd braku pasażera.');
            ROLLBACK;
        END IF;
END;
/
