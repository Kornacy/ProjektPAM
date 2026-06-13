import 'package:city_issues/core/utils/user_facing_error.dart';
import 'package:city_issues/services/report_service.dart';
import 'package:flutter/material.dart';

class UpvoteButton extends StatefulWidget {
  const UpvoteButton({
    super.key,
    required this.reportId,
    required this.initialCount,
    required this.isSignedIn,
    this.initialHasUpvoted = false,
    this.onUpvote,
    this.onRemoveUpvote,
  });

  final String reportId;
  final int initialCount;
  final bool isSignedIn;
  final bool initialHasUpvoted;
  final Future<void> Function(String reportId)? onUpvote;
  final Future<void> Function(String reportId)? onRemoveUpvote;

  @override
  State<UpvoteButton> createState() => _UpvoteButtonState();
}

class _UpvoteButtonState extends State<UpvoteButton>
    with SingleTickerProviderStateMixin {
  late int _count = widget.initialCount;
  late bool _hasUpvoted = widget.initialHasUpvoted;
  bool _isLoading = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  void _applyCachedState() {
    final cached = ReportService.instance.upvoteStateFor(widget.reportId);
    if (cached != null) {
      _count = cached.count;
      _hasUpvoted = cached.hasUpvoted;
    }
  }

  void _persistState() {
    ReportService.instance.cacheUpvoteState(
      widget.reportId,
      count: _count,
      hasUpvoted: _hasUpvoted,
    );
  }

  @override
  void initState() {
    super.initState();
    _applyCachedState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pulseScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.07)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.07, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 65,
      ),
    ]).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(UpvoteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (ReportService.instance.upvoteStateFor(widget.reportId) != null) {
      _applyCachedState();
      return;
    }
    if (oldWidget.initialCount != widget.initialCount) {
      _count = widget.initialCount;
    }
    if (oldWidget.initialHasUpvoted != widget.initialHasUpvoted) {
      _hasUpvoted = widget.initialHasUpvoted;
    }
  }

  String _supportLabel(int count) {
    if (count == 0) return 'Brak poparcia';
    if (count == 1) return '1 osoba wspiera';
    final lastDigit = count % 10;
    final lastTwo = count % 100;
    if (lastDigit >= 2 && lastDigit <= 4 && (lastTwo < 12 || lastTwo > 14)) {
      return '$count osoby wspierają';
    }
    return '$count osób wspiera';
  }

  Future<void> _toggleUpvote() async {
    if (_isLoading || !widget.isSignedIn) return;

    setState(() => _isLoading = true);
    try {
      if (_hasUpvoted) {
        final removeUpvote =
            widget.onRemoveUpvote ?? ReportService.instance.removeUpvote;
        await removeUpvote(widget.reportId);
        if (!mounted) return;
        setState(() {
          _hasUpvoted = false;
          _count = (_count - 1).clamp(0, 1 << 30);
        });
        _persistState();
      } else {
        final upvote = widget.onUpvote ?? ReportService.instance.upvoteReport;
        await upvote(widget.reportId);
        if (!mounted) return;
        setState(() {
          _hasUpvoted = true;
          _count++;
        });
        _persistState();
        _pulseController.forward(from: 0);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserFacingError.upvote(e))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildActionButton(Color primary, Color onPrimary) {
    return ScaleTransition(
      scale: _pulseScale,
      child: FilledButton(
        onPressed: _isLoading ? null : _toggleUpvote,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: _hasUpvoted ? primary : null,
          foregroundColor: _hasUpvoted ? onPrimary : null,
        ),
        child: _isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _hasUpvoted ? onPrimary : primary,
                ),
              )
            : Text(_hasUpvoted ? 'Podbite' : 'Podbij'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final subtitle = !widget.isSignedIn
        ? 'Zaloguj się, aby oddać głos'
        : _hasUpvoted
            ? 'Wspierasz to zgłoszenie'
            : 'Okaż poparcie dla zgłoszenia';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _hasUpvoted && widget.isSignedIn
            ? primary.withValues(alpha: 0.08)
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasUpvoted && widget.isSignedIn
              ? primary.withValues(alpha: 0.3)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _hasUpvoted && widget.isSignedIn
                  ? primary.withValues(alpha: 0.15)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _hasUpvoted && widget.isSignedIn
                  ? Icons.thumb_up
                  : Icons.thumb_up_outlined,
              size: 22,
              color: _hasUpvoted && widget.isSignedIn
                  ? primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _supportLabel(_count),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (widget.isSignedIn)
            _buildActionButton(primary, onPrimary)
          else
            Icon(
              Icons.login,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}
