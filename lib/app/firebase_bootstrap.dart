import 'dart:io' show Platform;

import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Shared Firebase initialization for the app and integration tests.
class FirebaseBootstrap {
  static const useEmulator = bool.fromEnvironment(
    'USE_FIREBASE_EMULATOR',
    defaultValue: false,
  );

  static const emulatorHostOverride = String.fromEnvironment(
    'EMULATOR_HOST',
    defaultValue: '',
  );

  static const authEmulatorPort = int.fromEnvironment(
    'AUTH_EMULATOR_PORT',
    defaultValue: 9099,
  );

  static const dataConnectEmulatorPort = int.fromEnvironment(
    'DATACONNECT_EMULATOR_PORT',
    defaultValue: 9399,
  );

  static const storageEmulatorPort = int.fromEnvironment(
    'STORAGE_EMULATOR_PORT',
    defaultValue: 9199,
  );

  static const functionsEmulatorPort = int.fromEnvironment(
    'FUNCTIONS_EMULATOR_PORT',
    defaultValue: 5001,
  );

  /// Resolves emulator host based on platform when [EMULATOR_HOST] is not set.
  static String resolveEmulatorHost() {
    if (emulatorHostOverride.isNotEmpty) {
      return emulatorHostOverride;
    }
    if (kIsWeb) {
      return 'localhost';
    }
    if (Platform.isAndroid) {
      return '10.0.2.2';
    }
    return 'localhost';
  }

  static bool _emulatorConfigured = false;

  static Future<void> initialize({
    bool? useEmulator,
    String? emulatorHost,
  }) async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final shouldUseEmulator = useEmulator ?? FirebaseBootstrap.useEmulator;
    if (!shouldUseEmulator || _emulatorConfigured) {
      return;
    }

    final host = emulatorHost ?? resolveEmulatorHost();

    await FirebaseAuth.instance.useAuthEmulator(host, authEmulatorPort);

    FirebaseDataConnect.instanceFor(
      app: Firebase.app(),
      connectorConfig: DefaultConnector.connectorConfig,
    ).useDataConnectEmulator(host, dataConnectEmulatorPort);

    await FirebaseStorage.instance.useStorageEmulator(
      host,
      storageEmulatorPort,
    );

    FirebaseFunctions.instance.useFunctionsEmulator(
      host,
      functionsEmulatorPort,
    );

    _emulatorConfigured = true;
  }
}
