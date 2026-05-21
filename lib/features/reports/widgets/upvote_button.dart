import 'package:city_issues/services/report_service.dart';
import 'package:flutter/material.dart';

class UpvoteButton extends StatefulWidget {
  const UpvoteButton({
    super.key,
    required this.reportId,
    required this.initialCount,
  });

  final String reportId;
  final int initialCount;

  @override
  State<UpvoteButton> createState() => _UpvoteButtonState();
}

class _UpvoteButtonState extends State<UpvoteButton> {
  late int _count = widget.initialCount;
  bool _isLoading = false;
  bool _hasUpvoted = false;

  Future<void> _upvote() async {
    if (_isLoading || _hasUpvoted) return;
    setState(() => _isLoading = true);
    try {
      await ReportService.instance.upvoteReport(widget.reportId);
      if (mounted) {
        setState(() {
          _count++;
          _hasUpvoted = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dziękujemy za poparcie zgłoszenia!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie udało się podbić: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: (_isLoading || _hasUpvoted) ? null : _upvote,
      icon: _isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(_hasUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined),
      label: Text(_hasUpvoted ? 'Podbite ($_count)' : 'Podbij ($_count)'),
    );
  }
}
