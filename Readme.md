# Temat projektu: System obsługi linii lotniczych
## Modele bazy danych
### Model pojęciowy
Opis encji:
**TO DO**
<br>
![Model pojęciowy](screeny/Logical.png)

### Model relacyjny
Zastosowana denormalizacja:
**TO DO**
<br>
![Model relacyjny](screeny/Relational_1.png)

## 🛠️ Kroki Importu Schematu (DDL) z SQL

### 1. Inicjacja Importu pliku SQL
Aby rozpocząć pracę z istniejącym skryptem SQL, należy użyć modułu Data Modeler.
* Wybierz: **File** -> **Data Modeler** -> **Import** -> **DDL File**.

![Opis zdjęcia](screeny/1.png)

### 2. Wybór plików źródłowych
W oknie **Select DDL Files** dodaj swój wygenerowany wcześniej plik `.sql`
![Opis zdjęcia](screeny/2.png)




---

## 📊 Modelowanie w Data Modeler

### 3. Generowanie Diagramu Relacyjnego
Po pomyślnym imporcie i wykonaniu operacji **Merge**, program wygeneruje graficzną reprezentację tabel, kolumn oraz relacji (kluczy obcych).



![Opis zdjęcia](screeny/4.png)

### 4. Inżynieria Wsteczna do Modelu Logicznego
Aby przejść na wyższy poziom abstrakcji (Model Pojęciowy), należy przekształcić model relacyjny w logiczny.
* Kliknij ikonę **Engineer to Logical Model** (niebieskie strzałki na pasku narzędzi).

![Opis zdjęcia](screeny/3.png)


