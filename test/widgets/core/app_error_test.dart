import 'package:city_issues/core/widgets/app_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppError', () {
    testWidgets('shows message without retry when onRetry is null', (tester) async {
      await pumpWidget(tester, const AppError(message: 'Coś poszło nie tak.'));

      expect(find.text('Coś poszło nie tak.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Spróbuj ponownie'), findsNothing);
    });

    testWidgets('invokes onRetry when retry button is tapped', (tester) async {
      var retried = false;

      await pumpWidget(
        tester,
        AppError(
          message: 'Błąd sieci.',
          onRetry: () => retried = true,
        ),
      );

      await tester.tap(find.text('Spróbuj ponownie'));
      await tester.pump();

      expect(retried, isTrue);
    });
  });
}
