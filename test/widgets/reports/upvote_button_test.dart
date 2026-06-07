import 'package:city_issues/features/reports/widgets/upvote_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('UpvoteButton', () {
    testWidgets('shows initial upvote count and is enabled', (tester) async {
      await pumpWidget(
        tester,
        const UpvoteButton(reportId: 'report-1', initialCount: 5),
      );

      expect(find.text('Podbij (5)'), findsOneWidget);
      expect(find.byIcon(Icons.thumb_up_outlined), findsOneWidget);
      expect(find.textContaining('Podbij'), findsOneWidget);
    });

    testWidgets('shows zero count when there are no upvotes', (tester) async {
      await pumpWidget(
        tester,
        const UpvoteButton(reportId: 'report-2', initialCount: 0),
      );

      expect(find.text('Podbij (0)'), findsOneWidget);
    });
  });
}
