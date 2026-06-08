import 'package:city_issues/features/reports/widgets/upvote_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('UpvoteButton', () {
    testWidgets('shows support bar with count when signed in', (tester) async {
      await pumpWidget(
        tester,
        const UpvoteButton(
          reportId: 'report-1',
          initialCount: 5,
          isSignedIn: true,
        ),
      );

      expect(find.text('5 osób wspiera'), findsOneWidget);
      expect(find.text('Podbij'), findsOneWidget);
      expect(find.byIcon(Icons.thumb_up_outlined), findsOneWidget);
    });

    testWidgets('shows active state when user already upvoted', (tester) async {
      await pumpWidget(
        tester,
        const UpvoteButton(
          reportId: 'report-1',
          initialCount: 3,
          isSignedIn: true,
          initialHasUpvoted: true,
        ),
      );

      expect(find.text('3 osoby wspierają'), findsOneWidget);
      expect(find.text('Podbite'), findsOneWidget);
      expect(find.text('Wspierasz to zgłoszenie'), findsOneWidget);
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
    });

    testWidgets('shows login hint when not signed in', (tester) async {
      await pumpWidget(
        tester,
        const UpvoteButton(
          reportId: 'report-2',
          initialCount: 0,
          isSignedIn: false,
        ),
      );

      expect(find.text('Brak poparcia'), findsOneWidget);
      expect(find.text('Zaloguj się, aby oddać głos'), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
    });
  });
}
