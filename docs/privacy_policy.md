# Polityka Prywatności Aplikacji „City Issues”

**Wersja:** 1.1  
**Data ostatniej aktualizacji:** 13 czerwca 2026 r.  
**Aplikacja:** City Issues (wersja 0.2.0)  
**Platforma:** Android (aplikacja mobilna Flutter)

---

## 1. Tożsamość Administratora Danych

Administratorem danych osobowych w rozumieniu Rozporządzenia Parlamentu Europejskiego i Rady (UE) 2016/679 (RODO) jest zespół deweloperski projektu **City Issues** w składzie: **Maciej Bik, Kamil Buszta, Jakub Wszołek**, realizujący projekt w ramach przedmiotu *Programowanie Aplikacji Mobilnych* na Politechnice Rzeszowskiej.

* **Adres kontaktowy e-mail:** kontakt.cityissues@domain.com
* **Kontakt w sprawach prywatności:** Wszelkie zapytania dotyczące ochrony danych osobowych należy kierować na wskazany wyżej adres e-mail z dopiskiem w tytule: *„Ochrona danych — City Issues”*.

---

## 2. Zakres i Architektura Przetwarzania

Niniejsza Polityka Prywatności określa zasady zbierania, przetwarzania, przechowywania i zabezpieczania danych osobowych użytkowników aplikacji mobilnej **City Issues**.

Architektura systemu opiera się na zarządzanych usługach chmurowych **Google Firebase** oraz relacyjnej bazie danych **PostgreSQL**, z którą komunikacja odbywa się za pośrednictwem technologii **Firebase SQL Connect**. Aplikacja nie korzysta z własnego, samodzielnie hostowanego serwera WWW; logika po stronie chmury obejmuje m.in.:

* **Firebase Authentication** — uwierzytelnianie użytkowników,
* **Firebase SQL Connect** — zapytania i mutacje GraphQL na PostgreSQL,
* **Firebase Storage** — przechowywanie zdjęć,
* **Firebase Cloud Functions** (region `europe-central2`) — wysyłka powiadomień push (FCM) po podbiciu zgłoszenia.

Aplikacja **nie wykorzystuje** narzędzi analitycznych ani crash reportingu (np. Firebase Analytics, Crashlytics).

---

## 3. Szczegółowy Wykaz i Mapowanie Przetwarzanych Danych

### 3.1. Autentykacja i Dane Konta (Google Sign-In)

Jedynym sposobem logowania dostępnym w interfejsie użytkownika (wersja 0.2.0) jest **Google Sign-In** przez *Firebase Authentication*. Podczas rejestracji/logowania (operacja `upsertUser` w `lib/services/auth_service.dart`) system pobiera i zapisuje w bazie danych:

| Kategoria danych | Źródło pozyskania | Miejsce docelowe w architekturze |
| :--- | :--- | :--- |
| **Unikalny identyfikator (UID)** | Google / Firebase Auth | Tabela `User` (klucz główny) w PostgreSQL |
| **Adres e-mail** | Profil Google | Pole `User.email` w PostgreSQL |
| **Nazwa wyświetlana (username)** | Profil Google (`displayName`) lub fragment e-maila | Pole `User.username` w PostgreSQL |
| **URL zdjęcia profilowego** | Profil Google (`photoURL`) | Pole `User.photoUrl` w PostgreSQL |
| **Rola użytkownika** | Wartość domyślna systemu | Pole `User.role` (domyślnie `CITIZEN`) |
| **Tokeny sesyjne** | Firebase Auth | Bezpieczna pamięć podręczna urządzenia |

### 3.2. Uprawnienia systemowe Android

Aplikacja żąda następujących uprawnień (`AndroidManifest.xml`):

| Uprawnienie | Cel |
| :--- | :--- |
| `INTERNET` | Komunikacja z Firebase, Google Maps i usługami chmurowymi |
| `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` | Ustalenie lokalizacji zgłoszenia (GPS) |
| `CAMERA` | Zrobienie zdjęcia do zgłoszenia |
| `POST_NOTIFICATIONS` | Wyświetlanie powiadomień push (Android 13+) |

Dostęp do galerii zdjęć realizowany jest przez systemowy selektor (`image_picker`) bez osobnego uprawnienia `READ_MEDIA_IMAGES` w manifeście.

### 3.3. Geopozycjonowanie i Dane Lokalizacyjne

Aplikacja przetwarza współrzędne geograficzne wyłącznie w celach operacyjnych (powiązanie zgłoszenia z punktem na mapie).

* **Zgłoszenie z poziomu GPS:** Pobieranie współrzędnych (`latitude`, `longitude`) przez `LocationService.getCurrentLocation()` (pakiet `geolocator`), po zgodzie użytkownika na uprawnienia lokalizacji.
* **Zgłoszenie z poziomu mapy:** Współrzędne wybierane w interfejsie (`ReportService.createReport(selectedLocation)`) bez wywołania modułu GPS.
* **Pamięć podręczna:** Ostatnia znana pozycja zapisywana lokalnie w `SharedPreferences` (`last_lat`, `last_lng`).

**Ważne:** Współrzędne zgłoszeń trafiają do pól `Report.latitude` i `Report.longitude` i stają się **danymi publicznymi** (zapytanie `GetReports`, `@auth(level: PUBLIC)`). Aplikacja **nie śledzi** użytkownika w tle.

### 3.4. Multimedia (Zdjęcia)

`[Aparat / Galeria] ──(image_picker)──> [Kompresja: jakość 80%] ──> [Upload: Firebase Storage] ──> [Zapis URL w PostgreSQL]`

* **Pozyskiwanie:** Aparat lub galeria przez `CameraService` (`imageQuality: 80`).
* **Przechowywanie:** Plik w *Firebase Storage* pod ścieżką `reports/{uid}/{timestamp}.jpg`; URL w tabeli `ReportPhoto.imageUrl`.
* **Dostępność:** Odczyt zdjęć jest publiczny (`storage.rules`: `allow read: if true`).
* **Usuwanie:** Przy usuwaniu zdjęcia z zgłoszenia (operacja backendowa) plik może zostać usunięty ze Storage (`StorageService.deleteReportPhoto`).

### 3.5. Treści publiczne i aktywności (User-Generated Content)

Interakcje użytkownika powiązane są z jego UID:

* Opis, kategoria, status i data zgłoszenia (`Report`).
* Głosy wsparcia (`Upvote` — powiązanie UID użytkownika ze zgłoszeniem; identyfikatory autorów głosów widoczne w zapytaniach publicznych).
* Treść komentarzy i data dodania (`Comment`).

### 3.6. Powiadomienia push (FCM)

Po zalogowaniu aplikacja może poprosić o zgodę na powiadomienia (`POST_NOTIFICATIONS` / `FirebaseMessaging.requestPermission`). W przypadku zgody:

| Kategoria danych | Źródło | Miejsce docelowe |
| :--- | :--- | :--- |
| **Token FCM urządzenia** | Firebase Cloud Messaging | Pole `User.fcmToken` w PostgreSQL (mutacja `UpdateFcmToken`) |
| **Treść powiadomienia** | Generowana przez Cloud Function | Wyświetlana na urządzeniu odbiorcy |

**Kiedy wysyłane są powiadomienia:** Gdy inny zalogowany użytkownik podbije zgłoszenie (`notifyUpvoteOnReport` w `functions/src/index.ts`). Powiadomienie trafia do **właściciela zgłoszenia** (nie do osoby podbijającej). Treść może zawierać: nazwę użytkownika podbijającego, kategorię lub fragment opisu zgłoszenia oraz identyfikator zgłoszenia (`reportId`). Przy podbiciu własnego zgłoszenia powiadomienie nie jest wysyłane.

Token FCM synchronizowany jest przy starcie aplikacji, po logowaniu oraz przy odświeżeniu tokenu. Użytkownik może wyłączyć powiadomienia w ustawieniach systemu Android; token w bazie może pozostać do czasu kolejnej synchronizacji lub żądania usunięcia danych.

### 3.7. Dane konfiguracyjne (lokalne)

W `SharedPreferences` (`lib/services/app_preferences.dart`) zapisywane są: tryb jasny/ciemny/systemowy, kolor akcentu, status ukończenia onboardingu. Dane te **nie są przesyłane** do chmury.

---

## 4. Cele oraz Podstawy Prawne Przetwarzania (RODO)

| Kategoria danych | Cel przetwarzania | Podstawa prawna (RODO) |
| :--- | :--- | :--- |
| **Profil Google Auth / UID** | Uwierzytelnianie, identyfikacja autora zgłoszeń i komentarzy | **Art. 6 ust. 1 lit. b** — wykonanie usługi |
| **Dane GPS / lokalizacja** | Umiejscowienie zgłoszenia na mapie | **Art. 6 ust. 1 lit. a** — zgoda (uprawnienia systemowe) |
| **Zdjęcia** | Dokumentacja wizualna zgłoszenia | **Art. 6 ust. 1 lit. a** — zgoda (aparat/galeria) |
| **Komentarze, opisy, głosy** | Funkcjonowanie platformy zgłoszeń | **Art. 6 ust. 1 lit. b** — wykonanie usługi |
| **Token FCM / powiadomienia push** | Informowanie o podbiciu zgłoszenia | **Art. 6 ust. 1 lit. a** — zgoda na powiadomienia |
| **Tokeny sesyjne** | Utrzymanie bezpiecznej sesji | **Art. 6 ust. 1 lit. b** — wykonanie usługi |

---

## 5. Lokalizacja Infrastruktury, Retencja i Zabezpieczenia

### 5.1. Lokacje sieciowe i transfery transgraniczne

* **PostgreSQL (Data Connect):** region `europe-central2` (Europa).
* **Firebase Cloud Functions:** region `europe-central2`.
* **Firebase Storage:** infrastruktura globalna Google.
* Transfer poza EOG do Google LLC (USA) — na podstawie *EU-US Data Privacy Framework* i Standardowych Klauzul Umownych (SCC) Google.

### 5.2. Środki ochrony technicznej

* **Szyfrowanie w locie:** HTTPS/TLS między aplikacją a usługami Google.
* **Kontrola dostępu API:** Mutacje wymagają `@auth(level: USER)`; zapytanie kontekstu powiadomień ma `@auth(level: NO_ACCESS)` i jest dostępne wyłącznie dla Admin SDK (Cloud Functions).
* **Firebase Storage:** zapis tylko dla zalogowanego właściciela ścieżki (`request.auth.uid == userId`).
* **Sekrety:** `google-services.json`, `firebase_options.dart` poza repozytorium Git (`docs/CI-SECRETS.md`, GitHub Secrets).

### 5.3. Okres przechowywania

* **Profil użytkownika i token FCM:** do żądania usunięcia lub likwidacji konta.
* **Zgłoszenia, komentarze, głosy:** do usunięcia przez administratora lub likwidacji systemu (historia mapy zgłoszeń).
* **Cache lokalny (SharedPreferences):** do wyczyszczenia danych aplikacji lub odinstalowania.

---

## 6. Udostępnianie Danych Podmiotom Trzecim

Dane nie są sprzedawane. Odbiorcy:

1. **Google LLC / Google Cloud Platform** — Firebase Auth, Data Connect, Storage, Cloud Messaging, Cloud Functions (podmiot przetwarzający).
2. **Google Maps Platform** — renderowanie mapy (w tym przekazywanie współrzędnych do pobrania kafelków).
3. **Inni użytkownicy aplikacji** — w zakresie danych publicznych (zgłoszenia na mapie, komentarze, zdjęcia, identyfikatory w głosach).

---

## 7. Uprawnienia Użytkownika (RODO)

* **Prawo dostępu (art. 15)** — wgląd w przetwarzane dane (kontakt e-mail, sekcja 1).
* **Prawo do sprostowania (art. 16)** — dane profilu Google synchronizują się przy logowaniu (`upsertUser`); komentarze można edytować w aplikacji.
* **Prawo do usunięcia (art. 17)** — patrz sekcja 8.3.
* **Prawo do ograniczenia przetwarzania (art. 18)** i **przenoszenia danych (art. 20)**.
* **Prawo do cofnięcia zgody (art. 7 ust. 3)** — w dowolnym momencie: wyłączenie GPS, aparatu lub powiadomień w ustawieniach Androida.

Skarga do **PUODO**, ul. Moniuszki 1A, 00-014 Warszawa.

---

## 8. Procedura Wylogowania i Usuwania Danych

### 8.1. Wylogowanie

Z ekranu Profil/Ustawienia (`AuthService.signOut()`) kończy sesję na urządzeniu. **Nie usuwa** danych z PostgreSQL ani Firebase Storage.

### 8.2. Usuwanie i edycja treści przez użytkownika

* **Komentarze:** użytkownik może **edytować i usuwać** własne komentarze (`CommentService.editComment`, `CommentService.deleteComment`).
* **Zgłoszenia:** w wersji 0.2.0 **brak** przycisku w interfejsie do edycji lub usunięcia własnego zgłoszenia (funkcje backendowe istnieją, lecz nie są udostępnione w UI). W razie potrzeby usunięcia zgłoszenia — kontakt z Administratorem (sekcja 1).

### 8.3. Trwałe usunięcie konta

Pełna automatyzacja usuwania konta z poziomu aplikacji **nie została wdrożona** w wersji 0.2.0. Aby usunąć profil i powiązane dane, użytkownik wysyła żądanie na adres e-mail z sekcji 1, podając adres powiązany z kontem Google.

---

## 9. Zmiany Polityki

Administrator może aktualizować niniejszą politykę. Data i wersja na górze dokumentu wskazują ostatnią aktualizację. Przy istotnych zmianach użytkownicy zostaną poinformowani w aplikacji lub przy kolejnym logowaniu.

---
