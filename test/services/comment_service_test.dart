import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/comment_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter_test/flutter_test.dart';

GetReportCommentsComments _comment({required String userId}) {
  return GetReportCommentsComments(
    id: 'comment-1',
    content: 'Test',
    createdAt: Timestamp(0, 1_704_067_200),
    user: GetReportCommentsCommentsUser(
      id: userId,
      username: 'Jan',
      photoUrl: '',
    ),
  );
}

void main() {
  group('CommentService validation', () {
    late CommentService service;

    setUp(() {
      service = CommentService.forTesting(
        firebaseAuth: MockFirebaseAuth(signedIn: false),
      );
    });

    test('addComment throws when user is not signed in', () async {
      await expectLater(
        service.addComment(reportId: 'report-1', content: 'Hej'),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('Musisz być zalogowany'),
          ),
        ),
      );
    });

    test('editComment throws when user is not signed in', () async {
      await expectLater(
        service.editComment(commentId: 'comment-1', content: 'Hej'),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('Musisz być zalogowany'),
          ),
        ),
      );
    });

    test('deleteComment throws when user is not signed in', () async {
      await expectLater(
        service.deleteComment('comment-1'),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('Musisz być zalogowany'),
          ),
        ),
      );
    });
  });

  group('CommentService with signed-in user', () {
    late CommentService service;

    setUp(() {
      service = CommentService.forTesting(
        firebaseAuth: MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(uid: 'user-123'),
        ),
      );
    });

    test('addComment rejects empty content', () async {
      await expectLater(
        service.addComment(reportId: 'report-1', content: ''),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('nie może być pusty'),
          ),
        ),
      );
    });

    test('addComment rejects whitespace-only content', () async {
      await expectLater(
        service.addComment(reportId: 'report-1', content: '   '),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('nie może być pusty'),
          ),
        ),
      );
    });

    test('editComment rejects empty content', () async {
      await expectLater(
        service.editComment(commentId: 'comment-1', content: '  '),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('nie może być pusty'),
          ),
        ),
      );
    });

    test('isOwner returns true for current user comment', () {
      expect(service.isOwner(_comment(userId: 'user-123')), isTrue);
    });

    test('isOwner returns false for another user comment', () {
      expect(service.isOwner(_comment(userId: 'other-user')), isFalse);
    });
  });

  group('CommentService.isOwner without signed-in user', () {
    test('returns false when user is not signed in', () {
      final service = CommentService.forTesting(
        firebaseAuth: MockFirebaseAuth(signedIn: false),
      );

      expect(service.isOwner(_comment(userId: 'user-123')), isFalse);
    });
  });
}
