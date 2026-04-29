import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/material.dart';
import 'package:city_issues/services/auth_service.dart';
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
      title: 'Test logowania',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _status = 'Niezalogowany';

  @override
  void initState() {
    super.initState();
    AuthService.instance.authStateChanges.listen((user) {
      setState(() {
        if (user != null) {
          _status = 'Zalogowany jako: ${user.email}';
        } else {
          _status = 'Niezalogowany';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test logowania')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                try {
                  await AuthService.instance.singInWithGoogle();
                } catch (e) {
                  setState(() => _status = 'Błąd: $e');
                }
              },
              child: const Text('Zaloguj przez Google'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await AuthService.instance.signOut();
              },
              child: const Text('Wyloguj'),
            ),
          ],
        ),
      ),
    );
  }
}