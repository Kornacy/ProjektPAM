import 'package:city_issues/features/onboarding/app_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppTourOverlay', () {
    testWidgets('shows welcome step and triggers next', (tester) async {
      var nextCalled = false;
      const step = AppTourStep(
        title: 'Witaj w City Issues',
        body: 'Krótki opis aplikacji.',
        stackIndex: 0,
        highlight: AppTourHighlight.welcome,
        showLogo: true,
      );

      await pumpWidget(
        tester,
        AppTourOverlay(
          step: step,
          stepIndex: 0,
          stepCount: 3,
          navBarKey: GlobalKey(),
          isLast: false,
          isReplay: false,
          onNext: () => nextCalled = true,
          onSkip: () {},
        ),
        surfaceSize: const Size(400, 800),
      );

      expect(find.text('Witaj w City Issues'), findsOneWidget);
      expect(find.text('Krok 1 z 3'), findsOneWidget);
      expect(find.text('Dalej'), findsOneWidget);

      await tester.tap(find.text('Dalej'));
      await tester.pump();

      expect(nextCalled, isTrue);
    });

    testWidgets('shows skip label and triggers onSkip', (tester) async {
      var skipped = false;

      await pumpWidget(
        tester,
        AppTourOverlay(
          step: const AppTourStep(
            title: 'Mapa',
            body: 'Opis mapy.',
            stackIndex: 0,
          ),
          stepIndex: 1,
          stepCount: 4,
          navBarKey: GlobalKey(),
          isLast: false,
          isReplay: false,
          onNext: () {},
          onSkip: () => skipped = true,
        ),
      );

      await tester.tap(find.text('Pomiń'));
      await tester.pump();

      expect(skipped, isTrue);
    });

    testWidgets('shows finish label on last step', (tester) async {
      await pumpWidget(
        tester,
        AppTourOverlay(
          step: const AppTourStep(
            title: 'Koniec',
            body: 'Gotowe.',
            stackIndex: 0,
          ),
          stepIndex: 3,
          stepCount: 4,
          navBarKey: GlobalKey(),
          isLast: true,
          isReplay: true,
          onNext: () {},
          onSkip: () {},
        ),
      );

      expect(find.text('Rozpocznij'), findsOneWidget);
      expect(find.text('Zamknij'), findsOneWidget);
    });
  });

  group('AppTourSteps', () {
    test('builds expected number of tour steps', () {
      final steps = AppTourSteps.build(
        mapFiltersKey: GlobalKey(),
        mapFabKey: GlobalKey(),
        settingsHelpKey: GlobalKey(),
      );

      expect(steps.length, 8);
      expect(steps.first.title, 'Witaj w City Issues');
      expect(steps.last.title, 'Pomoc w aplikacji');
    });
  });
}
