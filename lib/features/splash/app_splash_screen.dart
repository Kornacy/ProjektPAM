import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ekran startowy z logo aplikacji (SVG marki City Issues).
class AppSplashScreen extends StatelessWidget {
  const AppSplashScreen({super.key});

  static const Color background = Color(0xFF07004D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: SvgPicture.asset(
            'assets/images/app_logo.svg',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
