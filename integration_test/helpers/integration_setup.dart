import 'package:city_issues/app/firebase_bootstrap.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'data_connect_retry.dart';

Future<void>? _setupFuture;

/// Initializes Firebase against local emulators and verifies seed data.
/// Safe to call from multiple test files — runs only once per process.
Future<void> setUpIntegrationTests() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  _setupFuture ??= _setUpIntegrationTestsImpl();
  return _setupFuture!;
}

Future<void> _setUpIntegrationTestsImpl() async {
  _assertEmulatorDartDefines();

  await FirebaseBootstrap.initialize(useEmulator: true);
  // Let the Data Connect WebSocket settle before the first query/mutation.
  await Future<void>.delayed(const Duration(seconds: 2));

  try {
    await _ensureSeededCategories();
  } catch (error) {
    fail(_connectionHelpMessage(error));
  }
}

void _assertEmulatorDartDefines() {
  if (!FirebaseBootstrap.useEmulator) {
    fail(
      'Brak --dart-define=USE_FIREBASE_EMULATOR=true.\n'
      'Uruchom testy przez .\\test-integration.ps1 lub dodaj dart-define do flutter test.',
    );
  }
}

Future<void> _ensureSeededCategories() async {
  final categories = await withDataConnectRetry(() async {
    final result = await DefaultConnector.instance.getCategories().ref().execute(
          fetchPolicy: QueryFetchPolicy.serverOnly,
        );
    return result.data.categories;
  });

  if (categories.isNotEmpty) {
    return;
  }

  fail(
    'Emulator nie zawiera kategorii.\n'
    'Uruchom seed: cd scripts; npm run seed (emulatory musza dzialac).',
  );
}

String _connectionHelpMessage(Object error) {
  final host = FirebaseBootstrap.resolveEmulatorHost();
  return '''
Nie udalo sie polaczyc z Firebase Emulator Suite (Data Connect).

Blad: $error

Host uzyty przez aplikacje: $host
USE_FIREBASE_EMULATOR: ${FirebaseBootstrap.useEmulator}
EMULATOR_HOST (dart-define): "${FirebaseBootstrap.emulatorHostOverride}"

Sprawdz:
1. Emulatory dzialaja (firebase emulators:start --only auth,dataconnect,storage)
2. Seed: cd scripts && npm run seed
3. Fizyczny telefon: EMULATOR_HOST = IP komputera w Wi-Fi (nie 10.0.2.2)
4. Emulator Androida: EMULATOR_HOST = 10.0.2.2
5. Firewall Windows: zezwol na porty 9099, 9399, 9199
6. Telefon i PC w tej samej sieci Wi-Fi

Pelny flow: .\\test-integration.ps1
''';
}

Future<void> tearDownSignedInUser() async {
  await FirebaseAuth.instance.signOut();
}
