import 'package:city_issues/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/data_connect_retry.dart';
import '../helpers/integration_setup.dart';
import '../helpers/test_auth.dart';

void registerAuthServiceSuite() {
  group('AuthService integration', () {
    setUpAll(() async {
      await setUpIntegrationTests();
    });

    tearDown(() async {
      await tearDownSignedInUser();
    });

    testWidgets('register and sign in test user on Auth emulator',
        (tester) async {
      final credential = await withDataConnectRetry(signInTestUser);

      expect(credential.user, isNotNull);
      expect(credential.user!.email, testUserEmail);
      expect(FirebaseAuth.instance.currentUser, isNotNull);
    });

    testWidgets('ensureUserProfile upserts user in Data Connect',
        (tester) async {
      await withDataConnectRetry(signInAndEnsureProfile);

      expect(AuthService.instance.isSignedIn, isTrue);
      expect(AuthService.instance.currentUser?.email, testUserEmail);
    });
  });
}
