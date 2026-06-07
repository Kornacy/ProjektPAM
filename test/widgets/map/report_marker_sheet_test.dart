import 'package:city_issues/features/map/widgets/report_marker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

void main() {
  group('ReportMarkerSheet', () {
    testWidgets('shows report summary and opens details on button tap', (tester) async {
      var opened = false;
      final report = TestFixtures.sampleReport;

      await pumpWidget(
        tester,
        ReportMarkerSheet(
          report: report,
          onOpenDetail: () => opened = true,
        ),
        surfaceSize: const Size(400, 700),
      );

      expect(find.text('Drogi'), findsOneWidget);
      expect(find.text('Nowe'), findsOneWidget);
      expect(find.textContaining('Dziura na chodniku'), findsOneWidget);
      expect(find.text('Podbij (2)'), findsOneWidget);

      await tester.tap(find.text('Zobacz szczegóły'));
      await tester.pump();

      expect(opened, isTrue);
    });

    testWidgets('hides description section when report has no description', (tester) async {
      await pumpWidget(
        tester,
        ReportMarkerSheet(
          report: TestFixtures.sampleReportWithoutDescription,
          onOpenDetail: () {},
        ),
        surfaceSize: const Size(400, 700),
      );

      expect(find.text('Oświetlenie'), findsOneWidget);
      expect(find.text('W trakcie'), findsOneWidget);
      expect(find.text('Podbij (0)'), findsOneWidget);
    });
  });
}
