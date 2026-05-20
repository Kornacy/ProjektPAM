import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/material.dart';
import 'package:city_issues/app/theme.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/features/auth/auth_gate.dart';
import 'package:city_issues/features/splash/app_splash_screen.dart';
import 'package:city_issues/firebase_options.dart';
import 'package:city_issues/services/app_preferences.dart';
import 'package:city_issues/services/auth_service.dart';

// TODO: ustaw false dla produkcji
const bool _useEmulator = false;
const String _emulatorHost = '192.168.1.13';

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
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (_useEmulator) {
        FirebaseDataConnect.instanceFor(
          app: Firebase.app(),
          connectorConfig: DefaultConnector.connectorConfig,
        ).useDataConnectEmulator(_emulatorHost, 9399);
      }

      await AuthService.instance.initialize();
      await AppPreferences.instance.load();
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
