import 'dart:io';

import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/services/auth_service.dart';
import 'package:city_issues/services/comment_service.dart';
import 'package:city_issues/services/report_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/integration_setup.dart';
import '../helpers/test_auth.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('ReportService integration', () {
    setUpAll(() async {
      await setUpIntegrationTests();
    });

    tearDown(() async {
      await tearDownSignedInUser();
    });

    testWidgets('getCategories returns seeded categories', (tester) async {
      final categories = await ReportService.instance.getCategories();

      expect(categories, isNotEmpty);
      expect(categories.any((category) => category.name == 'Drogi'), isTrue);
      expect(
        categories.any((category) => category.name == 'Oświetlenie'),
        isTrue,
      );
    });

    testWidgets('signed-in user can create report and list it in my reports',
        (tester) async {
      await signInAndEnsureProfile();

      await ReportService.instance.createReport(
        categoryId: 'DROGI',
        description: 'Test integracyjny – dziura w chodniku',
        photos: <File>[],
        selectedLocation: const LatLng(52.2297, 21.0122),
      );

      final myReports = await ReportService.instance.getMyReports();

      expect(myReports, isNotEmpty);
      expect(
        myReports.any(
          (report) =>
              report.description == 'Test integracyjny – dziura w chodniku',
        ),
        isTrue,
      );
      expect(myReports.first.status, 'NOWE');
    });

    testWidgets('signed-in user can upvote an existing report', (tester) async {
      await signInAndEnsureProfile();

      await ReportService.instance.createReport(
        categoryId: 'OSWIETLENIE',
        description: 'Zgłoszenie pod test głosowania',
        photos: <File>[],
        selectedLocation: const LatLng(52.228, 21.011),
      );

      final reports = await ReportService.instance.getReports();
      expect(reports, isNotEmpty);

      final reportId = reports.first.id;
      final userId = AuthService.instance.currentUser!.uid;

      await ReportService.instance.upvoteReport(reportId);

      final updated = await ReportService.instance.getReports();
      final target = updated.firstWhere((report) => report.id == reportId);

      expect(
        ReportUtils.userHasUpvoted(target.upvotes_on_report, userId),
        isTrue,
      );

      await ReportService.instance.removeUpvote(reportId);

      final afterRemove = await ReportService.instance.getReports();
      final removedTarget =
          afterRemove.firstWhere((report) => report.id == reportId);

      expect(
        ReportUtils.userHasUpvoted(removedTarget.upvotes_on_report, userId),
        isFalse,
      );
    });

    testWidgets('signed-in user can add and read comments on a report',
        (tester) async {
      await signInAndEnsureProfile();

      await ReportService.instance.createReport(
        categoryId: 'INNE',
        description: 'Zgłoszenie pod komentarze integracyjne',
        photos: <File>[],
        selectedLocation: const LatLng(52.23, 21.01),
      );

      final myReports = await ReportService.instance.getMyReports();
      final reportId = myReports.first.id;

      final commentId = await CommentService.instance.addComment(
        reportId: reportId,
        content: 'Komentarz z testu integracyjnego',
      );

      final comments = await CommentService.instance.getComments(reportId);
      expect(comments.any((comment) => comment.id == commentId), isTrue);
      expect(
        comments.any(
          (comment) => comment.content == 'Komentarz z testu integracyjnego',
        ),
        isTrue,
      );

      await CommentService.instance.editComment(
        commentId: commentId,
        content: 'Komentarz po edycji',
      );

      final edited = await CommentService.instance.getComments(reportId);
      final editedComment = edited.firstWhere((c) => c.id == commentId);
      expect(editedComment.content, 'Komentarz po edycji');
      expect(CommentService.instance.isOwner(editedComment), isTrue);

      await CommentService.instance.deleteComment(commentId);

      final afterDelete = await CommentService.instance.getComments(reportId);
      expect(afterDelete.any((comment) => comment.id == commentId), isFalse);
    });
  });
}
