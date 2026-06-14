import 'package:flutter/material.dart';
import 'package:city_issues/app/firebase_bootstrap.dart';
import 'package:city_issues/app/theme.dart';
import 'package:city_issues/features/auth/auth_gate.dart';
import 'package:city_issues/features/splash/app_splash_screen.dart';
import 'package:city_issues/services/app_preferences.dart';
import 'package:city_issues/services/auth_service.dart';
import 'package:city_issues/services/notification_service.dart';

class CityIssuesApp extends StatefulWidget {
  const CityIssuesApp({super.key});

  @override
  State<CityIssuesApp> createState() => _CityIssuesAppState();
}

class _CityIssuesAppState extends State<CityIssuesApp> {
  bool _initialized = false;
  Object? _initError;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await FirebaseBootstrap.initialize();

      await AuthService.instance.initialize();
      await AuthService.instance.waitForAuthReady();
      if (AuthService.instance.isSignedIn) {
        await AuthService.instance.ensureUserProfile();
      }
      await AppPreferences.instance.load();
      await NotificationService.instance.initialize();
    } catch (e) {
      _initError = e;
    }

    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        title: 'City Issues',
        debugShowCheckedModeBanner: false,
        home: AppSplashScreen(),
      );
    }

    if (_initError != null) {
      return MaterialApp(
        title: 'City Issues',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppSplashScreen.background,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Nie udało się uruchomić aplikacji:\n$_initError',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
          home: const AuthGate(),
        );
      },
    );
  }
}
