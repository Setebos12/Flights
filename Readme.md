# Temat projektu: System obsługi linii lotniczych
## Modele bazy danych
### Model pojęciowy
Opis encji:
- Time Zone - słownik dostępnych stref czasowych wraz z kodem i przesunięciem UTC
- Country - reprezentacja krajów, każdy kraj przypisany do strefy czasowej
- City - reprezentacja miast, każde miasto przypisane do kraju
- Airports - reprezentacja lotnisk wraz z ich kodami, każde lotnisko przypisane do miasta
- Routes - katalog obsługiwanych tras, zdefiniowane połączenie między dwoma lotniskami
- Flights - katalog dostępnych lotów, połączenie trasy i samolotu, wraz z czasami odlotu i przylotu oraz ceną
- Airlines - katalog linii lotniczych obsługujących system
- Planes - reprezentacja fizycznych samolotów, parametry typu: liczba miejsc, ładowność, pojemność paliwa
- Seat type - słownik przechowujący typy dostępnych miejsc (okno, środek, korytarz)
- Class - słownik przechowujący możliwe klasy (economy, business itp.)
- Seats - reprezentacja każdego miejsca w każdym samolocie, reprezentowane przez własne id oraz numer seryjny samolotu, określony numer rzędu i kolumny
- Currency - słownik przechowujący możliwe waluty
- Reservations - centralny punkt procesó zakupowych, powiązanie użytkownika z konkretnym lotem, oraz ilością wykupionych miejsc, w danym punkcie czasowym
- Extra services - katalog dostępnych dodatkowych usług wraz z ich ceną, np. priorytetowe wejście
- Luggage - poddtyp Extra services, uszczegółowione wszystkie usługi walizkowe o dokładne parametry bagażu
- Users - reprezentacja użytkowników w systemie, przechowuje dane dostępowe użytkownika do konta (email, hasło)
- Passengers - reprezentacja każdego pasażera lotu, przechowuje dane osobowe podróżnych, m.in. imię, nazwisko, numer telefonu
- Payment Status - słownik możliwych statusów płatności, np. "oczekiwana", "zrealizowana" itp.
- Payment - reprezentacja transakcji płatniczych, powiązanie płatności z rezerwacja w danym punkcie czasowym, każda posiada status
- Reservations extra services - przypisane usługi do konkretnych rezerwacji oraz pasażerów kożystających z tych udogodnień
- Reservations passengers - przypisani pasażerowie do konkretnych rezerwacji
- Boarding pass - reprezentacja karty pokładowej, przechowywane informacje typu: imię i nazwisko pasażera, data i miejsce przylotu i odlotu, lokalizacja miejsca

<br>

![Model pojęciowy](screeny/Logical.png)


### Model relacyjny
![Model relacyjny](screeny/Relational.png)
Zastosowana denormalizacja:
- Kolumny wyliczane
1. Tabela Payments - dodanie kolumny `payment_amount`<br>
Odpowiada za wyliczenie całkowitej ceny rezerwacji wraz z dodanymi usługami dodatkowymi.
- Pre-join kluczy obcych
1. Tabela Payments - dodanie klucza obcego do tabeli Currency<br>
Ma na celu przyspieszyć wyświetlanie kwoty transakcji wraz z odpowiednią walutą.
2. Tabela Flights - dodanie klucza obcego do tabeli Currency<br>
Ma na celu przyspieszyć wyświetlanie ceny lotu wraz z odpowiednią walutą.
3. Tabela Flights - dodanie klucza obcego do tabeli Airlines<br>
Pomocne, ponieważ przy locie chcemy od razu wyświetlić też informację o linii lotniczej.
- Pre-join atrybutów
1. Tabela Boarding Pass - duplikowane atrybuty: `departure_airport_code, arrival_airport_code, flight_departure_time, passenger_first_name, passenger_last_name, seat_row, seat_col`<br>
Odpowiada temu, że chcemy, aby karta pokładowa była niezmienna w czasie. Dane kart pokładowych są szybkiej wyświetlane i mamy informację o stanie danych z przeszłości, ponieważ w tym przypadku taki nas interesuje.
2. Tabela Flights - pre-join atrybutu `seat_count` z tabeli Planes<br>
Utworzone, żeby przyspieszyć porównywanie z kolumną `booked_seats`.
- Kolumny agregujące
1. Tabela Flights - dodana kolumna `booked_seats`<br>
Pomocna do częstego odczytywania stopnia zapełnienia lotu - może być to przydatne, żeby nie doprowadzić do przepełnienia lotu.
- Tabele agregujące
1. Dodana tabela `Route_statistics`<br>
Pozwala zagregować statystyki dotyczące ilości klientów i całkowitych przychodów z tras dla konkretnych lat oraz miesięcy. Przyjęta konwencja: dla year=0, month=0 zapisywana jest suma całkowita i dla month=0 - suma roczna.

<br>

### Model fizyczny
#### Dodane widoki
1. Widoki części operacyjnej
Znajdują się w pliku: [optimization.sql](./app-code/db/init/optimization.sql)
* Widok `v_flight_search`
    - zbiera dane często wykorzystywane do zapytania o loty w aplikacji
    - nie jest zmaterializowany, ale zwiększa wydajność, bo możliwe jest zapamiętanie planu zapytania i optymalizacja jego wykonania
    - wykorzystywany w funkcji `findSeatsByFlightId` w [FlightRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/FlightRepository.java)
* Widok `v_seat_flights`
    - zbiera informacje o siedzeniach w samolocie w celu stworzenia zestawienia zajętości miejsc wykorzystywanego w backendzie\
    - wykorzystywany w funkcji `findFlights` w [FlightRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/FlightRepository.java)

2. Widoki części analitycznej - szczegółowy opis w sekcji [Część analityczna](#część-analityczna--szczegółowy-opis)

#### Dodane indeksy
Znajdują się w pliku: [optimization.sql](./app-code/db/init/optimization.sql)
* Indeksy na kluczach głównych i wartościach unique (np. users.email_address, (routes.origin_airport_id, routes.dest_airport_id)) są tworzone automatycznie przez Oracle, co już poprawia wydajność większości wykorzystywanych zapytań
* Indeksy na kluczach obcych - pozwalają przyspieszyć wykonanie złączeń
* Na podstawie analizy często wykonywanych zapytań (dane z aplikacji):
    - select a1_0.id,a1_0.airport_code,a1_0.airport_name,a1_0.city_id from airports a1_0 order by a1_0.airport_name
        - dodany indeks na airports(airport_name), żeby przechowywać dane już posortowane
    - Złączenie boarding_pass z reservations, seats, flights (po serial_number) w widoku v_flight_seats także można przyspieszyć indeksem na kombinację (reservations_id, seats_id, serial_number)
    - Złączenie boarding_pass z użytkownikami można przyspieszyć zakładając indeks na kombinacji (passengers_id, reservations_id)
    - Podczas wyszukiwania lotów w aplikacji filtrować można po: dacie odlotu, cenie (zakresowo), lotniskach przylotu i odlotu, dlatego utworzone są indeksy na kombinacjach tych wartości, przy czym:
        - flight_date_price_idx obejmuje zarówno filtrowanie po kombinacji daty i ceny oraz samej daty
        - Podobnie routes_origin_dest_idx i routes_dest_idx obejmuje filtrowanie po kombinacji lotnisk, jak i samego lotniska wylotu
* Indeksy analityczne - szczegółowy opis w sekcji [Część analityczna](#indeksy-analityczne)

#### Dodane procedury składowane
Znajdują się w pliku: [procedures.sql](./app-code/db/init/procedures.sql)
* `create_reservation`
    - Tworzy nową rezerwację i przypisuje płatność o statusie “Pending”
    - Do aplikacji zwraca id utworzonej rezerwacji
    - Dane potrzebne do prejoinów są przygotowywane w aplikacji, więc zerowym kosztem możemy je przekazać i od razu przypisać do wiersza płatności (payment_amount, currency_code) pomijając wykorzystanie triggera (bo wartości nie są NULL)
    - Wykorzystanie w: [ReservationService.java](./app-code/flights-app/src/main/java/com/example/flights_app/service/ReservationService.java)
* `add_passenger_and_boarding_pass`
    - Dodaje pasażera do rezerwacji i przypisuje mu kartę pokładową
    - Ponownie wykorzystujemy dane już przygotowane, żeby wypełnić atrybuty prejoinowane (serial_number, passenger_first_name, passenger_last_name, seat_row, seat_col)
    - Wykorzystanie w: [ReservationService.java](./app-code/flights-app/src/main/java/com/example/flights_app/service/ReservationService.java)
* `cancel_reservation`
    - Anuluje rezerwację (jeśli to możliwe), aktualizując status płatności i usuwając wygenerowaną kartę pokładową, nieistotne już dane dotyczące pasażerów oraz dodatkowych udogodnień (żeby nie zaburzały analiz)
    - Wykorzystanie w: [ReservationService.java](./app-code/flights-app/src/main/java/com/example/flights_app/service/ReservationService.java)
* `pay_for_reservation`
    - Realizacja płatności jako ustawienie status płatności na “Completed”
    - Wykorzystanie w: [ReservationService.java](./app-code/flights-app/src/main/java/com/example/flights_app/service/ReservationService.java)
* Procedury analityczne (`get_occupancy`, `get_route_seasonality`) - szczegółowy opis w sekcji [Część analityczna](#procedury-składowane-analityczne-stored-procedures)

#### Dodane wyzwalacze
Znajdują się w pliku: [denormalization.sql](./app-code/db/init/denormalization.sql) <br>
Część została już opisana wyżej jako mechanizmy zapewniające spójność danych po denormalizacji. Wyzwalacze analityczne opisane są w sekcji [Część analityczna](#wyzwalacze-analityczne-triggers). Pozostałe:
* `planes_create_seats`
    - Wyzwalacz pozwalający na automatyczne przypisanie miejsc i ich ustawienia do samolotu

---

## Część analityczna

Moduł analityczny dostarcza dashboardowe zestawienia i raporty na temat obłożenia lotów, sezonowości tras, przychodów, rankingu linii lotniczych i rozkładu cen. Architektura oparta jest na warstwowym przepływie danych:

```
Oracle DB  ─→  Widoki analityczne + Tabela agregująca (route_statistics)
                          │
           Procedury składowane (get_occupancy, get_route_seasonality)
                          │
           Spring Boot (AnalyticsRepository → AnalyticsService → AnalyticsController)
                          │
              REST API  (/api/analytics/*)
                          │
           Frontend React (AnalyticsDashboard + wykresy Chart.js)
```

### Widoki analityczne (Views)

Znajdują się w pliku: [04_analytics_views.sql](./app-code/db/init/04_analytics_views.sql)

Wszystkie widoki są **niezmaterializowane** - Oracle może ponownie wykorzystać zapamiętane plany wykonania, co redukuje czas parsowania zapytań. Uzupełnione są o indeksy function-based (opisane w sekcji indeksów), które przyspieszają filtrowanie po kolumnach wyliczanych.

#### 1. `v_flight_occupancy` - obłożenie lotów
- **Cel**: Oblicza procentowe obłożenie każdego lotu (`occupancy_pct = booked_seats / total_seats × 100`).
- **Złączenia**: `flights` → `routes` → `airports` (origin, dest) + `airlines` + `planes`
- **Kolumny wyliczane**:
  - `booked_seats` - wykorzystuje zdenormalizowaną kolumnę `flights.booked_seats_count` (utrzymywaną przez triggery)
  - `total_seats` - `NVL(f.p_seat_count, p.seat_count)`, pre-joinowany atrybut
  - `dep_year`, `dep_month` - `EXTRACT(YEAR/MONTH FROM CAST(departure_date_time AS DATE))`
- **Wykorzystanie**:
  - procedura `get_occupancy` - filtrowane dane szczegółowe
  - `findOccupancySummary()` w [AnalyticsRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/AnalyticsRepository.java) - agregacja per linia lotnicza
  - `findKpiSummary()` - średnie obłożenie dla dashboardu KPI

#### 2. `v_route_seasonality` - sezonowość tras
- **Cel**: Agreguje liczbę lotów, pasażerów, średnie obłożenie i średnią cenę per trasa per miesiąc.
- **Złączenia**: `flights` → `routes` → `airports` → `city` (origin, dest) + `planes`
- **Grupowanie**: po trasie (`r.id`), kodach lotnisk, miastach, roku i miesiącu odlotu, walucie
- **Kolumny agregujące**: `total_flights`, `total_passengers`, `avg_occupancy_pct`, `avg_price`
- **Rola**: Backup/weryfikacja dla tabeli agregującej `route_statistics` - widok liczy bezpośrednio z tabel bazowych

#### 3. `v_route_revenue` - przychody per trasa
- **Cel**: Przychody z opłaconych rezerwacji per trasa per miesiąc.
- **Filtr**: `payment_status_id = 2` (Completed) - uwzględnia tylko zrealizowane płatności
- **Złączenia**: `payments` → `reservations` → `flights` → `routes` → `airports` → `city` + `airlines`
- **Kolumny**: `total_payments`, `total_revenue` (`SUM` kwot płatności), `avg_payment`
- **Uwaga**: kwota płatności brana z `payments.payment_amount` (kolumna wyliczana przez trigger `payment_calculation`) z fallbackiem na `flights.price × number_in_party`

#### 4. `v_airline_ranking` - ranking linii lotniczych
- **Cel**: Ranking linii lotniczych po przychodach, obłożeniu i liczbie lotów.
- **Złączenia**: `airlines` → `flights` → `planes` + `LEFT JOIN reservations` + `LEFT JOIN payments` (filtr `payment_status_id = 2`)
- **Kolumny**: `total_flights` (`COUNT DISTINCT`), `total_passengers`, `avg_occupancy_pct`, `total_revenue`
- **LEFT JOIN**: zapewnia, że linie lotnicze bez rezerwacji/płatności nie są pomijane
- **Wykorzystanie**:
  - `findAirlineRanking()` - pełny ranking
  - `findKpiSummary()` - najlepsza linia lotnicza (top 1 po przychodach)

#### 5. `v_price_distribution` - rozkład cen
- **Cel**: Statystyki cenowe per trasa: minimum, maksimum, średnia, mediana.
- **Złączenia**: `flights` → `routes` → `airports` (origin, dest)
- **Kolumny**: `min_price`, `max_price`, `avg_price`, `median_price` (Oracle `MEDIAN()`), `flight_count`
- **Wykorzystanie**: `findPriceDistribution()` w [AnalyticsRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/AnalyticsRepository.java)

---

### Tabela agregująca `route_statistics`

Zdefiniowana w [01_ddl.sql](./app-code/db/init/01_ddl.sql), utrzymywana automatycznie przez wyzwalacze.

| Kolumna            | Opis                                                             |
|--------------------|------------------------------------------------------------------|
| `routes_id` (PK)   | Klucz obcy do `routes`                                           |
| `year` (PK)        | Rok odlotu (0 = suma całkowita)                                  |
| `month` (PK)       | Miesiąc odlotu (0 = suma roczna / całkowita)                     |
| `total_passengers`  | Skumulowana liczba pasażerów                                     |
| `total_revenue`     | Skumulowany przychód                                             |

**Konwencja granulacji**:
- `year = 0, month = 0` - statystyka **all-time** (suma całkowita po wszystkich okresach)
- `year = RRRR, month = 0` - statystyka **roczna** (suma za dany rok)
- `year = RRRR, month = MM` - statystyka **miesięczna** (dane za konkretny miesiąc)

**Zapytania korzystające z tabeli**:
- `findTopRoutes(limit)` - top trasy po `total_passengers` (filtr: `year=0, month=0`)
- `findRouteRevenue(year)` - przychody per trasa per miesiąc (filtr: `year>0, month>0`)
- `findKpiSummary()` - łączna liczba pasażerów i przychodów (filtr: `year=0, month=0`)
- procedura `get_route_seasonality` - sezonowość z filtrami

---

### Wyzwalacze analityczne (Triggers)

Znajdują się w pliku: [denormalization.sql](./app-code/db/init/denormalization.sql)

Poniższe wyzwalacze utrzymują spójność tabeli agregującej `route_statistics`, aktualizując ją automatycznie przy każdej operacji na rezerwacjach i płatnościach.

#### 1. `route_statistics_count_passengers_I`
- **Zdarzenie**: `AFTER INSERT ON reservations_passengers`
- **Działanie**: Inkrementuje `total_passengers` w trzech wierszach tabeli `route_statistics`:
  1. Wiersz all-time (`year=0, month=0`)
  2. Wiersz roczny (`year=RRRR, month=0`)
  3. Wiersz miesięczny (`year=RRRR, month=MM`)
- **Logika**: Na podstawie `reservations_id` odczytuje `routes_id` i `departure_date_time` z `flights`. Jeśli wiersz nie istnieje (INSERT na nowej trasie/okresie), jest tworzony z `total_passengers=1, total_revenue=0`.
- **Technika**: Wzorzec `UPDATE → IF SQL%ROWCOUNT = 0 THEN INSERT` (upsert bez MERGE)

#### 2. `route_statistics_count_revenue_I`
- **Zdarzenie**: `AFTER INSERT ON payments`
- **Działanie**: Dodaje kwotę płatności (`payment_amount`) do `total_revenue` we wszystkich trzech granulacjach (all-time, roczna, miesięczna) jednym `UPDATE` z warunkiem `OR`.
- **Uwaga**: Trigger działa na INSERT do `payments`, więc `payment_amount` jest już obliczona przez trigger `payment_calculation`.

---

### Procedury składowane analityczne (Stored Procedures)

Znajdują się w pliku: [procedures.sql](./app-code/db/init/procedures.sql)

Procedury analityczne hermetyzują złożoną logikę filtrowania i eliminują dynamiczne budowanie SQL w Javie (zapobiegając SQL injection i zapewniając stabilniejsze plany wykonania).

#### 1. `get_occupancy`

| Parametr       | Typ             | Opis                                    |
|----------------|-----------------|-----------------------------------------|
| `p_airline_id` | `NUMBER` (IN)   | Filtr po linii lotniczej (NULL = brak)  |
| `p_route_id`   | `NUMBER` (IN)   | Filtr po trasie (NULL = brak)           |
| `p_year`       | `NUMBER` (IN)   | Filtr po roku odlotu (NULL = brak)      |
| `p_month`      | `NUMBER` (IN)   | Filtr po miesiącu odlotu (NULL = brak)  |
| `p_result`     | `SYS_REFCURSOR` (OUT) | Kursor z wynikami                  |

- **Źródło danych**: widok `v_flight_occupancy`
- **Filtrowanie**: wzorzec `(param IS NULL OR kolumna = param)` - Oracle optymalizuje to do eliminacji predykatów, gdy parametr jest NULL
- **Sortowanie**: `ORDER BY departure_date_time ASC`
- **Wywołanie w Javie**: `SimpleJdbcCall` z `OracleTypes.CURSOR` w [AnalyticsRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/AnalyticsRepository.java)

#### 2. `get_route_seasonality`

| Parametr        | Typ              | Opis                                          |
|-----------------|------------------|-----------------------------------------------|
| `p_year`        | `NUMBER` (IN)    | Filtr po roku (NULL = wszystkie lata)         |
| `p_origin_code` | `VARCHAR2` (IN)  | Filtr po kodzie lotniska origin (NULL = brak) |
| `p_dest_code`   | `VARCHAR2` (IN)  | Filtr po kodzie lotniska dest (NULL = brak)   |
| `p_result`      | `SYS_REFCURSOR` (OUT) | Kursor z wynikami                         |

- **Źródło danych**: tabela `route_statistics` złączona z `routes` → `airports` → `city`
- **Filtrowanie**: `month > 0 AND year > 0` (pomija sumy roczne i all-time) + opcjonalne filtry
- **Sortowanie**: `ORDER BY year ASC, month ASC, total_passengers DESC NULLS LAST`
- **Wywołanie w Javie**: `SimpleJdbcCall` z `OracleTypes.CURSOR` w [AnalyticsRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/AnalyticsRepository.java)

---

### Indeksy analityczne

Znajdują się w pliku: [optimization.sql](./app-code/db/init/optimization.sql)

| Indeks                        | Tabela / Wyrażenie                                                    | Cel                                                                   |
|-------------------------------|-----------------------------------------------------------------------|-----------------------------------------------------------------------|
| `flights_dep_year_idx`        | `EXTRACT(YEAR FROM CAST(departure_date_time AS DATE))`                | Function-based: przyspiesza filtrowanie po `dep_year` w `v_flight_occupancy` |
| `flights_dep_month_idx`       | `EXTRACT(MONTH FROM CAST(departure_date_time AS DATE))`               | Function-based: przyspiesza filtrowanie po `dep_month` w `v_flight_occupancy` |
| `rs_year_month_idx`           | `route_statistics(year, month)`                                       | Zapytania filtrujące tylko po `year`/`month` (bez `routes_id` z PK)   |
| `rs_alltime_passengers_idx`   | `route_statistics(year, month, total_passengers DESC)`                 | Covering index dla top routes (`WHERE year=0 AND month=0 ORDER BY total_passengers DESC`) |
| `payments_status_idx`         | `payments(payment_status_id)`                                         | Filtrowanie `payment_status_id = 2` w `v_airline_ranking` i `v_route_revenue` |

---

### Warstwa aplikacyjna - REST API analityczne

Endpointy zdefiniowane w [AnalyticsController.java](./app-code/flights-app/src/main/java/com/example/flights_app/controller/AnalyticsController.java), logika biznesowa w [AnalyticsService.java](./app-code/flights-app/src/main/java/com/example/flights_app/service/AnalyticsService.java), dostęp do danych w [AnalyticsRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/AnalyticsRepository.java).

| Endpoint                          | Metoda | Parametry                                    | Źródło danych                     | DTO / Typ odpowiedzi     |
|-----------------------------------|--------|----------------------------------------------|-----------------------------------|--------------------------|
| `/api/analytics/kpi`              | GET    | -                                            | `route_statistics` + `v_flight_occupancy` + `v_airline_ranking` | `KpiSummaryDTO`          |
| `/api/analytics/occupancy`        | GET    | `airlineId`, `routeId`, `year`, `month`      | procedura `get_occupancy`         | `List<OccupancyDTO>`     |
| `/api/analytics/occupancy/summary`| GET    | -                                            | `v_flight_occupancy` (GROUP BY)   | `List<Map>`              |
| `/api/analytics/routes/seasonality`| GET   | `year`, `originCode`, `destCode`             | procedura `get_route_seasonality` | `List<RoutePopularityDTO>` |
| `/api/analytics/routes/top`       | GET    | `limit` (domyślnie 10)                       | `route_statistics` (all-time)     | `List<Map>`              |
| `/api/analytics/routes/revenue`   | GET    | `year`                                       | `route_statistics` (miesięczne)   | `List<RouteRevenueDTO>`  |
| `/api/analytics/airlines/ranking` | GET    | -                                            | `v_airline_ranking`               | `List<AirlineRankingDTO>` |
| `/api/analytics/prices/distribution`| GET  | -                                            | `v_price_distribution`            | `List<PriceDistributionDTO>` |

**Przepływ wywołania procedury** (na przykładzie occupancy):
1. `AnalyticsController.getOccupancy()` przyjmuje parametry z query string
2. `AnalyticsService.getOccupancy()` deleguje do repozytorium i mapuje wynik na DTO
3. `AnalyticsRepository.findOccupancy()` wywołuje `SimpleJdbcCall` z nazwą procedury `get_occupancy`, przekazując parametry IN i odbierając `SYS_REFCURSOR` (OUT)
4. Kursor jest automatycznie mapowany na `List<Map<String, Object>>` przez `RowMapper` zdefiniowany w konstruktorze repozytorium

---

### Frontend - Dashboard analityczny

Komponenty React znajdują się w katalogu `app-code/flights-frontend/src/components/analytics/`:

| Komponent                | Opis                                                                 |
|--------------------------|----------------------------------------------------------------------|
| `AnalyticsDashboard.jsx` | Główny kontener dashboardu, orkiestruje pozostałe komponenty         |
| `KpiCards.jsx`           | Karty KPI: łączne loty, pasażerowie, przychody, obłożenie, top trasa |
| `OccupancyChart.jsx`     | Wykres obłożenia lotów z filtrami (linia lotnicza, rok, miesiąc)     |
| `SeasonalityChart.jsx`   | Wykres sezonowości tras (pasażerowie per miesiąc)                    |
| `RevenueChart.jsx`       | Wykres przychodów per trasa per miesiąc                              |
| `AirlineRankingChart.jsx`| Ranking linii lotniczych (wykres słupkowy)                           |
| `PriceDistributionChart.jsx` | Rozkład cen per trasa (min/max/avg/mediana)                      |

Komunikacja z backendem odbywa się przez [analyticsApi.js](./app-code/flights-frontend/src/analyticsApi.js), który korzysta z endpointów REST opisanych powyżej.

### USERS:
dla przetestowania działania aplikacji należy logowac się na podanych userów:
1. ADMIN - email: anna.nowak@email.pl - hasło: Haslo5678
2. USER - email: piotr.wisniewski@email.pl - hasło: Secure99!