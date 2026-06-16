SET SERVEROUTPUT ON;

-- create_reservation
DECLARE
    v_res_id       NUMBER;
    v_party_count  NUMBER;
    v_pay_status   NUMBER;
    v_pay_amount   NUMBER(9,2);
BEGIN
    create_reservation(1, 1, 1, 299.00, 'EUR', v_res_id);

    SELECT number_in_party INTO v_party_count FROM reservations WHERE id = v_res_id;

    SELECT payment_status_id, payment_amount INTO v_pay_status, v_pay_amount
    FROM payments
    WHERE reservations_id = v_res_id;

    IF v_party_count = 1 AND v_pay_status = 1 AND v_pay_amount = 299.00 THEN
        DBMS_OUTPUT.PUT_LINE('OK: Rezerwacja (ID: '||v_res_id||') i płatność oczekująca zostały utworzone.');
    ELSE
        RAISE_APPLICATION_ERROR(-20401, 'FAIL: create_reservation utworzyła niepoprawne dane.');
    END IF;

    ROLLBACK;
END;
/

-- add_passenger_and_boarding_pass
DECLARE
    v_res_id       NUMBER;
    v_pass_id      NUMBER;
    v_bp_count     NUMBER;
    v_first        VARCHAR2(128);
BEGIN
    create_reservation(1, 1, 1, 299.00, 'EUR', v_res_id);

    add_passenger_and_boarding_pass(v_res_id, 1, 'Zenon   ', '   Nowak ', 1, 1, v_pass_id);

    SELECT first_name INTO v_first FROM passengers WHERE id = v_pass_id;

    SELECT COUNT(*) INTO v_bp_count
    FROM boarding_pass
    WHERE reservations_id = v_res_id AND passengers_id = v_pass_id;

    IF v_first = 'Zenon' AND v_bp_count = 1 THEN
        DBMS_OUTPUT.PUT_LINE('OK: Pasażer został dodany, karta pokładowa wygenerowana.');
    ELSE
        RAISE_APPLICATION_ERROR(-20402, 'FAIL: Błąd podczas dodawania pasażera lub karty pokładowej.');
    END IF;

    ROLLBACK;
END;
/

-- pay_for_reservation
DECLARE
    v_res_id     NUMBER;
    v_pay_status NUMBER;
BEGIN
    UPDATE flights
    SET departure_date_time = TIMESTAMP '2028-06-01 06:00:00 +02:00',
        arrival_date_time   = TIMESTAMP '2028-06-01 07:45:00 +02:00'
    WHERE id = 1;

    create_reservation(1, 1, 1, 299.00, 'EUR', v_res_id);
    COMMIT;

    pay_for_reservation(v_res_id, 1);

    SELECT payment_status_id INTO v_pay_status FROM payments WHERE reservations_id = v_res_id;

    IF v_pay_status = 2 THEN
        DBMS_OUTPUT.PUT_LINE('OK: Rezerwacja została pomyślnie opłacona (status zmieniony na Completed).');
    ELSE
        RAISE_APPLICATION_ERROR(-20403, 'FAIL: Status płatności to: '||v_pay_status||' zamiast 2.');
    END IF;

    DELETE FROM payments WHERE reservations_id = v_res_id;
    DELETE FROM reservations WHERE id = v_res_id;
    UPDATE flights
    SET departure_date_time = TIMESTAMP '2026-06-01 06:00:00 +02:00',
        arrival_date_time   = TIMESTAMP '2026-06-01 07:45:00 +02:00'
    WHERE id = 1;

    COMMIT;
END;
/

-- cancel_reservation
DECLARE
    v_res_id     NUMBER;
    v_pass_id    NUMBER;
    v_pay_status NUMBER;
    v_bp_count   NUMBER;
BEGIN
    UPDATE flights
    SET departure_date_time = TIMESTAMP '2028-06-01 06:00:00 +02:00',
        arrival_date_time   = TIMESTAMP '2028-06-01 07:45:00 +02:00'
    WHERE id = 1;

    create_reservation(1, 1, 1, 299.00, 'EUR', v_res_id);
    add_passenger_and_boarding_pass(v_res_id, 1, 'Jan', 'Testowy', 1, 2, v_pass_id);
    COMMIT;

    cancel_reservation(v_res_id, 1);

    SELECT COUNT(*) INTO v_bp_count FROM boarding_pass WHERE reservations_id = v_res_id;

    SELECT payment_status_id INTO v_pay_status FROM payments WHERE reservations_id = v_res_id;

    IF v_bp_count = 0 AND v_pay_status = 6 THEN
        DBMS_OUTPUT.PUT_LINE('OK: Rezerwacja anulowana. Bilet usunięty, status płatności zmieniony na Cancelled.');
    ELSE
        RAISE_APPLICATION_ERROR(-20404, 'FAIL: Błędy podczas anulowania rezerwacji.');
    END IF;

    DELETE FROM payments WHERE reservations_id = v_res_id;
    DELETE FROM reservations_passengers WHERE reservations_id = v_res_id;
    DELETE FROM passengers WHERE id = v_pass_id;
    DELETE FROM reservations WHERE id = v_res_id;
    UPDATE flights
    SET departure_date_time = TIMESTAMP '2026-06-01 06:00:00 +02:00',
        arrival_date_time   = TIMESTAMP '2026-06-01 07:45:00 +02:00'
    WHERE id = 1;

    COMMIT;
END;
/

-- cancel_reservation - mniej niż 24h przed odlotem
DECLARE
    v_res_id         NUMBER;
    v_error_code     NUMBER;
    v_test_failed    BOOLEAN := FALSE;
BEGIN
    INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, airlines_id, currency_code)
    VALUES (9999, CURRENT_TIMESTAMP + INTERVAL '2' HOUR, CURRENT_TIMESTAMP + INTERVAL '4' HOUR, 1, 1001, 100.00, 6, 'EUR');

    create_reservation(1, 9999, 1, 100.00, 'EUR', v_res_id);
    COMMIT;

    BEGIN
        cancel_reservation(v_res_id, 1);

        v_test_failed := TRUE;
    EXCEPTION
        WHEN OTHERS THEN
            v_error_code := SQLCODE;

            IF v_error_code = -20002 THEN
                DBMS_OUTPUT.PUT_LINE('OK: Baza prawidłowo zablokowała anulowanie lotu tuż przed odlotem.');
            ELSE
                DELETE FROM payments WHERE reservations_id = v_res_id;
                DELETE FROM reservations WHERE id = v_res_id;
                DELETE FROM flights WHERE id = 9999;
                COMMIT;
                RAISE;
            END IF;
    END;

    DELETE FROM payments WHERE reservations_id = v_res_id;
    DELETE FROM reservations WHERE id = v_res_id;
    DELETE FROM flights WHERE id = 9999;
    COMMIT;

    IF v_test_failed THEN
        RAISE_APPLICATION_ERROR(-20405, 'FAIL: Baza pozwoliła anulować lot na mniej niż 24h przed odlotem.');
    END IF;
END;
/