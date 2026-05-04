import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/material.dart';
import 'package:city_issues/services/auth_service.dart';
import 'package:city_issues/screens/auth_screen.dart';
import 'package:city_issues/screens/map_screen.dart';
import 'firebase_options.dart';
import 'package:city_issues/dataconnect_generated/default.dart';

//TODO Zmienić na false dla produkcji
const bool _useEmulator = true;
const String _emulatorHost = '192.168.0.42';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (_useEmulator) {
    FirebaseDataConnect.instanceFor(
      app: Firebase.app(),
      connectorConfig: DefaultConnector.connectorConfig,
    ).useDataConnectEmulator(_emulatorHost, 9399);
  }

  await AuthService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'City Issues',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('City Issues')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              ),
              child: const Text('Test logowania'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapScreen()),
              ),
              child: const Text('Mapa'),
            ),
          ],
        ),
      ),
    );
  }
}