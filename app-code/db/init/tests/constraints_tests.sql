SET SERVEROUTPUT ON;

-- data przylotu przed odlotem
DECLARE
    v_error_code NUMBER;
BEGIN
    INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, currency_code)
    VALUES (9999,
            TIMESTAMP '2026-06-15 14:00:00 +02:00',
            TIMESTAMP '2026-06-15 11:00:00 +02:00',
            1, 1001, 150.00, 'EUR');

    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20001, 'FAIL: Baza pozwoliła na przylot przed odlotem.');
EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        IF v_error_code = -2290 THEN
            DBMS_OUTPUT.PUT_LINE('OK: Baza prawidłowo zablokowała niepoprawne daty lotu.');
            ROLLBACK;
        ELSE
            ROLLBACK;
            RAISE;
        END IF;
END;
/


-- lot z tego samego miejsca do tego samego miejsca
DECLARE
    v_error_code NUMBER;
BEGIN
    INSERT INTO routes (id, origin_airport_id, destination_airport_id)
    VALUES (9999, 1, 1);

    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20002, 'FAIL: Baza pozwoliła na nieprawidłowy lot.');
EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        IF v_error_code = -2290 THEN
            DBMS_OUTPUT.PUT_LINE('OK: Baza prawidłowo zablokowała niemożliwy lot.');
            ROLLBACK;
        ELSE
            ROLLBACK;
            RAISE;
        END IF;
END;
/


-- niepoprawny format email)
DECLARE
    v_error_code NUMBER;
BEGIN
    INSERT INTO users (id, email_address, password, is_admin)
    VALUES (9999, 'email.pl', 'haslo1234', 0);

    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20003, 'FAIL: Baza pozwoliła na zapisanie niepoprawnego formatu e-mail.');
EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        IF v_error_code = -2290 THEN
            DBMS_OUTPUT.PUT_LINE('OK: Baza prawidłowo odrzuciła adres e-mail bez małpki.');
            ROLLBACK;
        ELSE
            ROLLBACK;
            RAISE;
        END IF;
END;
/

--  za krótkie hasło
DECLARE
    v_error_code NUMBER;
BEGIN
    INSERT INTO users (id, email_address, password, is_admin)
    VALUES (9999, 'test_pass@email.com', '123', 0);

    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20004, 'FAIL: Baza pozwoliła na hasło krótsze niż 8 znaków.');
EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        IF v_error_code = -2290 THEN
            DBMS_OUTPUT.PUT_LINE('OK: Baza prawidłowo zablokowała za krótkie hasło.');
            ROLLBACK;
        ELSE
            ROLLBACK;
            RAISE;
        END IF;
END;
/

-- nieistniejaca strefa czasowa
DECLARE
    v_error_code NUMBER;
BEGIN
    INSERT INTO time_zone (id, code, utc_difference)
    VALUES (99, 'TEST', 15);

    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20005, 'FAIL: Baza pozwoliła na nieistniejacą strefę czasową.');
EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        IF v_error_code = -2290 THEN
            DBMS_OUTPUT.PUT_LINE('OK: Baza prawidłowo zablokowała nierealną strefę czasową.');
            ROLLBACK;
        ELSE
            ROLLBACK;
            RAISE;
        END IF;
END;
/

-- ujemna cena lotu
DECLARE
    v_error_code NUMBER;
BEGIN
    INSERT INTO flights (id, departure_date_time, arrival_date_time, routes_id, serial_number, price, currency_code)
    VALUES (9999,
            TIMESTAMP '2026-06-15 14:00:00 +02:00',
            TIMESTAMP '2026-06-15 16:00:00 +02:00',
            1, 1001, -10.00, 'EUR');

    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20006, 'FAIL: Baza pozwoliła na ujemną cenę biletu!');
EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        IF v_error_code = -2290 THEN
            DBMS_OUTPUT.PUT_LINE('OK: Baza prawidłowo odrzuciła ujemną wartość ceny.');
            ROLLBACK;
        ELSE
            ROLLBACK;
            RAISE;
        END IF;
END;
/


-- powtarzajace sie kody lotnisk
DECLARE
    v_error_code NUMBER;
BEGIN
    INSERT INTO airports (id, airport_name, airport_code, city_id)
    VALUES (9998, 'Airport1', 'AIR', 1);

    INSERT INTO airports (id, airport_name, airport_code, city_id)
    VALUES (9999, 'Airport2', 'AIR', 1);

    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20007, 'FAIL: Baza pozwoliła na powtorzenie kodu lotniska.');
EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        IF v_error_code = -1 THEN
            DBMS_OUTPUT.PUT_LINE('OK: Baza prawidłowo zablokowała powtórzony kod lotniska.');
            ROLLBACK;
        ELSE
            ROLLBACK;
            RAISE;
        END IF;
END;
/

-- nieistniejące miasto
DECLARE
    v_error_code NUMBER;
BEGIN
    INSERT INTO airports (id, airport_name, airport_code, city_id)
    VALUES (9999, 'Ghost Airport', 'GHO', 99999);

    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20008, 'FAIL: Baza pozwoliła stworzyć lotnisko dla nieistniejącego miasta.');
EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        IF v_error_code = -2291 THEN
            DBMS_OUTPUT.PUT_LINE('OK: Baza prawidłowo zablokowała referencję do nieistniejącego miasta.');
            ROLLBACK;
        ELSE
            ROLLBACK;
            RAISE;
        END IF;
END;
/


-- ujemne lub 0 wymiary bagażu
DECLARE
    v_error_code NUMBER;
BEGIN
    INSERT INTO luggage (id, weight, height, length, width)
    VALUES (3, 0, 40, 30, 20);

    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20009, 'FAIL: Baza pozwoliła na dodanie bagażu o złych wymiarach.');
EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        IF v_error_code = -2290 THEN
            DBMS_OUTPUT.PUT_LINE('OK: Baza prawidłowo odrzuciła bagaż ze złymi wymiarami.');
            ROLLBACK;
        ELSE
            ROLLBACK;
            RAISE;
        END IF;
END;
/

DECLARE
    v_error_code NUMBER;
BEGIN
    INSERT INTO luggage (id, weight, height, length, width)
    VALUES (3, 10, -40, 30, 20);

    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20009, 'FAIL: Baza pozwoliła na dodanie bagażu o złych wymiarach.');
EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        IF v_error_code = -2290 THEN
            DBMS_OUTPUT.PUT_LINE('OK: Baza prawidłowo odrzuciła bagaż ze złymi wymiarami.');
            ROLLBACK;
        ELSE
            ROLLBACK;
            RAISE;
        END IF;
END;
/

DECLARE
    v_error_code NUMBER;
BEGIN
    INSERT INTO luggage (id, weight, height, length, width)
    VALUES (3, 10, 40, 0, 20);

    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20009, 'FAIL: Baza pozwoliła na dodanie bagażu o złych wymiarach.');
EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        IF v_error_code = -2290 THEN
            DBMS_OUTPUT.PUT_LINE('OK: Baza prawidłowo odrzuciła bagaż ze złymi wymiarami.');
            ROLLBACK;
        ELSE
            ROLLBACK;
            RAISE;
        END IF;
END;
/

DECLARE
    v_error_code NUMBER;
BEGIN
    INSERT INTO luggage (id, weight, height, length, width)
    VALUES (3, 10, 40, 30, -20);

    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20009, 'FAIL: Baza pozwoliła na dodanie bagażu o złych wymiarach.');
EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        IF v_error_code = -2290 THEN
            DBMS_OUTPUT.PUT_LINE('OK: Baza prawidłowo odrzuciła bagaż ze złymi wymiarami.');
            ROLLBACK;
        ELSE
            ROLLBACK;
            RAISE;
        END IF;
END;
/

-- numer kolumny w samolocie poza zakresem
DECLARE
    v_error_code NUMBER;
BEGIN
    INSERT INTO seats (id, row_nr, column_nr, serial_number, seat_type_id, class_id)
    VALUES (99999, 1, 10, 1001, 1, 1);

    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20010, 'FAIL: Baza pozwoliła na numer kolumny poza zakresem.');
EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        IF v_error_code = -01438 THEN
            DBMS_OUTPUT.PUT_LINE('OK: Baza prawidłowo pilnuje układu siedzeń.');
            ROLLBACK;
        ELSE
            ROLLBACK;
            RAISE;
        END IF;
END;
/