import 'package:city_issues/services/auth_service.dart';
import 'package:city_issues/services/report_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('ReportService auth guards', () {
    late ReportService reportService;

    setUp(() {
      reportService = ReportService.forTesting(
        authService: AuthService.forTesting(
          firebaseAuth: MockFirebaseAuth(signedIn: false),
        ),
      );
    });

    test('upvoteReport throws when user is not signed in', () async {
      await expectLater(
        reportService.upvoteReport('report-1'),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('Musisz być zalogowany'),
          ),
        ),
      );
    });

    test('removeUpvote throws when user is not signed in', () async {
      await expectLater(
        reportService.removeUpvote('report-1'),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('Musisz być zalogowany'),
          ),
        ),
      );
    });

    test('editReport throws when user is not signed in', () async {
      await expectLater(
        reportService.editReport(
          reportId: 'report-1',
          categoryId: 'DROGI',
          location: const LatLng(52.2297, 21.0122),
        ),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('Musisz być zalogowany'),
          ),
        ),
      );
    });

    test('deleteReport throws when user is not signed in', () async {
      await expectLater(
        reportService.deleteReport('report-1'),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('Musisz być zalogowany'),
          ),
        ),
      );
    });
  });
}
