import 'package:city_issues/services/auth_service.dart';
import 'package:city_issues/services/report_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

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
  });
}
