# Project topic: Airline Handling System

## Media & Showcase
### Technology Stack & Architecture Showcase
* 🎥 [Technology Overview (Minions Edition)](https://www.youtube.com/watch?v=d7ykmqRy26A) – A fun yet detailed presentation introducing the project's tech stack, database constraints, and underlying architecture.

### Sample Run
* 🚀 [Application Demo](https://www.youtube.com/watch?v=H3jNq9FGktk)


## Database Models
### Conceptual Model
Entity description:
- Time Zone - dictionary of available time zones with code and UTC offset
- Country - representation of countries, each country assigned to a time zone
- City - representation of cities, each city assigned to a country
- Airports - representation of airports with their codes, each airport assigned to a city
- Routes - catalog of supported routes, defined connection between two airports
- Flights - catalog of available flights, combination of a route and a plane, along with departure and arrival times and price
- Airlines - catalog of airlines served by the system
- Planes - representation of physical planes, parameters such as: number of seats, load capacity, fuel capacity
- Seat type - dictionary storing available seat types (window, middle, aisle)
- Class - dictionary storing possible classes (economy, business, etc.)
- Seats - representation of each seat in each plane, represented by its own id and the plane's serial number, a defined row and column number
- Currency - dictionary storing possible currencies
- Reservations - the central point of purchase processes, linking a user to a specific flight, along with the number of purchased seats, at a given point in time
- Extra services - catalog of available additional services along with their price, e.g. priority boarding
- Luggage - a subtype of Extra services, a detailed specification of all baggage-related services with precise baggage parameters
- Users - representation of system users, stores the user's account access data (email, password)
- Passengers - representation of each flight passenger, stores travelers' personal data, among others first name, last name, phone number
- Payment Status - dictionary of possible payment statuses, e.g. "pending", "completed" etc.
- Payment - representation of payment transactions, linking a payment to a reservation at a given point in time, each has a status
- Reservations extra services - services assigned to specific reservations and passengers using these amenities
- Reservations passengers - passengers assigned to specific reservations
- Boarding pass - representation of a boarding pass, stores information such as: passenger's first and last name, arrival/departure date and location, seat location

<br>

![Conceptual model](screeny/Logical.png)


### Relational Model
![Relational model](screeny/Relational.png)
Denormalization applied:
- Computed columns
1. Payments table - addition of the `payment_amount` column<br>
Responsible for calculating the total reservation price including added extra services.
- Pre-joined foreign keys
1. Payments table - addition of a foreign key to the Currency table<br>
Meant to speed up displaying the transaction amount with the corresponding currency.
2. Flights table - addition of a foreign key to the Currency table<br>
Meant to speed up displaying the flight price with the corresponding currency.
3. Flights table - addition of a foreign key to the Airlines table<br>
Helpful because when displaying a flight we also want to immediately show the airline information.
- Pre-joined attributes
1. Boarding Pass table - duplicated attributes: `departure_airport_code, arrival_airport_code, flight_departure_time, passenger_first_name, passenger_last_name, seat_row, seat_col`<br>
This corresponds to the fact that we want the boarding pass to remain unchanged over time. Boarding pass data is displayed quickly and we have information about the state of the data from the past, since in this case that's what interests us.
2. Flights table - pre-joined `seat_count` attribute from the Planes table<br>
Created to speed up comparison with the `booked_seats` column.
- Aggregating columns
1. Flights table - added `booked_seats` column<br>
Helpful for frequently reading a flight's occupancy level - this can be useful to avoid overbooking a flight.
- Aggregating tables
1. Added `Route_statistics` table<br>
Allows aggregating statistics regarding the number of customers and total revenue from routes for specific years and months. Adopted convention: for year=0, month=0 the total overall sum is stored, and for month=0 - the annual sum.

<br>

### Physical Model
#### Added views
1. Operational-part views
Located in the file: [optimization.sql](./app-code/db/init/optimization.sql)
* View `v_flight_search`
    - collects data frequently used for querying flights in the application
    - it is not materialized, but it increases performance because it is possible to remember the query plan and optimize its execution
    - used in the `findSeatsByFlightId` function in [FlightRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/FlightRepository.java)
* View `v_seat_flights`
    - collects information about seats in a plane in order to create a seat-occupancy summary used in the backend
    - used in the `findFlights` function in [FlightRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/FlightRepository.java)

2. Analytics-part views - detailed description in the [Analytics part](#analytics-part--detailed-description) section

#### Added indexes
Located in the file: [optimization.sql](./app-code/db/init/optimization.sql)
* Indexes on primary keys and unique values (e.g. users.email_address, (routes.origin_airport_id, routes.dest_airport_id)) are created automatically by Oracle, which already improves the performance of most of the queries used
* Indexes on foreign keys - help speed up the execution of joins
* Based on an analysis of frequently executed queries (data from the application):
    - select a1_0.id,a1_0.airport_code,a1_0.airport_name,a1_0.city_id from airports a1_0 order by a1_0.airport_name
        - added an index on airports(airport_name), to keep the data already sorted
    - The join of boarding_pass with reservations, seats, flights (by serial_number) in the v_flight_seats view can also be sped up with an index on the combination (reservations_id, seats_id, serial_number)
    - The join of boarding_pass with users can be sped up by creating an index on the combination (passengers_id, reservations_id)
    - When searching for flights in the application, one can filter by: departure date, price (by range), departure and arrival airports, therefore indexes are created on combinations of these values, where:
        - flight_date_price_idx covers both filtering by the combination of date and price, and by date alone
        - Similarly, routes_origin_dest_idx and routes_dest_idx cover filtering by the combination of airports, as well as by the departure airport alone
* Analytical indexes - detailed description in the [Analytics part](#analytical-indexes) section

#### Added stored procedures
Located in the file: [procedures.sql](./app-code/db/init/procedures.sql)
* `create_reservation`
    - Creates a new reservation and assigns a payment with the "Pending" status
    - Returns the id of the created reservation to the application
    - The data needed for pre-joins is prepared in the application, so we can pass it at zero cost and immediately assign it to the payment row (payment_amount, currency_code), bypassing the use of a trigger (since the values are not NULL)
    - Used in: [ReservationService.java](./app-code/flights-app/src/main/java/com/example/flights_app/service/ReservationService.java)
* `add_passenger_and_boarding_pass`
    - Adds a passenger to the reservation and assigns them a boarding pass
    - Again, we reuse already-prepared data to fill in the pre-joined attributes (serial_number, passenger_first_name, passenger_last_name, seat_row, seat_col)
    - Used in: [ReservationService.java](./app-code/flights-app/src/main/java/com/example/flights_app/service/ReservationService.java)
* `cancel_reservation`
    - Cancels a reservation (if possible), updating the payment status and removing the generated boarding pass and now-irrelevant data regarding passengers and extra amenities (so they do not skew the analytics)
    - Used in: [ReservationService.java](./app-code/flights-app/src/main/java/com/example/flights_app/service/ReservationService.java)
* `pay_for_reservation`
    - Processes the payment by setting the payment status to "Completed"
    - Used in: [ReservationService.java](./app-code/flights-app/src/main/java/com/example/flights_app/service/ReservationService.java)
* Analytical procedures (`get_occupancy`, `get_route_seasonality`) - detailed description in the [Analytics part](#analytical-stored-procedures) section

#### Added triggers
Located in the file: [denormalization.sql](./app-code/db/init/denormalization.sql) <br>
Some have already been described above as mechanisms ensuring data consistency after denormalization. Analytical triggers are described in the [Analytics part](#analytical-triggers) section. Remaining ones:
* `planes_create_seats`
    - A trigger that allows automatic assignment of seats and their configuration to a plane

---

## Analytics Part

The analytics module provides dashboard summaries and reports on flight occupancy, route seasonality, revenue, airline ranking, and price distribution. The architecture is based on a layered data flow:

```
Oracle DB  ─→  Analytical views + Aggregating table (route_statistics)
                          │
           Stored procedures (get_occupancy, get_route_seasonality)
                          │
           Spring Boot (AnalyticsRepository → AnalyticsService → AnalyticsController)
                          │
              REST API  (/api/analytics/*)
                          │
           React Frontend (AnalyticsDashboard + Chart.js charts)
```

### Analytical Views (Views)

Located in the file: [04_analytics_views.sql](./app-code/db/init/04_analytics_views.sql)

All views are **non-materialized** - Oracle can reuse cached execution plans, which reduces query parsing time. They are supplemented with function-based indexes (described in the indexes section), which speed up filtering on computed columns.

#### 1. `v_flight_occupancy` - flight occupancy
- **Purpose**: Calculates the percentage occupancy of each flight (`occupancy_pct = booked_seats / total_seats × 100`).
- **Joins**: `flights` → `routes` → `airports` (origin, dest) + `airlines` + `planes`
- **Computed columns**:
  - `booked_seats` - uses the denormalized column `flights.booked_seats_count` (maintained by triggers)
  - `total_seats` - `NVL(f.p_seat_count, p.seat_count)`, pre-joined attribute
  - `dep_year`, `dep_month` - `EXTRACT(YEAR/MONTH FROM CAST(departure_date_time AS DATE))`
- **Usage**:
  - `get_occupancy` procedure - filtered detailed data
  - `findOccupancySummary()` in [AnalyticsRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/AnalyticsRepository.java) - aggregation per airline
  - `findKpiSummary()` - average occupancy for the KPI dashboard

#### 2. `v_route_seasonality` - route seasonality
- **Purpose**: Aggregates the number of flights, passengers, average occupancy, and average price per route per month.
- **Joins**: `flights` → `routes` → `airports` → `city` (origin, dest) + `planes`
- **Grouping**: by route (`r.id`), airport codes, cities, departure year and month, currency
- **Aggregating columns**: `total_flights`, `total_passengers`, `avg_occupancy_pct`, `avg_price`
- **Role**: Backup/verification for the `route_statistics` aggregating table - the view computes directly from the base tables

#### 3. `v_route_revenue` - revenue per route
- **Purpose**: Revenue from paid reservations per route per month.
- **Filter**: `payment_status_id = 2` (Completed) - only includes completed payments
- **Joins**: `payments` → `reservations` → `flights` → `routes` → `airports` → `city` + `airlines`
- **Columns**: `total_payments`, `total_revenue` (`SUM` of payment amounts), `avg_payment`
- **Note**: the payment amount is taken from `payments.payment_amount` (a column computed by the `payment_calculation` trigger), with a fallback to `flights.price × number_in_party`

#### 4. `v_airline_ranking` - airline ranking
- **Purpose**: Ranking of airlines by revenue, occupancy, and number of flights.
- **Joins**: `airlines` → `flights` → `planes` + `LEFT JOIN reservations` + `LEFT JOIN payments` (filter `payment_status_id = 2`)
- **Columns**: `total_flights` (`COUNT DISTINCT`), `total_passengers`, `avg_occupancy_pct`, `total_revenue`
- **LEFT JOIN**: ensures that airlines without reservations/payments are not omitted
- **Usage**:
  - `findAirlineRanking()` - full ranking
  - `findKpiSummary()` - top airline (top 1 by revenue)

#### 5. `v_price_distribution` - price distribution
- **Purpose**: Price statistics per route: minimum, maximum, average, median.
- **Joins**: `flights` → `routes` → `airports` (origin, dest)
- **Columns**: `min_price`, `max_price`, `avg_price`, `median_price` (Oracle `MEDIAN()`), `flight_count`
- **Usage**: `findPriceDistribution()` in [AnalyticsRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/AnalyticsRepository.java)

---

### `route_statistics` Aggregating Table

Defined in [01_ddl.sql](./app-code/db/init/01_ddl.sql), maintained automatically by triggers.

| Column             | Description                                                      |
|--------------------|--------------------------------------------------------------------|
| `routes_id` (PK)   | Foreign key to `routes`                                            |
| `year` (PK)        | Departure year (0 = total sum)                                     |
| `month` (PK)       | Departure month (0 = annual / total sum)                           |
| `total_passengers`  | Cumulative number of passengers                                   |
| `total_revenue`     | Cumulative revenue                                                 |

**Granularity convention**:
- `year = 0, month = 0` - **all-time** statistic (total sum across all periods)
- `year = YYYY, month = 0` - **annual** statistic (sum for the given year)
- `year = YYYY, month = MM` - **monthly** statistic (data for a specific month)

**Queries using the table**:
- `findTopRoutes(limit)` - top routes by `total_passengers` (filter: `year=0, month=0`)
- `findRouteRevenue(year)` - revenue per route per month (filter: `year>0, month>0`)
- `findKpiSummary()` - total number of passengers and revenue (filter: `year=0, month=0`)
- `get_route_seasonality` procedure - seasonality with filters

---

### Analytical Triggers (Triggers)

Located in the file: [denormalization.sql](./app-code/db/init/denormalization.sql)

The following triggers maintain the consistency of the `route_statistics` aggregating table, updating it automatically on every operation on reservations and payments.

#### 1. `route_statistics_count_passengers_I`
- **Event**: `AFTER INSERT ON reservations_passengers`
- **Action**: Increments `total_passengers` in three rows of the `route_statistics` table:
  1. All-time row (`year=0, month=0`)
  2. Annual row (`year=YYYY, month=0`)
  3. Monthly row (`year=YYYY, month=MM`)
- **Logic**: Based on `reservations_id`, reads `routes_id` and `departure_date_time` from `flights`. If the row does not exist (INSERT on a new route/period), it is created with `total_passengers=1, total_revenue=0`.
- **Technique**: `UPDATE → IF SQL%ROWCOUNT = 0 THEN INSERT` pattern (upsert without MERGE)

#### 2. `route_statistics_count_revenue_I`
- **Event**: `AFTER INSERT ON payments`
- **Action**: Adds the payment amount (`payment_amount`) to `total_revenue` across all three granularities (all-time, annual, monthly) in a single `UPDATE` with an `OR` condition.
- **Note**: The trigger runs on INSERT into `payments`, so `payment_amount` has already been computed by the `payment_calculation` trigger.

---

### Analytical Stored Procedures

Located in the file: [procedures.sql](./app-code/db/init/procedures.sql)

Analytical procedures encapsulate complex filtering logic and eliminate dynamic SQL construction in Java (preventing SQL injection and ensuring more stable execution plans).

#### 1. `get_occupancy`

| Parameter      | Type            | Description                              |
|----------------|-----------------|-------------------------------------------|
| `p_airline_id` | `NUMBER` (IN)   | Filter by airline (NULL = none)           |
| `p_route_id`   | `NUMBER` (IN)   | Filter by route (NULL = none)             |
| `p_year`       | `NUMBER` (IN)   | Filter by departure year (NULL = none)    |
| `p_month`      | `NUMBER` (IN)   | Filter by departure month (NULL = none)   |
| `p_result`     | `SYS_REFCURSOR` (OUT) | Cursor with results                |

- **Data source**: `v_flight_occupancy` view
- **Filtering**: `(param IS NULL OR column = param)` pattern - Oracle optimizes this to eliminate predicates when the parameter is NULL
- **Sorting**: `ORDER BY departure_date_time ASC`
- **Called from Java**: `SimpleJdbcCall` with `OracleTypes.CURSOR` in [AnalyticsRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/AnalyticsRepository.java)

#### 2. `get_route_seasonality`

| Parameter        | Type              | Description                                    |
|-----------------|------------------|--------------------------------------------------|
| `p_year`        | `NUMBER` (IN)    | Filter by year (NULL = all years)                |
| `p_origin_code` | `VARCHAR2` (IN)  | Filter by origin airport code (NULL = none)      |
| `p_dest_code`   | `VARCHAR2` (IN)  | Filter by destination airport code (NULL = none) |
| `p_result`      | `SYS_REFCURSOR` (OUT) | Cursor with results                         |

- **Data source**: `route_statistics` table joined with `routes` → `airports` → `city`
- **Filtering**: `month > 0 AND year > 0` (skips annual and all-time sums) + optional filters
- **Sorting**: `ORDER BY year ASC, month ASC, total_passengers DESC NULLS LAST`
- **Called from Java**: `SimpleJdbcCall` with `OracleTypes.CURSOR` in [AnalyticsRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/AnalyticsRepository.java)

---

### Analytical Indexes

Located in the file: [optimization.sql](./app-code/db/init/optimization.sql)

| Index                          | Table / Expression                                                     | Purpose                                                                    |
|-------------------------------|-------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| `flights_dep_year_idx`        | `EXTRACT(YEAR FROM CAST(departure_date_time AS DATE))`                  | Function-based: speeds up filtering by `dep_year` in `v_flight_occupancy`   |
| `flights_dep_month_idx`       | `EXTRACT(MONTH FROM CAST(departure_date_time AS DATE))`                 | Function-based: speeds up filtering by `dep_month` in `v_flight_occupancy`  |
| `rs_year_month_idx`           | `route_statistics(year, month)`                                         | Queries filtering only by `year`/`month` (without `routes_id` from the PK) |
| `rs_alltime_passengers_idx`   | `route_statistics(year, month, total_passengers DESC)`                   | Covering index for top routes (`WHERE year=0 AND month=0 ORDER BY total_passengers DESC`) |
| `payments_status_idx`         | `payments(payment_status_id)`                                           | Filtering `payment_status_id = 2` in `v_airline_ranking` and `v_route_revenue` |

---

### Application Layer - Analytical REST API

Endpoints defined in [AnalyticsController.java](./app-code/flights-app/src/main/java/com/example/flights_app/controller/AnalyticsController.java), business logic in [AnalyticsService.java](./app-code/flights-app/src/main/java/com/example/flights_app/service/AnalyticsService.java), data access in [AnalyticsRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/AnalyticsRepository.java).

| Endpoint                          | Method | Parameters                                    | Data source                        | DTO / Response type      |
|-----------------------------------|--------|------------------------------------------------|-------------------------------------|---------------------------|
| `/api/analytics/kpi`              | GET    | -                                              | `route_statistics` + `v_flight_occupancy` + `v_airline_ranking` | `KpiSummaryDTO`          |
| `/api/analytics/occupancy`        | GET    | `airlineId`, `routeId`, `year`, `month`        | `get_occupancy` procedure           | `List<OccupancyDTO>`     |
| `/api/analytics/occupancy/summary`| GET    | -                                              | `v_flight_occupancy` (GROUP BY)     | `List<Map>`              |
| `/api/analytics/routes/seasonality`| GET   | `year`, `originCode`, `destCode`               | `get_route_seasonality` procedure   | `List<RoutePopularityDTO>` |
| `/api/analytics/routes/top`       | GET    | `limit` (default 10)                           | `route_statistics` (all-time)       | `List<Map>`              |
| `/api/analytics/routes/revenue`   | GET    | `year`                                         | `route_statistics` (monthly)        | `List<RouteRevenueDTO>`  |
| `/api/analytics/airlines/ranking` | GET    | -                                              | `v_airline_ranking`                 | `List<AirlineRankingDTO>` |
| `/api/analytics/prices/distribution`| GET  | -                                              | `v_price_distribution`              | `List<PriceDistributionDTO>` |

**Procedure call flow** (using occupancy as an example):
1. `AnalyticsController.getOccupancy()` accepts parameters from the query string
2. `AnalyticsService.getOccupancy()` delegates to the repository and maps the result to a DTO
3. `AnalyticsRepository.findOccupancy()` invokes `SimpleJdbcCall` with the procedure name `get_occupancy`, passing IN parameters and receiving a `SYS_REFCURSOR` (OUT)
4. The cursor is automatically mapped to a `List<Map<String, Object>>` by the `RowMapper` defined in the repository's constructor

---

### Frontend - Analytics Dashboard

React components are located in the directory `app-code/flights-frontend/src/components/analytics/`:

| Component                | Description                                                            |
|--------------------------|----------------------------------------------------------------------|
| `AnalyticsDashboard.jsx` | Main dashboard container, orchestrates the other components          |
| `KpiCards.jsx`           | KPI cards: total flights, passengers, revenue, occupancy, top route  |
| `OccupancyChart.jsx`     | Flight occupancy chart with filters (airline, year, month)           |
| `SeasonalityChart.jsx`   | Route seasonality chart (passengers per month)                       |
| `RevenueChart.jsx`       | Revenue chart per route per month                                    |
| `AirlineRankingChart.jsx`| Airline ranking (bar chart)                                          |
| `PriceDistributionChart.jsx` | Price distribution per route (min/max/avg/median)                |

Communication with the backend takes place through [analyticsApi.js](./app-code/flights-frontend/src/analyticsApi.js), which uses the REST endpoints described above.




### USERS:
To test the application's operation, log in using the following users:
1. ADMIN - email: anna.nowak@email.pl - password: Haslo5678
2. USER - email: piotr.wisniewski@email.pl - password: Secure99!

### System Trailer
* 🎬 [System Trailer](https://www.youtube.com/watch?v=eDwicYUp85Y)
