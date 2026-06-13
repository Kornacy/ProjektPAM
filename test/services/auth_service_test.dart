import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

DeleteAccountData _deleteAccountData({bool deleted = true}) {
  return DeleteAccountData(
    comment_deleteMany: 0,
    upvote_deleteMany: 0,
    reportPhoto_deleteMany: 0,
    report_deleteMany: 0,
    user_delete: deleted
        ? DeleteAccountUserDelete(id: 'test-uid')
        : null,
  );
}

void main() {
  group('AuthService.mapAuthError', () {
    String map(String code, {String? message}) {
      return AuthService.mapAuthError(
        FirebaseAuthException(code: code, message: message),
      );
    }

    test('maps wrong-password and invalid-credential', () {
      expect(map('wrong-password'), 'Nieprawidłowy e-mail lub hasło.');
      expect(map('invalid-credential'), 'Nieprawidłowy e-mail lub hasło.');
    });

    test('maps email-already-in-use', () {
      expect(map('email-already-in-use'), 'Ten adres e-mail jest już zarejestrowany.');
    });

    test('maps user-not-found', () {
      expect(map('user-not-found'), 'Nie znaleziono użytkownika o podanym adresie e-mail.');
    });

    test('maps weak-password', () {
      expect(map('weak-password'), 'Hasło jest zbyt słabe (min. 8 znaków).');
    });

    test('maps invalid-email', () {
      expect(map('invalid-email'), 'Nieprawidłowy adres e-mail.');
    });

    test('maps too-many-requests', () {
      expect(map('too-many-requests'), 'Zbyt wiele prób. Spróbuj ponownie później.');
    });

    test('falls back to exception message', () {
      expect(map('unknown-code', message: 'Custom error'), 'Custom error');
    });

    test('falls back to generic message when message is null', () {
      expect(map('unknown-code'), 'Wystąpił błąd uwierzytelniania.');
    });
  });

  group('AuthService.ensureUserProfile', () {
    test('throws when user is not signed in', () async {
      final authService = AuthService.forTesting(
        firebaseAuth: MockFirebaseAuth(signedIn: false),
      );

      await expectLater(
        authService.ensureUserProfile(),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('Musisz być zalogowany'),
          ),
        ),
      );
    });
  });

  group('AuthService.deleteAccount', () {
    test('throws when user is not signed in', () async {
      final authService = AuthService.forTesting(
        firebaseAuth: MockFirebaseAuth(signedIn: false),
      );

      await expectLater(
        authService.deleteAccount(),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('Musisz być zalogowany'),
          ),
        ),
      );
    });

    test('throws when database deletion returns no user row', () async {
      final authService = AuthService.forTesting(
        firebaseAuth: MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'test-uid'),
        ),
        deleteAccountMutation: () async => _deleteAccountData(deleted: false),
      );

      await expectLater(
        authService.deleteAccount(),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('Nie udało się usunąć konta'),
          ),
        ),
      );
    });
  });
}
