# City Issues

Aplikacja mobilna do zgłaszania problemów infrastruktury miejskiej — dziur w jezdni, zepsutego oświetlenia, śmieci czy zaniedbań w zieleni. Zgłoszenia są geolokalizowane i udokumentowane zdjęciem.

Projekt semestralny z przedmiotu **Programowanie aplikacji mobilnych**.

Wersja: **0.2.0 (1)**

## Spis treści

- [Funkcjonalności](#funkcjonalności)
- [Stos technologiczny](#stos-technologiczny)
- [Wymagania](#wymagania)
- [Konfiguracja](#konfiguracja)
- [Uruchomienie](#uruchomienie)
- [Testy](#testy)
- [Dokumentacja](#dokumentacja)
- [Struktura projektu](#struktura-projektu)
- [Zespół](#zespół)

## Funkcjonalności

### Uwierzytelnianie

- Logowanie i rejestracja przez **Google Sign-In** (Firebase Auth)
- Usuwanie konta wraz z danymi w PostgreSQL i plikami w Storage

### Mapa zgłoszeń

- Wyświetlanie zgłoszeń na mapie Google Maps
- Filtry kategorii (kolory pinów z bazy danych)
- Podgląd zgłoszenia w bottom sheet po kliknięciu markera
- Przejście do szczegółów zgłoszenia
- Odświeżanie listy co 30 s oraz po powiadomieniu push

### Nowe zgłoszenie

- Wybór kategorii
- Opis problemu (opcjonalny)
- Co najmniej jedno zdjęcie (aparat lub galeria)
- Wybór lokalizacji: przesuwanie mapy z pinezką na środku lub pobranie pozycji GPS

### Moje zgłoszenia

- Lista zgłoszeń zalogowanego użytkownika
- Status zgłoszenia (np. nowe, w trakcie, naprawione)

### Szczegóły zgłoszenia

- Zdjęcia, opis, kategoria, status
- Mapa z lokalizacją
- Głosowanie (upvote) z optymistycznym UI
- Komentarze: dodawanie, edycja i usuwanie własnych wpisów
- Edycja i usuwanie własnego zgłoszenia (kategoria, opis, lokalizacja, zdjęcia)

### Powiadomienia push

- Powiadomienie właściciela zgłoszenia o nowym głosie wsparcia (FCM + Cloud Function)
- Otwarcie szczegółów zgłoszenia po kliknięciu powiadomienia
- Włączanie i wyłączanie push w ustawieniach profilu

### Tryb offline (frontend)

- Cache zgłoszeń, kategorii, „moich zgłoszeń” i komentarzy w SQLite
- Banner informujący o braku sieci
- Kolejka synchronizacji: głosowanie, cofanie głosu, dodawanie komentarza po powrocie online
- Tworzenie, edycja i usuwanie zgłoszeń wymagają połączenia z siecią

### Profil i ustawienia

- Motyw jasny / ciemny / systemowy
- Kolor akcentu aplikacji
- Powiadomienia push (włącz / wyłącz)
- Interaktywny przewodnik po aplikacji (onboarding)
- Ekran „O aplikacji”

## Stos technologiczny

| Warstwa | Technologia |
|---------|-------------|
| Aplikacja mobilna | Flutter (Dart 3.11+) |
| Backend / API | Firebase Data Connect (PostgreSQL) |
| Uwierzytelnianie | Firebase Auth, Google Sign-In |
| Pliki | Firebase Storage |
| Powiadomienia | Firebase Cloud Messaging, Cloud Functions, `flutter_local_notifications` |
| Mapa | Google Maps Flutter |
| Lokalizacja | Geolocator |
| Preferencje lokalne | SharedPreferences |
| Cache offline | SQLite (`sqflite`), `connectivity_plus` |

## Wymagania

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (zgodny z `environment.sdk` w `pubspec.yaml`)
- Android Studio lub VS Code z rozszerzeniem Flutter
- Konto Firebase z skonfigurowanym projektem
- Klucz **Google Maps API** (Maps SDK for Android)
- Skonfigurowany **Google Sign-In** w Firebase Console (SHA-1 dla Androida)

Do uruchomienia testów na Windowsie bez MSVC można korzystać z obecnego `dependency_overrides` dla `path_provider_foundation` w `pubspec.yaml`.

## Konfiguracja

Pliki z danymi wrażliwymi nie są w repozytorium (patrz `.gitignore`). Trzeba je dodać lokalnie.

### 1. Firebase

1. Utwórz projekt w [Firebase Console](https://console.firebase.google.com/) lub użyj istniejącego.
2. Wygeneruj pliki konfiguracyjne FlutterFire:

   ```bash
   flutterfire configure
   ```

   Powstanie m.in. `lib/firebase_options.dart`.

3. Pliki `android/app/google-services.json` i `lib/firebase_options.dart` są w `.gitignore` (nie commituj kluczy).

4. W Firebase Console włącz **Authentication** (dostawca Google), **Data Connect**, **Storage**, **Cloud Messaging** oraz **Cloud Functions** według potrzeb projektu.

### CI (GitHub Actions)

Testy integracyjne wymagają sekretów `GOOGLE_SERVICES_JSON` i `FIREBASE_OPTIONS_DART`. Instrukcja: [`docs/CI-SECRETS.md`](docs/CI-SECRETS.md).

### 2. Google Maps (Android)

W pliku `android/local.properties` (nie commitowany) dodaj:

```properties
GOOGLE_MAPS_API_KEY=twoj_klucz_maps
```

Klucz musi mieć włączone **Maps SDK for Android**. W Google Cloud Console ogranicz klucz do pakietu aplikacji (`com.example.city_issues`).

### 3. Emulator Firebase (opcjonalnie)

Emulatory włączasz przy uruchomieniu:

```bash
flutter run --dart-define=USE_FIREBASE_EMULATOR=true --dart-define=EMULATOR_HOST=192.168.1.13
```

Konfiguracja: `lib/app/firebase_bootstrap.dart`.

### 4. Data Connect (backend)

Schemat, zapytania i mutacje znajdują się w katalogu `dataconnect/`. Po zmianach w GraphQL wygeneruj ponownie SDK:

```bash
firebase dataconnect:sdk:generate
```

Wygenerowany kod trafia do `lib/dataconnect_generated/`.

## Uruchomienie

```bash
# zależności
flutter pub get

# podłączone urządzenie lub emulator Android
flutter devices
flutter run
```

Build APK (debug):

```bash
flutter build apk --debug
```

## Testy

Testy jednostkowe i widgetów:

```bash
flutter test
```

Przykładowe grupy:

```bash
flutter test test/unit/
flutter test test/widgets/
```

Testy integracyjne (wymagają sekretów CI lub lokalnej konfiguracji Firebase):

```bash
flutter test integration_test/
```

Struktura:

- `test/unit/` — logika pomocnicza (walidacja, mapowanie błędów)
- `test/widgets/` — komponenty UI (mapa, formularze, ustawienia)
- `test/helpers/` — wspólne fixture'y i `pumpWidget` do testów
- `integration_test/` — scenariusze end-to-end na urządzeniu

## Dokumentacja

| Dokument | Opis |
|----------|------|
| [`docs/frontend/README.md`](docs/frontend/README.md) | Architektura frontendu, nawigacja, ekrany, konwencje |
| [`lib/services/README.md`](lib/services/README.md) | Referencja API warstwy serwisów (Data Connect, offline, FCM) |
| [`docs/CI-SECRETS.md`](docs/CI-SECRETS.md) | Sekrety GitHub Actions |
| [`docs/database.dbml`](docs/database.dbml) | Schemat bazy PostgreSQL (diagram) |
| [`integration_test/README.md`](integration_test/README.md) | Testy integracyjne |

## Struktura projektu

```
lib/
├── app/                    # MaterialApp, motywy, bootstrap Firebase
├── core/                   # stałe, widgety wspólne, utils
│   └── widgets/            # m.in. OfflineBanner
├── dataconnect_generated/  # SDK wygenerowane z Data Connect
├── features/
│   ├── auth/               # logowanie, AuthGate
│   ├── map/                # mapa i filtry
│   ├── onboarding/         # przewodnik po aplikacji
│   ├── reports/            # zgłoszenia (lista, formularz, szczegóły, komentarze)
│   ├── settings/         # profil, powiadomienia, o aplikacji
│   ├── shell/              # nawigacja (dolny pasek, IndexedStack)
│   └── splash/             # ekran startowy podczas inicjalizacji
├── services/               # auth, raporty, komentarze, storage, powiadomienia
│   └── offline/            # SQLite, cache, sync, connectivity
└── main.dart

dataconnect/                # schema, queries, mutations (backend)
functions/                  # Cloud Functions (np. push przy upvote)
docs/                       # dokumentacja projektu
test/                       # testy jednostkowe i widgetów
integration_test/           # testy E2E
android/                    # konfiguracja Android
```

## Zespół

| Osoba | Rola |
|-------|------|
| Maciej Bik | Frontend Developer |
| Kamil Buszta | Backend & DevOps |
| Jakub Wszołek | Product Lead & UX |

## Licencja

Projekt akademicki — brak publicznej licencji open source.
