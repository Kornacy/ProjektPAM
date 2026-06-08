import 'package:city_issues/features/reports/screens/report_detail_screen.dart';
import 'package:city_issues/features/reports/widgets/upvote_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

void main() {
  group('ReportDetailScreen', () {
    testWidgets('renders report details and comments section', (tester) async {
      await pumpWidget(
        tester,
        ReportDetailScreen(
          report: TestFixtures.sampleReport,
          commentsSection: const SizedBox.shrink(),
          upvoteButton: const UpvoteButton(
            reportId: 'report-1',
            initialCount: 2,
            isSignedIn: true,
          ), // renders "2 osoby wspierają"
        ),
        surfaceSize: const Size(400, 900),
      );

      expect(find.text('Szczegóły zgłoszenia'), findsOneWidget);
      expect(find.text('Drogi'), findsWidgets);
      expect(find.text('Nowe'), findsOneWidget);
      expect(find.textContaining('Dziura na chodniku'), findsOneWidget);
      expect(find.text('2 osoby wspierają'), findsOneWidget);
      expect(find.textContaining('Zgłoszono:'), findsOneWidget);
    });

    testWidgets('calls onBack from app bar leading button', (tester) async {
      var backPressed = false;

      await pumpWidget(
        tester,
        ReportDetailScreen(
          report: TestFixtures.sampleReport,
          onBack: () => backPressed = true,
          commentsSection: const SizedBox.shrink(),
          upvoteButton: const SizedBox.shrink(),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(backPressed, isTrue);
    });

    testWidgets('calls onBack on system back via PopScope', (tester) async {
      var backPressed = false;

      await pumpWidget(
        tester,
        ReportDetailScreen(
          report: TestFixtures.sampleReport,
          onBack: () => backPressed = true,
          commentsSection: const SizedBox.shrink(),
          upvoteButton: const SizedBox.shrink(),
        ),
      );

      final handled = await tester.binding.handlePopRoute();
      await tester.pump();

      expect(handled, isTrue);
      expect(backPressed, isTrue);
    });
  });
}
