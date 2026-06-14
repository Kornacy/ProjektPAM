import 'package:city_issues/core/utils/user_facing_error.dart';
import 'package:city_issues/core/widgets/app_error.dart';
import 'package:city_issues/core/widgets/app_loading.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/comment_service.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/material.dart';

class CommentsSection extends StatefulWidget {
  const CommentsSection({
    super.key,
    required this.reportId,
    required this.isSignedIn,
    this.currentUserId,
    this.commentsLoader,
  });

  final String reportId;
  final bool isSignedIn;
  final String? currentUserId;
  final Future<List<GetReportCommentsComments>> Function(String reportId)?
      commentsLoader;

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  static const _maxLength = 1000;

  final _contentController = TextEditingController();
  final _commentService = CommentService.instance;

  List<GetReportCommentsComments> _comments = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final loadComments = widget.commentsLoader ?? _commentService.getComments;
      final comments = await loadComments(widget.reportId);
      if (!mounted) return;
      setState(() {
        _comments = _sortComments(comments);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = UserFacingError.loadComments(e);
        _isLoading = false;
      });
    }
  }

  List<GetReportCommentsComments> _sortComments(
    List<GetReportCommentsComments> comments,
  ) {
    final sorted = List<GetReportCommentsComments>.from(comments);
    sorted.sort((a, b) => a.createdAt.seconds.compareTo(b.createdAt.seconds));
    return sorted;
  }

  Future<void> _addComment() async {
    final content = _contentController.text;
    if (_isSubmitting || content.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final commentId = await _commentService.addComment(
        reportId: widget.reportId,
        content: content,
      );
      if (!mounted) return;
      _contentController.clear();
      if (commentId != CommentService.offlinePendingId) {
        await _loadComments();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            commentId == CommentService.offlinePendingId
                ? 'Komentarz zostanie wysłany po odzyskaniu połączenia.'
                : 'Komentarz został dodany.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserFacingError.addComment(e))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _editComment(GetReportCommentsComments comment) async {
    final updated = await showDialog<String>(
      context: context,
      builder: (context) => _CommentEditDialog(initialContent: comment.content),
    );
    if (updated == null || updated.trim() == comment.content.trim()) return;

    try {
      await _commentService.editComment(
        commentId: comment.id,
        content: updated,
      );
      if (!mounted) return;
      await _loadComments();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentarz został zaktualizowany.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserFacingError.editComment(e))),
      );
    }
  }

  Future<void> _deleteComment(GetReportCommentsComments comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń komentarz'),
        content: const Text('Czy na pewno chcesz usunąć ten komentarz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _commentService.deleteComment(comment.id);
      if (!mounted) return;
      setState(() {
        _comments = _comments.where((c) => c.id != comment.id).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentarz został usunięty.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserFacingError.deleteComment(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Komentarze',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (!_isLoading && _loadError == null)
                  Chip(
                    label: Text('${_comments.length}'),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: AppLoading(message: 'Ładowanie komentarzy…'),
              )
            else if (_loadError != null)
              AppError(message: _loadError!, onRetry: _loadComments)
            else if (_comments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Brak komentarzy. Bądź pierwszą osobą, która coś napisze.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _comments.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  return _CommentTile(
                    comment: comment,
                    formattedDate: _formatDate(comment.createdAt),
                    canManage: widget.currentUserId != null &&
                        comment.user.id == widget.currentUserId,
                    onEdit: () => _editComment(comment),
                    onDelete: () => _deleteComment(comment),
                  );
                },
              ),
            const SizedBox(height: 16),
            if (widget.isSignedIn) ...[
              TextField(
                controller: _contentController,
                maxLines: 3,
                maxLength: _maxLength,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Napisz komentarz…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: _isSubmitting ? null : _addComment,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: const Text('Dodaj komentarz'),
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Zaloguj się, aby dodać komentarz.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDateTime().toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}.${two(date.month)}.${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.formattedDate,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  final GetReportCommentsComments comment;
  final String formattedDate;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final username = comment.user.username.trim().isEmpty
        ? 'Użytkownik'
        : comment.user.username;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: comment.user.photoUrl.isNotEmpty
              ? NetworkImage(comment.user.photoUrl)
              : null,
          child: comment.user.photoUrl.isEmpty
              ? Text(username[0].toUpperCase())
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      username,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  if (canManage)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit();
                          case 'delete':
                            onDelete();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edytuj'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Usuń',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(comment.content),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentEditDialog extends StatefulWidget {
  const _CommentEditDialog({required this.initialContent});

  final String initialContent;

  @override
  State<_CommentEditDialog> createState() => _CommentEditDialogState();
}

class _CommentEditDialogState extends State<_CommentEditDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialContent);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edytuj komentarz'),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        maxLength: _CommentsSectionState._maxLength,
        autofocus: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          onPressed: () {
            final content = _controller.text.trim();
            if (content.isEmpty) return;
            Navigator.of(context).pop(content);
          },
          child: const Text('Zapisz'),
        ),
      ],
    );
  }
}
