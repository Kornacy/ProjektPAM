import 'package:flutter/material.dart';
import 'package:city_issues/app/theme.dart';
import 'package:city_issues/features/auth/auth_gate.dart';
import 'package:city_issues/services/app_preferences.dart';

class CityIssuesApp extends StatelessWidget {
  const CityIssuesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences.instance,
      builder: (context, _) {
        final prefs = AppPreferences.instance;
        final accent = prefs.accentColor;

        return MaterialApp(
          title: 'City Issues',
          debugShowCheckedModeBanner: false,
          themeMode: prefs.themeMode,
          theme: AppTheme.light(accent),
          darkTheme: AppTheme.dark(accent),
          home: prefs.isLoaded
              ? const AuthGate()
              : const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
        );
      },
    );
  }
}
