import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:city_issues/core/widgets/app_loading.dart';
import 'package:city_issues/features/auth/screens/login_screen.dart';
import 'package:city_issues/features/shell/main_shell.dart';
import 'package:city_issues/services/auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      initialData: AuthService.instance.currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return const Scaffold(
            body: AppLoading(message: 'Ładowanie aplikacji...'),
          );
        }
        if (snapshot.data != null) {
          return const MainShell();
        }
        return const LoginScreen();
      },
    );
  }
}
