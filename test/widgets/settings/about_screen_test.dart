import 'package:city_issues/core/constants/app_info.dart';
import 'package:city_issues/features/settings/screens/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AboutScreen', () {
    testWidgets('shows app info and creators', (tester) async {
      await pumpScreen(
        tester,
        const AboutScreen(),
        surfaceSize: const Size(400, 900),
      );

      expect(find.text('O aplikacji'), findsOneWidget);
      expect(find.text(AppInfo.appName), findsOneWidget);
      expect(find.text('Wersja ${AppInfo.versionLabel}'), findsOneWidget);
      expect(find.text('Do czego służy'), findsOneWidget);
      expect(find.text('Twórcy'), findsOneWidget);

      for (final creator in AppInfo.creators) {
        expect(find.text(creator.name), findsOneWidget);
        expect(find.text(creator.role), findsOneWidget);
      }
    });
  });
}
