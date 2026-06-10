import 'package:city_issues/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/integration_setup.dart';
import '../helpers/test_auth.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService integration', () {
    setUpAll(() async {
      await setUpIntegrationTests();
    });

    tearDown(() async {
      await tearDownSignedInUser();
    });

    testWidgets('register and sign in test user on Auth emulator',
        (tester) async {
      final credential = await signInTestUser();

      expect(credential.user, isNotNull);
      expect(credential.user!.email, testUserEmail);
      expect(FirebaseAuth.instance.currentUser, isNotNull);
    });

    testWidgets('ensureUserProfile upserts user in Data Connect',
        (tester) async {
      await signInAndEnsureProfile();

      expect(AuthService.instance.isSignedIn, isTrue);
      expect(AuthService.instance.currentUser?.email, testUserEmail);
    });
  });
}
