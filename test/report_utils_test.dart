import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:city_issues/core/utils/report_utils.dart';

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
  });
}
