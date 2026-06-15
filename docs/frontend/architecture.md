# Architektura frontendu

## Warstwy

### Prezentacja (`lib/features/`)

Ekrany są `StatefulWidget` lub `StatelessWidget`. Stan lokalny (formularze, ładowanie) pozostaje w widoku; dane z backendu pobierane są przez serwisy w `initState`, `FutureBuilder` lub po akcjach użytkownika.

Wspólne wzorce:

- **GlobalKey** do odświeżania ekranów z `MainShell` (`MapScreenState`, `MyReportsScreenState`).
- **Callbacki** z `NotificationService` do nawigacji i odświeżania bez tight coupling między modułami.
- **UserFacingError** (`lib/core/utils/user_facing_error.dart`) — spójne komunikaty błędów po polsku.

### Serwisy (`lib/services/`)

Każdy serwis to singleton z konstruktorem prywatnym i `static final instance`. Ułatwia to testowanie (opcjonalne wstrzykiwanie zależności w konstruktorze fabrycznym, np. `AuthService.forTesting`).

Serwisy:

- mapują odpowiedzi Data Connect na modele domenowe używane w UI,
- obsługują upload do Storage,
- integrują cache offline tam, gdzie ma to sens (`ReportService`, `CommentService`).

### Core (`lib/core/`)

Elementy wielokrotnego użytku niezwiązane z jedną funkcją:

- `constants/app_info.dart` — wersja, opis, lista twórców (zsynchronizowana z `pubspec.yaml`),
- `widgets/offline_banner.dart` — pasek „Brak połączenia” / „Synchronizacja…”,
- `widgets/app_loading.dart` — spinner z opcjonalnym komunikatem.

### Aplikacja (`lib/app/`)

| Plik | Rola |
|------|------|
| `app.dart` | `CityIssuesApp` — bootstrap i `MaterialApp` z `AuthGate` |
| `theme.dart` | Motyw jasny/ciemny, paleta akcentów |
| `firebase_bootstrap.dart` | Inicjalizacja Firebase, opcjonalnie emulatory |

## Bootstrap

Kolejność inicjalizacji w `CityIssuesApp._bootstrap()`:

```
FirebaseBootstrap → AuthService → AppPreferences → LocalDatabase → ConnectivityService → NotificationService
```

Błąd inicjalizacji wyświetla ekran z komunikatem zamiast `AuthGate`.

## Motyw i preferencje

`AppPreferences` (SharedPreferences) przechowuje:

- tryb motywu (system / jasny / ciemny),
- wybrany kolor akcentu.

`CityIssuesApp` buduje `ThemeData` przez `AppTheme` przy każdej zmianie preferencji (`ListenableBuilder` lub odpowiednik w `app.dart`).

## Generowany SDK

`lib/dataconnect_generated/` powstaje poleceniem:

```bash
firebase dataconnect:sdk:generate
```

Pliki w tym katalogu **nie powinny być edytowane ręcznie**. Serwisy importują `default.dart` i wywołują wygenerowane buildery zapytań i mutacji.

## Testy frontendu

| Katalog | Zakres |
|---------|--------|
| `test/unit/` | Funkcje czyste, mapowanie błędów, logika offline |
| `test/widgets/` | Pojedyncze ekrany i widgety z mockami serwisów |
| `test/helpers/` | `pumpApp`, fixture'y danych |
| `integration_test/` | Scenariusze na urządzeniu / emulatorze |

Uruchomienie:

```bash
flutter test
flutter test test/widgets/
flutter test integration_test/
```

Przy testach widgetów serwisy można podmieniać przez konstruktory testowe lub mocki (`firebase_auth_mocks` w dev_dependencies).

## Konwencje

- Importy pakietu: `package:city_issues/...`
- Nazwy plików: `snake_case.dart`
- Ekrany: sufiks `_screen.dart` w `screens/`
- Widgety współdzielone w module: `widgets/`
- Komunikaty UI po polsku; identyfikatory w kodzie po angielsku
- Nowa funkcja biznesowa → nowy podkatalog w `features/` z `screens/` i opcjonalnie `widgets/`
- Logika API → rozszerzenie lub nowy plik w `services/`, dokumentacja w `lib/services/README.md`

## Zależności UI (pubspec.yaml)

Kluczowe pakiety po stronie frontendu:

| Pakiet | Użycie |
|--------|--------|
| `google_maps_flutter` | Mapa zgłoszeń |
| `geolocator` | Pozycja GPS |
| `image_picker` | Zdjęcia z aparatu / galerii |
| `flutter_svg` | Logo i ikony SVG |
| `sqflite`, `path_provider` | Cache offline |
| `connectivity_plus` | Wykrywanie sieci |
| `firebase_messaging`, `flutter_local_notifications` | Push |
| `shared_preferences` | Ustawienia lokalne |

Pełna lista: `pubspec.yaml`.
