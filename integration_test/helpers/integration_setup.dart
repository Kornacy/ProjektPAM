import 'package:city_issues/app/firebase_bootstrap.dart';
import 'package:city_issues/services/report_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Initializes Firebase against local emulators and verifies seed data.
Future<void> setUpIntegrationTests() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  await FirebaseBootstrap.initialize(useEmulator: true);
  await _ensureSeededCategories();
}

Future<void> _ensureSeededCategories() async {
  final categories = await ReportService.instance.getCategories();
  if (categories.isNotEmpty) {
    return;
  }

  fail(
    'Emulator nie zawiera kategorii. '
    'Uruchom scripts/seed-emulator.mjs przed testami integracyjnymi.',
  );
}

Future<void> tearDownSignedInUser() async {
  await FirebaseAuth.instance.signOut();
}
