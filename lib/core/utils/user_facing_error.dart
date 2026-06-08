import 'package:google_sign_in/google_sign_in.dart';

class UserFacingError {
  UserFacingError._();

  static String message(
    Object error, {
    String fallback = 'Coś poszło nie tak. Spróbuj ponownie.',
  }) {
    if (error is GoogleSignInException) {
      return googleSignIn(error) ?? fallback;
    }

    final text = _normalize(error);

    if (text.contains('usługi lokalizacji') ||
        text.contains('location service')) {
      return 'Włącz usługi lokalizacji w ustawieniach telefonu.';
    }
    if (text.contains('uprawnień') || text.contains('permission')) {
      return 'Brak dostępu do lokalizacji. Zezwól na nią w ustawieniach aplikacji.';
    }
    if (_isNetworkError(text)) {
      return 'Brak połączenia z internetem. Sprawdź sieć i spróbuj ponownie.';
    }
    if (text.contains('timeout') || text.contains('timed out')) {
      return 'Przekroczono czas oczekiwania. Spróbuj ponownie.';
    }
    if (text.contains('unauthenticated') || text.contains('not authorized')) {
      return 'Sesja wygasła. Zaloguj się ponownie.';
    }

    if (text.length <= 120 &&
        !text.contains('exception') &&
        !text.contains('error:')) {
      return _capitalizeFirst(text);
    }

    return fallback;
  }

  static String loadReports(Object error) =>
      message(error, fallback: 'Nie udało się załadować zgłoszeń.');

  static String loadCategories(Object error) =>
      message(error, fallback: 'Nie udało się pobrać kategorii.');

  static String loadMyReports(Object error) =>
      message(error, fallback: 'Nie udało się pobrać Twoich zgłoszeń.');

  static String submitReport(Object error) =>
      message(error, fallback: 'Nie udało się wysłać zgłoszenia.');

  static String upvote(Object error) =>
      message(error, fallback: 'Nie udało się oddać głosu.');

  static String loadComments(Object error) =>
      message(error, fallback: 'Nie udało się załadować komentarzy.');

  static String addComment(Object error) =>
      message(error, fallback: 'Nie udało się dodać komentarza.');

  static String editComment(Object error) =>
      message(error, fallback: 'Nie udało się edytować komentarza.');

  static String deleteComment(Object error) =>
      message(error, fallback: 'Nie udało się usunąć komentarza.');

  static String location(Object error) =>
      message(error, fallback: 'Nie udało się ustalić lokalizacji.');

  /// Zwraca `null`, gdy użytkownik anulował logowanie — wtedy nie pokazuj błędu.
  static String? googleSignIn(Object error) {
    if (error is! GoogleSignInException) {
      return message(error, fallback: 'Nie udało się zalogować przez Google.');
    }

    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
        return null;
      case GoogleSignInExceptionCode.interrupted:
        return 'Logowanie zostało przerwane. Spróbuj ponownie.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Błąd konfiguracji logowania Google. Skontaktuj się z administratorem aplikacji.';
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Usługa Google Sign-In jest niedostępna. Spróbuj ponownie później.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Nie można wyświetlić ekranu logowania. Spróbuj ponownie.';
      case GoogleSignInExceptionCode.userMismatch:
        return 'Wybrano inne konto Google. Wyloguj się i spróbuj ponownie.';
      case GoogleSignInExceptionCode.unknownError:
        final description = error.description?.trim();
        if (description != null && description.isNotEmpty) {
          return description;
        }
        return 'Nie udało się zalogować przez Google.';
    }
  }

  static String auth(Object error) =>
      googleSignIn(error) ??
      message(error, fallback: 'Nie udało się zalogować.');

  static String _normalize(Object error) {
    var text = error.toString();
    if (text.startsWith('Exception: ')) {
      text = text.substring('Exception: '.length);
    }
    return text.toLowerCase();
  }

  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static bool _isNetworkError(String text) {
    return text.contains('socketexception') ||
        text.contains('network') ||
        text.contains('failed host lookup') ||
        text.contains('connection refused') ||
        text.contains('connection reset');
  }
}
