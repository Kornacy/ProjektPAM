# Warstwa serwisów (`lib/services`)

Katalog zawiera logikę biznesową aplikacji — komunikację z backendem (Firebase Data Connect, Storage, Auth, Cloud Functions) oraz integrację z funkcjami urządzenia. UI w `lib/features/` korzysta z tych serwisów przez singletony (`*.instance`).

Backend GraphQL: `dataconnect/default_connector/`. Cloud Function poza tym folderem: `functions/src/index.ts`.

---

## `auth_service.dart` — uwierzytelnianie i profil użytkownika

| Metoda / właściwość | Opis | Backend |
| :--- | :--- | :--- |
| `authStateChanges` | Strumień stanu sesji Firebase Auth. | Firebase Auth |
| `currentUser` | Aktualnie zalogowany użytkownik lub `null`. | Firebase Auth |
| `isSignedIn` | Czy użytkownik jest zalogowany. | — |
| `initialize()` | Konfiguruje Google Sign-In, nasłuchuje zdarzeń logowania/wylogowania. | Google Sign-In |
| `waitForAuthReady()` | Czeka na pierwszą emisję stanu auth (przywrócenie sesji). | Firebase Auth |
| `ensureUserProfile()` | Wymaga zalogowania; upsert profilu w PostgreSQL. | `UpsertUser` |
| `signInWithGoogle()` | Uruchamia logowanie przez Google (UI arkusza Google). | Google Sign-In → Firebase Auth |
| `signInWithEmailPassword()` | Logowanie e-mail/hasło (w kodzie; nieużywane w UI). | Firebase Auth → `UpsertUser` |
| `registerWithEmailPassword()` | Rejestracja e-mail/hasło (w kodzie; nieużywane w UI). | Firebase Auth → `UpsertUser` |
| `signOut()` | Wylogowanie z Firebase Auth i Google. | Firebase Auth |
| `deleteAccount()` | Usuwa dane z PostgreSQL, zdjęcia ze Storage, konto Firebase Auth. | `DeleteAccount`, Storage, Firebase Auth |
| `mapAuthError()` | Mapuje kody `FirebaseAuthException` na komunikaty po polsku. | — |

---

## `report_service.dart` — zgłoszenia, mapa, głosy

| Metoda | Opis | Backend |
| :--- | :--- | :--- |
| `upvoteStateFor()` | Zwraca cache'owany stan głosu dla zgłoszenia (UI). | — |
| `cacheUpvoteState()` | Zapisuje optymistyczny stan głosu w pamięci. | — |
| `resolveUpvoteState()` | Łączy cache z danymi z serwera. | — |
| `getReports()` | Pobiera wszystkie zgłoszenia na mapę; fallback offline. | `GetReports` |
| `findReportById()` | Szuka zgłoszenia po ID w liście z `getReports`. | `GetReports` |
| `getCategories()` | Pobiera słownik kategorii; fallback offline. | `GetCategories` |
| `getActiveReports()` | Zgłoszenia ze statusem innym niż `ZAKONCZONE`. | `GetActiveReports` |
| `getMyReports()` | Zgłoszenia zalogowanego użytkownika; fallback offline. | `GetMyReports` |
| `isOwnReport()` | Sprawdza, czy zgłoszenie należy do bieżącego użytkownika. | `GetMyReports` |
| `upvoteReport()` | Dodaje głos wsparcia; offline → kolejka sync. Po sukcesie woła push. | `UpvoteReport`, Cloud Function `notifyUpvoteOnReport` |
| `removeUpvote()` | Cofa głos; offline → kolejka sync. | `RemoveUpvote` |
| `createReport()` | Tworzy zgłoszenie (GPS lub wskazana lokalizacja) + upload zdjęć. | `CreateReport`, `AddPhoto`, Storage |
| `editReport()` | Edycja własnego zgłoszenia: kategoria, opis, lokalizacja, zdjęcia. | `EditReport`, `RemoveReportPhoto`, `AddPhoto`, Storage |
| `deleteReport()` | Usuwa własne zgłoszenie wraz z powiązanymi danymi. | `DeleteReport` |

---

## `comment_service.dart` — komentarze pod zgłoszeniami

| Metoda / stała | Opis | Backend |
| :--- | :--- | :--- |
| `offlinePendingId` | Identyfikator zastępczy komentarza dodanego offline. | — |
| `getComments()` | Lista komentarzy dla zgłoszenia; fallback z cache SQLite. | `GetReportComments` |
| `addComment()` | Dodaje komentarz; offline → kolejka sync. | `AddComment` |
| `editComment()` | Edycja własnego komentarza (wymaga sieci). | `EditComment` |
| `deleteComment()` | Usunięcie własnego komentarza (wymaga sieci). | `DeleteComment` |
| `isOwner()` | Czy bieżący użytkownik jest autorem komentarza. | — |

---

## `storage_service.dart` — pliki w Firebase Storage

| Metoda | Opis | Backend |
| :--- | :--- | :--- |
| `uploadReportPhoto()` | Upload zdjęcia JPEG pod `reports/{uid}/{timestamp}.jpg`; zwraca URL. | Firebase Storage |
| `deleteReportPhoto()` | Usuwa pojedynczy plik po URL (np. przy edycji zgłoszenia). | Firebase Storage |
| `deleteAllUserPhotos()` | Usuwa cały folder `reports/{uid}/` (przy usuwaniu konta). | Firebase Storage |

---

## `notification_service.dart` — powiadomienia push (FCM)

| Metoda / właściwość | Opis | Backend |
| :--- | :--- | :--- |
| `initialize()` | Kanał Android, nasłuch FCM (foreground/background), sync tokena. | FCM |
| `syncToken()` | Pobiera token FCM i zapisuje w profilu użytkownika. | `UpdateFcmToken` |
| `systemPermissionStatus()` | Status zgody systemowej na powiadomienia. | FCM / Android |
| `disablePushRegistration()` | Kasuje token FCM i zapisuje pusty `fcmToken` w bazie. | `UpdateFcmToken` |
| `notifyUpvoteOnReport()` | Woła Cloud Function wysyłającą push do właściciela zgłoszenia. | `notifyUpvoteOnReport` (region `europe-central2`) |
| `showUpvoteReceived()` | Lokalne powiadomienie na urządzeniu (aplikacja otwarta). | `flutter_local_notifications` |
| `setOnReportOpened()` | Rejestruje callback otwarcia zgłoszenia po kliknięciu powiadomienia. | — |
| `setOnReportsChanged()` | Callback odświeżenia listy zgłoszeń po push. | — |
| `lastTokenSyncResult` | Wynik ostatniej synchronizacji tokena FCM. | — |
| `handleReportNotificationData()` | Parsuje payload powiadomienia (testy). | — |

---

## `location_service.dart` — geolokalizacja

| Metoda | Opis | Backend |
| :--- | :--- | :--- |
| `getLastKnownLocation()` | Odczyt ostatniej pozycji z `SharedPreferences` (`last_lat`, `last_lng`). | Lokalne |
| `getCurrentLocation()` | Pobiera GPS (z uprawnieniami), zapisuje ostatnią pozycję lokalnie. | Geolocator |
| `getLocationStream()` | Strumień pozycji (co ~10 m); dostępny w kodzie, nieużywany w głównym flow. | Geolocator |

---

## `camera_service.dart` — aparat i galeria

| Metoda | Opis | Backend |
| :--- | :--- | :--- |
| `takePhoto()` | Zdjęcie z aparatu (kompresja 80%). | `image_picker` |
| `pickFromGallery()` | Wybór zdjęcia z galerii (kompresja 80%). | `image_picker` |
| `showPickerDialog()` | Bottom sheet: aparat lub galeria. | — |

---

## `app_preferences.dart` — preferencje lokalne (nie w chmurze)

| Metoda / właściwość | Opis | Backend |
| :--- | :--- | :--- |
| `load()` | Wczytuje ustawienia z `SharedPreferences`. | Lokalne |
| `themeMode` | Motyw: system / jasny / ciemny. | Lokalne |
| `accentColor` | Kolor akcentu aplikacji. | Lokalne |
| `hasCompletedOnboarding` | Czy użytkownik przeszedł onboarding. | Lokalne |
| `notificationsEnabled` | Przełącznik powiadomień push w aplikacji. | Lokalne |
| `setThemeMode()` | Zapis motywu. | Lokalne |
| `setAccentColor()` | Zapis koloru akcentu. | Lokalne |
| `setNotificationsEnabled()` | Włącza/wyłącza powiadomienia w aplikacji. | Lokalne |
| `setOnboardingCompleted()` | Oznacza onboarding jako ukończony. | Lokalne |
| `resetOnboardingFlags()` | Reset flagi onboardingu (np. ponowny przewodnik). | Lokalne |

---

## `offline/` — tryb offline

### `offline_exception.dart`

| Element | Opis |
| :--- | :--- |
| `OfflineException` | Wyjątek rzucany przy braku sieci i braku danych w cache (komunikat po polsku). |

### `connectivity_service.dart`

| Metoda / właściwość | Opis |
| :--- | :--- |
| `initialize()` | Sprawdza stan sieci i nasłuchuje zmian (`connectivity_plus`). |
| `isOnline` | Czy urządzenie ma połączenie sieciowe. |
| `setOnlineForTesting()` | Ustawia stan online/offline w testach. |

### `local_database.dart`

| Metoda / właściwość | Opis |
| :--- | :--- |
| `initialize()` | Otwiera SQLite `city_issues_offline.db` (tabele `cache_entries`, `pending_operations`). |
| `isAvailable` | Czy baza lokalna jest dostępna. |
| `requireDb()` | Zwraca instancję bazy lub rzuca błąd. |
| `closeForTesting()` | Zamyka bazę w testach. |

### `offline_cache_store.dart`

| Metoda | Opis |
| :--- | :--- |
| `saveJson()` / `loadJson()` | Zapis i odczyt listy JSON pod kluczem cache. |
| `lastUpdated()` | Data ostatniej aktualizacji wpisu cache. |
| `saveReports()` / `loadReports()` | Cache wszystkich zgłoszeń (`reports_all`). |
| `saveCategories()` / `loadCategories()` | Cache kategorii. |
| `saveMyReports()` / `loadMyReports()` | Cache zgłoszeń użytkownika (`my_reports_{uid}`). |
| `saveComments()` / `loadComments()` | Cache komentarzy (`comments_{reportId}`). |

### `offline_sync_service.dart`

| Metoda | Opis | Backend (po sync) |
| :--- | :--- | :--- |
| `enqueue()` | Dodaje operację do kolejki offline. | — |
| `pendingCount()` | Liczba oczekujących operacji. | — |
| `pendingOperations()` | Lista operacji w kolejce. | — |
| `syncPendingOperations()` | Wysyła kolejkę na serwer po powrocie sieci (kolejno FIFO). | `UpvoteReport`, `RemoveUpvote`, `AddComment` |

Obsługiwane typy kolejki (`PendingOperationType`): `upvote`, `removeUpvote`, `addComment`.

---

## Mapowanie mutacji Data Connect

| Mutacja / zapytanie | Używane w serwisie |
| :--- | :--- |
| `UpsertUser` | `AuthService` |
| `DeleteAccount` | `AuthService` |
| `GetReports`, `GetMyReports`, `GetActiveReports`, `GetCategories` | `ReportService` |
| `CreateReport`, `EditReport`, `DeleteReport` | `ReportService` |
| `AddPhoto`, `RemoveReportPhoto` | `ReportService` |
| `UpvoteReport`, `RemoveUpvote` | `ReportService`, `OfflineSyncService` |
| `GetReportComments`, `AddComment`, `EditComment`, `DeleteComment` | `CommentService`, `OfflineSyncService` |
| `UpdateFcmToken` | `NotificationService` |
