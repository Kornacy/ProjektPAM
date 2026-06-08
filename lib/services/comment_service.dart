import 'package:firebase_auth/firebase_auth.dart';
import 'package:city_issues/dataconnect_generated/default.dart';

class CommentService {
  CommentService._();
  static final CommentService instance = CommentService._();

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // ─── Pobieranie ────────────────────────────────────────────────────────────

  Future<List<GetReportCommentsComments>> getComments(String reportId) async {
    final result = await DefaultConnector.instance
        .getReportComments(reportId: reportId)
        .execute();
    return result.data.comments;
  }

  // ─── Dodawanie ─────────────────────────────────────────────────────────────

  Future<String> addComment({
    required String reportId,
    required String content,
  }) async {
    if (_currentUserId == null) {
      throw Exception('Musisz być zalogowany żeby dodać komentarz.');
    }
    if (content.trim().isEmpty) {
      throw Exception('Komentarz nie może być pusty.');
    }

    final result = await DefaultConnector.instance
        .addComment(reportId: reportId, content: content.trim())
        .execute();

    return result.data.comment_insert.id;
  }

  // ─── Edytowanie ────────────────────────────────────────────────────────────

  Future<void> editComment({
    required String commentId,
    required String content,
  }) async {
    if (_currentUserId == null) {
      throw Exception('Musisz być zalogowany żeby edytować komentarz.');
    }
    if (content.trim().isEmpty) {
      throw Exception('Komentarz nie może być pusty.');
    }

    await DefaultConnector.instance
        .editComment(commentId: commentId, content: content.trim())
        .execute();
  }

  // ─── Usuwanie ──────────────────────────────────────────────────────────────

  Future<void> deleteComment(String commentId) async {
    if (_currentUserId == null) {
      throw Exception('Musisz być zalogowany żeby usunąć komentarz.');
    }

    await DefaultConnector.instance
        .deleteComment(commentId: commentId)
        .execute();
  }

  // ─── Helper ────────────────────────────────────────────────────────────────

  /// Sprawdza czy zalogowany użytkownik jest właścicielem komentarza
  bool isOwner(GetReportCommentsComments comment) {
    return comment.user.id == _currentUserId;
  }
}