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





