import 'package:city_issues/app/firebase_bootstrap.dart';
import 'package:city_issues/services/report_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void>? _setupFuture;

/// Initializes Firebase against local emulators and verifies seed data.
/// Safe to call from multiple test files — runs only once per process.
Future<void> setUpIntegrationTests() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  _setupFuture ??= _setUpIntegrationTestsImpl();
  return _setupFuture!;
}

Future<void> _setUpIntegrationTestsImpl() async {
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
