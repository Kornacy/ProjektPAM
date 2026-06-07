import 'package:city_issues/core/widgets/form_error_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('FormErrorBanner', () {
    testWidgets('displays error message and icon', (tester) async {
      await pumpWidget(
        tester,
        const FormErrorBanner(message: 'Nieprawidłowe dane formularza.'),
      );

      expect(find.text('Nieprawidłowe dane formularza.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
