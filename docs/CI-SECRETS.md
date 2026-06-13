# Sekrety GitHub Actions (Firebase)

Pliki zawierające klucze klienckie Firebase **nie są przechowywane w repozytorium**. Pipeline CI odtwarza je z [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) przed procesem buildu.

## Podział plików konfiguracyjnych

| Plik | W repozytorium | Zawartość |
|------|----------------|-----------|
| `firebase.json` | tak | porty emulatorów, ścieżki — **bez kluczy API** |
| `.firebaserc` | tak | identyfikator projektu Firebase |
| `storage.rules` | tak | reguły Firebase Storage |
| `android/app/google-services.json` | **nie** | klucz API, identyfikatory klientów OAuth |
| `lib/firebase_options.dart` | **nie** | klucz API, konfiguracja FlutterFire |

Pliki wyłączone z repozytorium generuje się lokalnie poleceniem `flutterfire configure` (opis w głównym `README.md`).

## Wymagane sekrety repozytorium

Konfiguracja w GitHub: **Settings → Secrets and variables → Actions → New repository secret**

| Nazwa sekretu | Źródło zawartości |
|---------------|-------------------|
| `GOOGLE_SERVICES_JSON` | pełna treść pliku `android/app/google-services.json` |
| `FIREBASE_OPTIONS_DART` | pełna treść pliku `lib/firebase_options.dart` |

### Konfiguracja przez GitHub CLI

Wymagane: zainstalowane narzędzie `gh` oraz wykonane `gh auth login`.  
Pliki źródłowe muszą istnieć lokalnie w katalogu projektu.

```powershell
Get-Content android/app/google-services.json -Raw | gh secret set GOOGLE_SERVICES_JSON
Get-Content lib/firebase_options.dart -Raw | gh secret set FIREBASE_OPTIONS_DART
```

Alternatywnie dostępny jest skrypt pomocniczy:

```powershell
.\scripts\set-github-secrets.ps1
```

### Konfiguracja ręczna (interfejs GitHub)

1. Odczytanie zawartości pliku `android/app/google-services.json`.
2. Wklejenie całego dokumentu JSON (od `{` do `}`) jako wartości sekretu `GOOGLE_SERVICES_JSON`.
3. Powtórzenie operacji dla `lib/firebase_options.dart` z przypisaniem do sekretu `FIREBASE_OPTIONS_DART`.

Wartości sekretów przekazywane są jako surowy tekst — bez dodatkowego opakowania w cudzysłowy ani kodowania base64. Workflow zapisuje treść bezpośrednio do odpowiednich plików.

## Weryfikacja poprawności konfiguracji

Po dodaniu sekretów i wypchnięciu commitów zawierających `firebase.json` oraz `.firebaserc` należy sprawdzić wynik workflow **Integration Tests** w zakładce Actions.

Krok `Create Firebase client config from GitHub Secrets` musi zakończyć się powodzeniem przed uruchomieniem emulatorów Firebase.

## Uwagi dotyczące bezpieczeństwa

- Sekrety Actions dostępne są wyłącznie dla kont z uprawnieniami do repozytorium; wartości nie są emitowane w logach workflow.
- Przekazywane klucze mają charakter **kliencki** — warstwa ochrony opiera się na regułach Firebase (`storage.rules`, dyrektywy `@auth` w Data Connect) oraz ograniczeniach klucza API w Google Cloud Console.
- Do sekretów **nie należy** dodawać plików konta serwisowego (`*-firebase-adminsdk-*.json`).

## Repozytoria publiczne

Sekrety Actions nie są ujawniane w kodzie źródłowym. Forki repozytorium nie dziedziczą sekretów — w każdym forku wymagana jest osobna konfiguracja.
