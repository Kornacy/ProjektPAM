import 'package:city_issues/core/utils/user_facing_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  group('UserFacingError', () {
    test('maps location service errors', () {
      expect(
        UserFacingError.location(
          Exception('Usługi lokalizacji są wyłączone.'),
        ),
        'Włącz usługi lokalizacji w ustawieniach telefonu.',
      );
    });

    test('maps network errors', () {
      expect(
        UserFacingError.loadReports(
          Exception('SocketException: Failed host lookup'),
        ),
        'Brak połączenia z internetem. Sprawdź sieć i spróbuj ponownie.',
      );
    });

    test('uses fallback for unknown errors', () {
      expect(
        UserFacingError.submitReport(
          Exception('unhandled exception: internal server failure'),
        ),
        'Nie udało się wysłać zgłoszenia.',
      );
    });

    test('maps GoogleSignInException canceled to null', () {
      expect(
        UserFacingError.googleSignIn(
          const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
        ),
        isNull,
      );
    });

    test('maps GoogleSignInException interrupted', () {
      expect(
        UserFacingError.googleSignIn(
          const GoogleSignInException(
            code: GoogleSignInExceptionCode.interrupted,
          ),
        ),
        'Logowanie zostało przerwane. Spróbuj ponownie.',
      );
    });

    test('maps GoogleSignInException clientConfigurationError', () {
      expect(
        UserFacingError.googleSignIn(
          const GoogleSignInException(
            code: GoogleSignInExceptionCode.clientConfigurationError,
          ),
        ),
        contains('konfiguracji logowania Google'),
      );
    });
  });
}
