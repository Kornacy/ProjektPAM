import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:city_issues/services/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
    // Nasłuchuj zmian stanu zalogowania
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