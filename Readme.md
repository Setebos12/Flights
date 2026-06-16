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

2. Widoki części analitycznej
Znajdują się w pliku: [04_analytics_views.sql](./app-code/db/init/04_analytics_views.sql)
* Widok `v_flight_occupancy`
    - oblicza obłożenie każdego lotu (booked_seats / total_seats) jako `occupancy_pct`
    - łączy flights z routes, airports, airlines, planes
    - wykorzystywany przez `findOccupancy` i `findOccupancySummary` w [AnalyticsRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/AnalyticsRepository.java)
* Widok `v_route_seasonality`
    - agreguje liczbę lotów i pasażerów per trasa per miesiąc
    - backup dla danych z tabeli agregującej `route_statistics`
* Widok `v_route_revenue`
    - przychody per trasa per miesiąc na podstawie opłaconych płatności (`payment_status_id = 2`)
* Widok `v_airline_ranking`
    - ranking linii lotniczych po przychodach, obłożeniu i liczbie lotów
    - wykorzystywany przez `findAirlineRanking` i `findKpiSummary` w [AnalyticsRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/AnalyticsRepository.java)
* Widok `v_price_distribution`
    - rozkład cen (min, max, avg, mediana) per trasa
    - wykorzystywany przez `findPriceDistribution` w [AnalyticsRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/AnalyticsRepository.java)

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
* Na podstawie analizy zapytań części analitycznej:
    - `flights_dep_year_idx` / `flights_dep_month_idx` — function-based indeksy na `EXTRACT(YEAR/MONTH FROM CAST(departure_date_time AS DATE))`, ponieważ widok `v_flight_occupancy` filtruje po wyliczanych kolumnach `dep_year` / `dep_month`
    - `rs_year_month_idx` na `route_statistics(year, month)` — PK tabeli to `(routes_id, year, month)`, więc zapytania filtrujące tylko po `year`/`month` (bez `routes_id`) nie mogą optymalnie użyć PK
    - `rs_alltime_passengers_idx` na `route_statistics(year, month, total_passengers DESC)` — covering index dla zapytania top routes (`WHERE year=0 AND month=0 ORDER BY total_passengers DESC`)
    - `payments_status_idx` na `payments(payment_status_id)` — widoki `v_airline_ranking` i `v_route_revenue` filtrują `payment_status_id = 2`

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
* `get_occupancy` (analityczna)
    - Zwraca obłożenie lotów z opcjonalnymi filtrami: linia lotnicza, trasa, rok, miesiąc
    - Zastępuje dynamiczne budowanie SQL w Javie (konkatenacja stringów) — eliminuje ryzyko SQL injection i pozwala na stabilniejszy plan wykonania
    - Wykorzystanie w: [AnalyticsRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/AnalyticsRepository.java)
* `get_route_seasonality` (analityczna)
    - Zwraca sezonowość tras (pasażerowie i przychody per miesiąc) z opcjonalnymi filtrami: rok, lotnisko origin, lotnisko destination
    - Hermetyzuje logikę złączeń (route_statistics + routes + airports + city) i filtrowania
    - Wykorzystanie w: [AnalyticsRepository.java](./app-code/flights-app/src/main/java/com/example/flights_app/repository/AnalyticsRepository.java)

#### Dodane wyzwalacze
Znajdują się w pliku: [denormalization.sql](./app-code/db/init/denormalization.sql) <br>
Część została już opisana wyżej jako mechanizmy zapewniające spójność danych po denormalizacji. Tutaj przedstawiamy pozostałe:
* `planes_create_seats`
    - Wyzwalacz pozwalający na automatyczne przypisanie miejsc i ich ustawienia do samolotu

### USERS:
dla przetestowania działania aplikacji należy logowac się na podanych userów:
1. ADMIN - email: anna.nowak@email.pl - hasło: Haslo5678
2. USER - email: piotr.wisniewski@email.pl - hasło: Secure99!