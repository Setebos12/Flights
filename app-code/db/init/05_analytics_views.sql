WHENEVER SQLERROR EXIT FAILURE ROLLBACK;
-- ============================================================
-- Analytics Views for SkySearch Reporting Module
-- ============================================================

-- View: flight occupancy (obłożenie lotów)
CREATE OR REPLACE VIEW v_flight_occupancy AS
SELECT
    f.id                                                                              AS flight_id,
    f.departure_date_time,
    f.arrival_date_time,
    oa.airport_code                                                                   AS origin_code,
    oa.airport_name                                                                   AS origin_name,
    da.airport_code                                                                   AS dest_code,
    da.airport_name                                                                   AS dest_name,
    al.id                                                                             AS airline_id,
    al.name                                                                           AS airline_name,
    p.model                                                                           AS plane_model,
    p.serial_number,
    NVL(f.booked_seats_count, 0)                                                      AS booked_seats,
    NVL(f.p_seat_count, p.seat_count)                                                 AS total_seats,
    CASE
        WHEN NVL(f.p_seat_count, p.seat_count) = 0 THEN NULL
        ELSE ROUND(NVL(f.booked_seats_count, 0) /
                   NVL(f.p_seat_count, p.seat_count) * 100, 2)
    END                                                                               AS occupancy_pct,
    EXTRACT(YEAR  FROM CAST(f.departure_date_time AS DATE))                           AS dep_year,
    EXTRACT(MONTH FROM CAST(f.departure_date_time AS DATE))                           AS dep_month,
    f.price,
    f.currency_code
FROM flights f
JOIN routes r   ON r.id  = f.routes_id
JOIN airports oa ON oa.id = r.origin_airport_id
JOIN airports da ON da.id = r.destination_airport_id
JOIN airlines al ON al.id = f.airlines_id
JOIN planes p    ON p.serial_number = f.serial_number;


-- View: route seasonality — passengers and flights per month, derived from flights table
-- (route_statistics is optionally populated via triggers; we compute directly for reliability)
CREATE OR REPLACE VIEW v_route_seasonality AS
SELECT
    r.id                                                                              AS route_id,
    oa.airport_code                                                                   AS origin_code,
    oc.name                                                                           AS origin_city,
    da.airport_code                                                                   AS dest_code,
    dc.name                                                                           AS dest_city,
    EXTRACT(YEAR  FROM CAST(f.departure_date_time AS DATE))                           AS dep_year,
    EXTRACT(MONTH FROM CAST(f.departure_date_time AS DATE))                           AS dep_month,
    COUNT(f.id)                                                                       AS total_flights,
    SUM(NVL(f.booked_seats_count, 0))                                                 AS total_passengers,
    ROUND(AVG(
        CASE WHEN NVL(f.p_seat_count, p.seat_count) > 0
             THEN NVL(f.booked_seats_count, 0) /
                  NVL(f.p_seat_count, p.seat_count) * 100
        END
    ), 2)                                                                             AS avg_occupancy_pct,
    ROUND(AVG(f.price), 2)                                                            AS avg_price,
    f.currency_code
FROM flights f
JOIN routes r    ON r.id  = f.routes_id
JOIN airports oa ON oa.id = r.origin_airport_id
JOIN city oc     ON oc.id = oa.city_id
JOIN airports da ON da.id = r.destination_airport_id
JOIN city dc     ON dc.id = da.city_id
JOIN planes p    ON p.serial_number = f.serial_number
GROUP BY
    r.id, oa.airport_code, oc.name, da.airport_code, dc.name,
    EXTRACT(YEAR  FROM CAST(f.departure_date_time AS DATE)),
    EXTRACT(MONTH FROM CAST(f.departure_date_time AS DATE)),
    f.currency_code;


-- View: route revenue — completed payments (payment_status_id = 2) per route and month
CREATE OR REPLACE VIEW v_route_revenue AS
SELECT
    r.id                                                                              AS route_id,
    oa.airport_code                                                                   AS origin_code,
    oc.name                                                                           AS origin_city,
    da.airport_code                                                                   AS dest_code,
    dc.name                                                                           AS dest_city,
    al.id                                                                             AS airline_id,
    al.name                                                                           AS airline_name,
    EXTRACT(YEAR  FROM p.payment_date)                                                AS pay_year,
    EXTRACT(MONTH FROM p.payment_date)                                                AS pay_month,
    COUNT(p.id)                                                                       AS total_payments,
    SUM(NVL(p.payment_amount, f.price * res.number_in_party))                         AS total_revenue,
    ROUND(AVG(NVL(p.payment_amount, f.price * res.number_in_party)), 2)               AS avg_payment,
    p.currency_code
FROM payments p
JOIN reservations res ON res.id       = p.reservations_id
JOIN flights f        ON f.id         = res.flights_id
JOIN routes r         ON r.id         = f.routes_id
JOIN airports oa      ON oa.id        = r.origin_airport_id
JOIN city oc          ON oc.id        = oa.city_id
JOIN airports da      ON da.id        = r.destination_airport_id
JOIN city dc          ON dc.id        = da.city_id
JOIN airlines al      ON al.id        = f.airlines_id
WHERE p.payment_status_id = 2   -- Completed
GROUP BY
    r.id, oa.airport_code, oc.name, da.airport_code, dc.name,
    al.id, al.name,
    EXTRACT(YEAR  FROM p.payment_date),
    EXTRACT(MONTH FROM p.payment_date),
    p.currency_code;


-- View: airline ranking summary
CREATE OR REPLACE VIEW v_airline_ranking AS
SELECT
    al.id                                                                             AS airline_id,
    al.name                                                                           AS airline_name,
    COUNT(DISTINCT f.id)                                                              AS total_flights,
    SUM(NVL(f.booked_seats_count, 0))                                                 AS total_passengers,
    ROUND(AVG(
        CASE WHEN NVL(f.p_seat_count, p.seat_count) > 0
             THEN NVL(f.booked_seats_count, 0) /
                  NVL(f.p_seat_count, p.seat_count) * 100
        END
    ), 2)                                                                             AS avg_occupancy_pct,
    SUM(NVL(pay.payment_amount, f.price * res.number_in_party))                       AS total_revenue
FROM airlines al
JOIN flights f        ON f.airlines_id    = al.id
JOIN planes p         ON p.serial_number  = f.serial_number
LEFT JOIN reservations res ON res.flights_id = f.id
LEFT JOIN payments pay     ON pay.reservations_id = res.id
                           AND pay.payment_status_id = 2
GROUP BY al.id, al.name;


-- View: price distribution per route
CREATE OR REPLACE VIEW v_price_distribution AS
SELECT
    r.id                                                                              AS route_id,
    oa.airport_code                                                                   AS origin_code,
    da.airport_code                                                                   AS dest_code,
    f.currency_code,
    MIN(f.price)                                                                      AS min_price,
    MAX(f.price)                                                                      AS max_price,
    ROUND(AVG(f.price), 2)                                                            AS avg_price,
    MEDIAN(f.price)                                                                   AS median_price,
    COUNT(f.id)                                                                       AS flight_count
FROM flights f
JOIN routes r    ON r.id  = f.routes_id
JOIN airports oa ON oa.id = r.origin_airport_id
JOIN airports da ON da.id = r.destination_airport_id
GROUP BY r.id, oa.airport_code, da.airport_code, f.currency_code;

EXIT;
