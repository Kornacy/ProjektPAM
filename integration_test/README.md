# Testy integracyjne (Firebase Emulator Suite)

Testy w tym katalogu sprawdzają **prawdziwe połączenie** warstwy serwisów (`lib/services/`) z lokalnymi emulatorami Firebase:

- **Auth** — logowanie testowego użytkownika
- **Data Connect** — zapytania i mutacje (zgłoszenia, komentarze, głosy)
- **Storage** — skonfigurowany emulator (przygotowany pod przyszłe testy uploadu zdjęć)

Testy jednostkowe w `test/services/` nadal są szybkie i działają bez emulatora. Testy integracyjne je **uzupełniają**, nie zastępują.

## Wymagania lokalne

| Narzędzie | Wersja / uwagi |
|-----------|----------------|
| Flutter SDK | stabilny kanał (`flutter doctor`) |
| Firebase CLI | `npm install -g firebase-tools` |
| Node.js | 18+ (skrypt seedujący) |
| Android SDK | emulator lub podłączone urządzenie |
| Java | **21+** (wymagane przez Firebase CLI i Android build) |

## Struktura

```
integration_test/
├── README.md
├── app_smoke_test.dart          # szybki smoke test połączenia z emulatorem
├── helpers/
│   ├── integration_setup.dart   # inicjalizacja Firebase + weryfikacja seeda
│   └── test_auth.dart           # logowanie użytkownika testowego
└── services/
    ├── auth_service_test.dart   # Auth emulator + upsertUser
    └── report_service_test.dart # kategorie, CRUD zgłoszeń, głosy, komentarze

scripts/
├── package.json
├── seed-emulator.mjs            # seed kategorii do Data Connect
├── seed.ps1                     # seed (Windows PowerShell)
├── get-lan-ip.ps1               # IP komputera dla fizycznego telefonu
├── run-integration-tests.ps1    # pełny flow (Windows)
└── run-integration-tests.sh     # pełny flow (Linux / macOS / Git Bash)
```

## Jak to działa

1. Uruchamiasz **Firebase Emulator Suite** (`auth`, `dataconnect`, `storage`).
2. Skrypt `scripts/seed-emulator.mjs` wstawia kategorie z `dataconnect/seed.gql`.
3. Testy startują na **emulatorze Androida** i łączą się z hostem `10.0.2.2` (localhost komputera widziany z emulatora).
4. `FirebaseBootstrap` (`lib/app/firebase_bootstrap.dart`) kieruje SDK na emulatory, gdy podasz:

   ```
   --dart-define=USE_FIREBASE_EMULATOR=true
   --dart-define=EMULATOR_HOST=10.0.2.2
   ```

### Host emulatora zależnie od środowiska

| Środowisko | `EMULATOR_HOST` |
|------------|-----------------|
| Emulator Androida (domyślnie w CI) | `10.0.2.2` |
| iOS Simulator / desktop | `localhost` |
| Fizyczny telefon w tej samej sieci | IP komputera, np. `192.168.1.13` |

## Uruchomienie lokalne

### Opcja A — jeden skrypt (Linux / macOS / Git Bash)

```bash
# Terminal 1: uruchom emulator Androida
flutter emulators --launch <emulator_id>

# Terminal 2: testy (wymaga firebase-tools i Node)
chmod +x scripts/run-integration-tests.sh
./scripts/run-integration-tests.sh
```

### Opcja B — Windows PowerShell (zalecane)

> **Uwaga:** `flutter test integration_test` uruchamiaj **z katalogu głównego** `ProjektPAM`, nie z `scripts\`.  
> W przeciwnym razie Flutter szuka `scripts/integration_test` i zgłasza `Does not exist`.

**Jednym skryptem** (sam startuje emulatory, seed i testy):

```powershell
cd C:\Users\kamil\Desktop\ProjektPAM

# Telefon USB (auto-wykrywa urządzenie i IP komputera):
.\test-integration.ps1

# Lub jawnie:
.\scripts\run-integration-tests.ps1 -DeviceId cb475b22 -EmulatorHost 192.168.1.13
```

IP komputera w sieci Wi‑Fi:

```powershell
.\scripts\get-lan-ip.ps1
```

**Ręcznie — dwa terminale:**

Terminal 1 — emulatory Firebase:

```powershell
firebase emulators:start --only auth,dataconnect,storage --project projekt-pam-city-issues
```

Terminal 2 — seed + testy:

```powershell
# WAŻNE: na Windows nie używaj "npm --prefix scripts" — wejdź do folderu scripts:
.\scripts\seed.ps1

# Testy — ZAWSZE z katalogu glownego ProjektPAM:
cd C:\Users\kamil\Desktop\ProjektPAM
.\run-flutter-integration-tests.ps1 -DeviceId cb475b22

# Emulator Androida:
.\run-flutter-integration-tests.ps1 -DeviceId emulator-5554 -EmulatorHost 10.0.2.2

# Fizyczny telefon — IP z .\scripts\get-lan-ip.ps1, np. 192.168.1.13:
.\run-flutter-integration-tests.ps1 -DeviceId cb475b22 -EmulatorHost 192.168.1.13
```

> `10.0.2.2` działa **tylko** w emulatorze Androida. Na fizycznym telefonie podaj **IP komputera** z `ipconfig` / `get-lan-ip.ps1`.
>
> Seed zawsze na `127.0.0.1` (działa na PC). Testy na telefonie łączą się z emulatorem przez IP LAN.

### Opcja C — `firebase emulators:exec` (jak w CI)

```bash
firebase emulators:exec \
  --only auth,dataconnect,storage \
  --project projekt-pam-city-issues \
  "npm run seed --prefix scripts && flutter test integration_test -d emulator-5554 --dart-define=USE_FIREBASE_EMULATOR=true --dart-define=EMULATOR_HOST=10.0.2.2"
```

## GitHub Actions

Workflow: [`.github/workflows/integration-tests.yml`](../.github/workflows/integration-tests.yml)

Uruchamia się przy push / PR do `main` i `backend-test`.

Kroki w CI:

1. Checkout + Java 21 + Flutter stable
2. Instalacja `firebase-tools`
3. `flutter pub get` + `npm install --prefix scripts`
4. `reactivecircus/android-emulator-runner` — startuje emulator Androida
5. `firebase emulators:exec` — emulatory + seed + `flutter test integration_test`

### Sekrety

Do uruchomienia emulatorów **nie są wymagane** sekrety Firebase — testy działają w pełni offline na Emulator Suite.

### Sekrety (klucze nie są w repo)

W repozytorium commituj tylko **konfigurację bez kluczy**:

- `firebase.json`, `.firebaserc`, `storage.rules`

Klucze klienckie trafiają do **GitHub Secrets** — szczegóły: [`docs/CI-SECRETS.md`](../docs/CI-SECRETS.md).

Szybka konfiguracja (lokalnie, po `flutterfire configure`):

```powershell
.\scripts\set-github-secrets.ps1
```

## Co testujemy

| Plik | Scenariusz |
|------|------------|
| `app_smoke_test.dart` | publiczne `getCategories` po seedzie |
| `auth_service_test.dart` | rejestracja/logowanie na Auth emulatorze, `ensureUserProfile` |
| `report_service_test.dart` | kategorie, tworzenie zgłoszenia, moje zgłoszenia, głosowanie, komentarze (dodaj/edytuj/usuń) |

## Rozwiązywanie problemów

### `Cannot start the Storage emulator without rules file`

Upewnij się, że w repozytorium są pliki `storage.rules` oraz sekcja `"storage"` w `firebase.json`. Bez tego emulator Storage nie wystartuje i może przerwać cały zestaw emulatorów (błędy `ECONNRESET`, `SIGKILL` przy Data Connect).

### `No Firebase App '[DEFAULT]' has been created`

Test integracyjny musi iść przez `integration_test/`, nie `test/`. Uruchamiaj:

```bash
flutter test integration_test -d <device_id> ...
```

### `Emulator nie zawiera kategorii`

Seed nie został wykonany. Uruchom:

```powershell
.\scripts\seed.ps1
```

(przy działających emulatorach)

### `violates SQL unique constraint: category_pkey`

Kategorie są **już w bazie** z poprzedniego seeda — to normalne. Zaktualizowany `seed-emulator.mjs` pomija seed, gdy kategorie istnieją. Uruchom ponownie `.\scripts\seed.ps1` — powinno wypisać `seed skipped`.

### `npm error ENOENT ... package.json` (Windows)

Na Windows **nie używaj** `npm install --prefix scripts` — często szuka `package.json` w katalogu głównym.

Zamiast tego:

```powershell
.\scripts\seed.ps1
```

(skrypt sam robi `cd scripts` i `npm install`)

### `Does not exist` przy `scripts/integration_test`

Uruchomiles `flutter test integration_test` z folderu `scripts\`. Wejdz do katalogu glownego:

```powershell
cd C:\Users\kamil\Desktop\ProjektPAM
.\run-flutter-integration-tests.ps1 -DeviceId cb475b22
```

### `No supported devices found with name emulator-5554`

Masz podłączony **fizyczny telefon**, nie emulator. Sprawdź ID:

```powershell
flutter devices
```

Uruchom testy z właściwym ID, np. `-d cb475b22`.

### `Connection refused` / timeout na Androidzie

- Sprawdź `android/app/src/debug/AndroidManifest.xml` — `usesCleartextTraffic=true`
- **Emulator Androida:** `EMULATOR_HOST=10.0.2.2`
- **Fizyczny telefon:** `EMULATOR_HOST=<IP_PC>` (ten sam Wi‑Fi, zezwól w firewallu na porty 9099, 9399, 9199)
- Emulatory muszą nasłuchiwać na `0.0.0.0` (ustawione w `firebase.json`)

### Testy jednostkowe vs integracyjne

```bash
# Szybkie testy bez Firebase (VM)
flutter test test/

# Integracyjne — wymagają urządzenia + emulatorów Firebase
flutter test integration_test -d emulator-5554 --dart-define=USE_FIREBASE_EMULATOR=true --dart-define=EMULATOR_HOST=10.0.2.2
```

## Rozszerzanie

Kolejne sensowne testy integracyjne:

- `createReport` ze zdjęciem (`StorageService` + Storage emulator)
- `getActiveReports` z filtrem statusu
- pełny smoke test UI (`CityIssuesApp` + `pumpWidget`)

Nowe testy dodawaj w `integration_test/services/` i korzystaj z helperów w `integration_test/helpers/`.
