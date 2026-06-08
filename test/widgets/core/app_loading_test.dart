import 'package:city_issues/core/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppLoading', () {
    testWidgets('shows progress indicator only when message is null', (tester) async {
      await pumpWidget(tester, const AppLoading());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('shows optional loading message', (tester) async {
      await pumpWidget(
        tester,
        const AppLoading(message: 'Ładowanie mapy...'),
      );

      expect(find.text('Ładowanie mapy...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
