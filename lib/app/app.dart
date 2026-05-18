import 'package:flutter/material.dart';
import 'package:city_issues/app/theme.dart';
import 'package:city_issues/features/auth/auth_gate.dart';

class CityIssuesApp extends StatelessWidget {
  const CityIssuesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'City Issues',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
