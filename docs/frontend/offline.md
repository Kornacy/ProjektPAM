# Tryb offline (frontend)

Tryb offline działa **wyłącznie po stronie aplikacji mobilnej**. Nie zastępuje backendu — przy braku sieci użytkownik przegląda ostatnio pobrane dane i może wykonać ograniczony zestaw akcji, które trafiają do kolejki synchronizacji.

## Komponenty

```
ConnectivityService          OfflineSyncService
        │                            │
        ▼                            ▼
   OfflineBanner              pending_operations
        │                            │
        └──────────┬─────────────────┘
                   ▼
         ReportService / CommentService
                   │
                   ▼
         OfflineCacheStore → LocalDatabase (SQLite)
```

| Moduł | Plik |
|-------|------|
| Baza SQLite | `lib/services/offline/local_database.dart` |
| Zapis / odczyt cache | `lib/services/offline/offline_cache_store.dart` |
| Stan sieci | `lib/services/offline/connectivity_service.dart` |
| Kolejka operacji | `lib/services/offline/offline_sync_service.dart` |
| UI | `lib/core/widgets/offline_banner.dart` |
| Integracja w shellu | `lib/features/shell/main_shell.dart` |

## Co jest cache'owane

Po udanym pobraniu z sieci serwisy zapisują kopie w SQLite:

- wszystkie zgłoszenia na mapę (`getReports`),
- słownik kategorii (`getCategories`),
- zgłoszenia użytkownika (`getMyReports`),
- komentarze pod zgłoszeniem (`getComments`).

Przy błędzie sieci lub `OfflineException` serwis zwraca dane z cache zamiast propagować błąd do UI (o ile cache istnieje).

## Operacje w kolejce sync

Gdy `ConnectivityService` zgłasza brak sieci, następujące akcje są **kolejkowane** zamiast wysyłane od razu:

| Operacja | Serwis |
|----------|--------|
| `upvoteReport` | `ReportService` |
| `removeUpvote` | `ReportService` |
| `addComment` | `CommentService` |

Po powrocie online `MainShell` wywołuje `OfflineSyncService.instance.syncAll()`. Banner pokazuje stan synchronizacji.

Komentarz dodany offline otrzymuje tymczasowe ID (`CommentService.offlinePendingId`) do czasu potwierdzenia z serwera.

## Operacje wymagające sieci

Bez połączenia **nie** da się m.in.:

- utworzyć, edytować ani usunąć zgłoszenia,
- edytować ani usunąć komentarza,
- zalogować się lub usunąć konto,
- zsynchronizować tokena FCM.

W takich przypadkach serwis rzuca `OfflineException` lub zwraca komunikat błędu mapowany przez `UserFacingError`.

## UI

`OfflineBanner` w `MainShell`:

- wyświetla informację o braku internetu,
- informuje o trwającej synchronizacji kolejki,
- nie blokuje interakcji z mapą i listami (layout kolumnowy z `SafeArea` u góry powłoki).

## Mapa — kolejność ładowania

`MapScreen` ładuje **najpierw kategorie**, potem zgłoszenia (`_categoriesLoaded`). Zapobiega to sytuacji, w której markery renderują się bez poprawnych filtrów kolorów lub znikałyby przy błędnym stanie offline podczas startu.

## Rozwój i debugowanie

- Baza: `getDatabasesPath()` + plik `city_issues_offline.db`
- Tabele: `cache_entries` (klucz + JSON), `pending_operations` (typ, payload, timestamp)
- Testy jednostkowe offline: `test/unit/offline_*`

Przy zmianie formatu cache rozważ migrację wersji bazy w `LocalDatabase`.
