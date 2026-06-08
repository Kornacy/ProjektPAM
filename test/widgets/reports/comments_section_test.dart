import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/features/reports/widgets/comments_section.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('CommentsSection', () {
    testWidgets('renders header and login prompt when not signed in', (tester) async {
      await pumpWidget(
        tester,
        CommentsSection(
          reportId: 'report-1',
          isSignedIn: false,
          commentsLoader: (_) async => [],
        ),
      );
      await tester.pump();

      expect(find.text('Komentarze'), findsOneWidget);
      expect(find.text('Zaloguj się, aby dodać komentarz.'), findsOneWidget);
      expect(find.text('Brak komentarzy. Bądź pierwszą osobą, która coś napisze.'), findsOneWidget);
    });

    testWidgets('renders comment form when signed in', (tester) async {
      await pumpWidget(
        tester,
        CommentsSection(
          reportId: 'report-1',
          isSignedIn: true,
          commentsLoader: (_) async => [],
        ),
      );
      await tester.pump();

      expect(find.text('Dodaj komentarz'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders loaded comments', (tester) async {
      await pumpWidget(
        tester,
        CommentsSection(
          reportId: 'report-1',
          isSignedIn: false,
          commentsLoader: (_) async => [
            GetReportCommentsComments(
              id: 'comment-1',
              content: 'To jest testowy komentarz.',
              createdAt: Timestamp(0, 1_704_067_200),
              user: GetReportCommentsCommentsUser(
                id: 'user-1',
                username: 'Jan',
                photoUrl: '',
              ),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('Jan'), findsOneWidget);
      expect(find.text('To jest testowy komentarz.'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });
  });
}
