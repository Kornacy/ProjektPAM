import 'package:city_issues/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

const testUserEmail = 'integration-test@city-issues.test';
const testUserPassword = 'integration-test-pass-123';

/// Signs in a deterministic test user on the Auth emulator.
Future<UserCredential> signInTestUser() async {
  final auth = FirebaseAuth.instance;

  try {
    return await auth.createUserWithEmailAndPassword(
      email: testUserEmail,
      password: testUserPassword,
    );
  } on FirebaseAuthException catch (error) {
    if (error.code == 'email-already-in-use') {
      return auth.signInWithEmailAndPassword(
        email: testUserEmail,
        password: testUserPassword,
      );
    }
    rethrow;
  }
}

/// Ensures the user exists in Firebase Auth and Data Connect.
Future<void> signInAndEnsureProfile() async {
  await signInTestUser();
  await AuthService.instance.ensureUserProfile();
}
