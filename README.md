# Laboratoria Erlang i Elixir

Repozytorium zawiera projekty oraz zadania laboratoryjne realizowane w ramach nauki programowania współbieżnego i funkcyjnego w językach **Erlang** oraz **Elixir**, od podstaw składniowych po pełną architekturę OTP, bazę danych Ecto i aplikację webową w Phoenix Framework.

Głównym motywem przewodnim projektów jest budowa systemu monitorowania jakości powietrza (**Pollution Monitor**).

---

## 📁 Struktura repozytorium

```text
.
├── erlang_lab1/                      # Podstawy Erlanga
│   └── src/
│       ├── makota.erl                # Quicksort, list comprehensions, generowanie list
│       └── lab2.erl                  # Funkcje pomocnicze i ćwiczenia składniowe
│
├── erlang_lab2/                      # Moduł funkcyjny Pollution
│   └── src/
│       ├── pollution.erl             # Główny moduł stanu monitora (rekord #monitor{}, mapy)
│       └── pollution_test.erl        # Testy jednostkowe (EUnit)
│
├── erlang_lab3/                      # Współbieżność i architektura procesowa
│   └── src/
│       ├── pingpong.erl              # Komunikacja asynchroniczna między procesami
│       ├── pollution.erl             # Moduł domenowy
│       ├── pollution_server.erl      # Serwer oparty na pętli receive/loop i rejestracji procesu
│       └── pollution_server_test.erl # Testy serwera procesowego
│
├── erlangElixir/
│   ├── AirlyData-ALL-50k.csv         # Zbiór testowy 50 000 pomiarów z czujników Airly
│   │
│   ├── rebarLab/                     # Architektura OTP (Rebar3)
│   │   ├── rebar.config              # Konfiguracja projektu Rebar3
│   │   └── src/
│   │       ├── pollution.erl                  # Logika dziedzinowa
│   │       ├── pollution_gen_server.erl       # Serwer gen_server
│   │       ├── pollution_value_collector.erl  # Maszyna stanów gen_statem zbierająca dane
│   │       ├── rebarLab_app.erl               # Definicja aplikacji OTP
│   │       └── rebarLab_sup.erl               # Drzewo nadzorców (Supervisor)
│   │
│   └── eix_lab7/pollutiondb/         # Aplikacja webowa Phoenix Framework
│       ├── lib/                      # Kontrolery, komponenty, widoki, schematy Ecto
│       ├── config/                   # Konfiguracja środowiska Phoenix
│       └── mix.exs                   # Konfiguracja projektu Mix
│
└── elixir/
    └── pollutiondb/                  # Elixir + Ecto + SQLite
        ├── lib/
        │   ├── pollutiondb/
        │   │   ├── station.ex        # Model Ecto stacji pomiarowej (Pollutiondb.Station)
        │   │   ├── reading.ex        # Model Ecto pojedynczego pomiaru (Pollutiondb.Reading)
        │   │   ├── repo.ex           # Repozytorium Ecto (Pollutiondb.Repo)
        │   │   └── application.ex    # Drzewo nadzorców aplikacji Elixir
        │   └── pollutiondb.ex        # Główny moduł aplikacji
        └── mix.exs                   # Definicja zależności (ecto_sql, ecto_sqlite3)
```

---

## 🛠️ Opis poszczególnych modułów

### 1. `erlang_lab1` – Wprowadzenie do Erlanga
* Podstawy programowania funkcyjnego i dopasowania do wzorca (*pattern matching*).
* Przetwarzanie list, generatory (*list comprehensions*), rekurencja ogonowa.
* Implementacja algorytmu Quicksort oraz narzędzi do pomiaru czasu wykonania (`timer:tc`).

### 2. `erlang_lab2` – Moduł `pollution`
Niezmienny (*immutable*) monitor pomiarów jakości powietrza:
* Struktura danych `#monitor{}` oparta na mapach Erlanga:
  * mapa stacji: nazwa -> współrzędne,
  * mapa współrzędnych: współrzędne -> nazwa,
  * mapa pomiarów: `{{Współrzędne}, DataCzas, Typ}` -> wartość.
* Operacje:
  * `add_station/3` – dodawanie stacji pomiarowej,
  * `add_value/5` / `remove_value/4` – wprowadzanie i usuwanie pomiarów,
  * `get_one_value/4` – odczyt konkretnej wartości,
  * `get_station_min/3`, `get_station_mean/3` – minimum i średnia stacji,
  * `get_daily_mean/3` – średnia dobowa dla danego typu pomiaru,
  * `get_moving_mean/3` – średnia ruchoma w oknie czasowym.
* Zestaw testów automatycznych `pollution_test.erl` z wykorzystaniem **EUnit**.

### 3. `erlang_lab3` – Procesy i współbieżność
* Komunikacja asynchroniczna z użyciem skrzynek pocztowych procesów (`pingpong.erl`).
* Implementacja serwera `pollution_server.erl`:
  * Własna pętla wiadomości `receive ... end`,
  * Rejestracja procesu pod globalną nazwą,
  * Synchroniczny interfejs kliencki (`call/1`),
  * Obsługa błędów i testy współbieżne (`pollution_server_test.erl`).

### 4. `erlangElixir/rebarLab` – OTP z Rebar3
* Przejście na standard przemysłowy **Erlang/OTP**:
  * `pollution_gen_server.erl` – zachowanie `gen_server` opakowujące monitor `pollution`.
  * `pollution_value_collector.erl` – zachowanie `gen_statem` buforujące odczyty dla danej stacji przed ich hurtowym zapisem.
  * `rebarLab_sup.erl` – automatyczne restartowanie serwerów w razie awarii (*let it crash*).

### 5. `elixir/pollutiondb` – Elixir i Ecto (SQLite)
* Przeniesienie logiki do języka **Elixir**.
* Model relacyjny z użyciem **Ecto**:
  * `Pollutiondb.Station` – stacja (nazwa, długość i szerokość geograficzna, relacja `has_many` do odczytów).
  * `Pollutiondb.Reading` – odczyt (typ, wartość, data i godzina, relacja `belongs_to` do stacji).
* Złożone zapytania Ecto: wyszukiwanie po lokalizacji, zakresach współrzędnych, datach i agregacje statystyczne.

### 6. `erlangElixir/eix_lab7/pollutiondb` – Aplikacja Phoenix
* Interfejs WWW oparty na frameworku **Phoenix**.
* Wizualizacja danych pomiarowych ze stacji, widoki HEEx, kontrolery i routing.

---

## 🚀 Uruchomienie i testowanie

### Wymagania wstępne
* **Erlang/OTP** (zalecana wersja 25+)
* **Rebar3**
* **Elixir** (zalecana wersja 1.15+)

---

### Erlang (Laboratoria 1–3)
Uruchomienie powłoki Erlanga w katalogu danego laboratorium:
```bash
cd erlang_lab2/src
erl
```
Kompilacja i uruchomienie testów w powłoce:
```erlang
c(pollution).
c(pollution_test).
eunit:test(pollution_test).
```

Dla serwera z laboratorium 3:
```bash
cd erlang_lab3/src
erl
```
```erlang
c(pollution).
c(pollution_server).
pollution_server:start().
pollution_server:add_station("Krakow-Centrum", {50.0614, 19.9365}).
pollution_server:stop().
```

---

### Rebar3 (`erlangElixir/rebarLab`)
Budowanie aplikacji OTP i wejście w interaktywną konsolę:
```bash
cd erlangElixir/rebarLab
rebar3 compile
rebar3 shell
```
Wewnątrz konsoli Rebar3 aplikacja startuje automatycznie pod nadzorem supervisora.

---

### Elixir (`elixir/pollutiondb`)
Instalacja zależności, migracje i uruchomienie sesji IEx:
```bash
cd elixir/pollutiondb
mix deps.get
mix compile
iex -S mix
```
Przykładowe użycie w IEx:
```elixir
alias Pollutiondb.{Repo, Station, Reading}
Station.get_all()
```

---

### Phoenix (`erlangElixir/eix_lab7/pollutiondb`)
Uruchomienie serwera lokalnego:
```bash
cd erlangElixir/eix_lab7/pollutiondb
mix setup
mix phx.server
```
Aplikacja będzie dostępna pod adresem: `http://localhost:4000`.

