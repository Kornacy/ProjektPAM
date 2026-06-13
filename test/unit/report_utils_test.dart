import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReportUtils', () {
    test('statusLabel maps known statuses', () {
      expect(ReportUtils.statusLabel('NOWE'), 'Nowe');
      expect(ReportUtils.statusLabel('NAPRAWIONE'), 'Naprawione');
      expect(ReportUtils.statusLabel('W_TRAKCIE'), 'W trakcie');
    });

    test('statusColor returns distinct colors', () {
      expect(ReportUtils.statusColor('NAPRAWIONE'), Colors.green);
      expect(ReportUtils.statusColor('W_TRAKCIE'), Colors.orange);
    });

    test('parsePinColor parses hex', () {
      final color = ReportUtils.parsePinColor('#FF0000');
      expect(color, const Color(0xFFFF0000));
    });

    test('categoryIcon returns icon for known names', () {
      expect(ReportUtils.categoryIcon('road'), Icons.add_road);
      expect(ReportUtils.categoryIcon('unknown'), Icons.report_problem_outlined);
    });

    test('formatDateTime formats timestamp in local time', () {
      final formatted = ReportUtils.formatDateTime(Timestamp(0, 1_704_067_200));
      expect(formatted, contains('2024'));
      expect(formatted, contains('.'));
      expect(formatted, contains(':'));
    });

    test('upvoteCount ignores orphaned upvotes without user', () {
      final upvotes = [
        GetReportsReportsUpvotesOnReport(
          id: 'up-1',
          user: GetReportsReportsUpvotesOnReportUser(id: 'user-a'),
        ),
        GetReportsReportsUpvotesOnReport(
          id: 'up-2',
          user: GetReportsReportsUpvotesOnReportUser(id: ''),
        ),
      ];

      expect(ReportUtils.upvoteCount(upvotes), 1);
      expect(ReportUtils.userHasUpvoted(upvotes, 'user-a'), isTrue);
      expect(ReportUtils.userHasUpvoted(upvotes, null), isFalse);
    });
  });
}
