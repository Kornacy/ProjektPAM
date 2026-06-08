import 'package:city_issues/dataconnect_generated/default.dart';

/// Sample API models for frontend widget tests (no network calls).
class TestFixtures {
  static GetReportsReportsCategory get sampleCategory =>
      GetReportsReportsCategory(
        name: 'Drogi',
        iconName: 'road',
        pinColor: '#FF5722',
      );

  static GetReportsReports get sampleReport => GetReportsReports(
        id: 'report-1',
        latitude: 52.2297,
        longitude: 21.0122,
        description: 'Dziura na chodniku przy przejściu',
        status: 'NOWE',
        category: sampleCategory,
        reportPhotos_on_report: const [],
        upvotes_on_report: [
          GetReportsReportsUpvotesOnReport(id: 'up-1'),
          GetReportsReportsUpvotesOnReport(id: 'up-2'),
        ],
      );

  static GetReportsReports get sampleReportWithoutDescription =>
      GetReportsReports(
        id: 'report-2',
        latitude: 52.23,
        longitude: 21.01,
        description: null,
        status: 'W_TRAKCIE',
        category: GetReportsReportsCategory(
          name: 'Oświetlenie',
          iconName: 'lightbulb',
          pinColor: '#FFC107',
        ),
        reportPhotos_on_report: const [],
        upvotes_on_report: const [],
      );

  static List<GetCategoriesCategories> get sampleCategories => [
        GetCategoriesCategories(
          id: 'cat-1',
          name: 'Drogi',
          iconName: 'road',
          pinColor: '#FF5722',
        ),
        GetCategoriesCategories(
          id: 'cat-2',
          name: 'Oświetlenie',
          iconName: 'lightbulb',
          pinColor: '#FFC107',
        ),
      ];
}
