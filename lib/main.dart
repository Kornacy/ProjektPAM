import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/material.dart';
import 'package:city_issues/app/app.dart';
import 'package:city_issues/services/auth_service.dart';
import 'firebase_options.dart';
import 'package:city_issues/dataconnect_generated/default.dart';

// TODO: ustaw false dla produkcji
const bool _useEmulator = true;
const String _emulatorHost = '192.168.1.13';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (_useEmulator) {
    FirebaseDataConnect.instanceFor(
      app: Firebase.app(),
      connectorConfig: DefaultConnector.connectorConfig,
    ).useDataConnectEmulator(_emulatorHost, 9399);
  }

  await AuthService.instance.initialize();
  runApp(const CityIssuesApp());
}
