import 'package:flutter/material.dart';
import 'package:city_issues/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
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