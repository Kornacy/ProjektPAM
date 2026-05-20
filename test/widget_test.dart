import 'package:flutter_test/flutter_test.dart';
import 'package:city_issues/core/utils/auth_validation.dart';

void main() {
  group('AuthValidation', () {
    test('validateEmail rejects empty', () {
      expect(AuthValidation.validateEmail(null), isNotNull);
      expect(AuthValidation.validateEmail(''), isNotNull);
    });

    test('validateEmail accepts valid email', () {
      expect(AuthValidation.validateEmail('user@example.com'), isNull);
    });

    test('validateEmail rejects invalid format', () {
      expect(AuthValidation.validateEmail('not-an-email'), isNotNull);
    });

    test('validatePassword requires 8 characters', () {
      expect(AuthValidation.validatePassword('short'), isNotNull);
      expect(AuthValidation.validatePassword('longenough'), isNull);
    });

    test('validatePasswordConfirm matches password', () {
      expect(
        AuthValidation.validatePasswordConfirm('password1', 'password1'),
        isNull,
      );
      expect(
        AuthValidation.validatePasswordConfirm('password1', 'other'),
        isNotNull,
      );
    });
  });
}
