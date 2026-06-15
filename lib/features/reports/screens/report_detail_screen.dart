import 'dart:async';

import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/core/utils/scroll_padding.dart';
import 'package:city_issues/core/utils/user_facing_error.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/features/reports/widgets/comments_section.dart';
import 'package:city_issues/features/reports/widgets/photo_viewer.dart';
import 'package:city_issues/features/reports/widgets/report_manage_actions.dart';
import 'package:city_issues/features/reports/widgets/upvote_button.dart';
import 'package:city_issues/services/auth_service.dart';
import 'package:city_issues/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({
    super.key,
    required this.report,
    this.onBack,
    this.commentsSection,
    this.upvoteButton,
    this.canManage = false,
    this.onEdit,
    this.onDeleted,
  });

  final GetReportsReports report;
  final VoidCallback? onBack;
  final Widget? commentsSection;
  final Widget? upvoteButton;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDeleted;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late GetReportsReports _report;
  Timer? _refreshTimer;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _report = widget.report;
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _refreshReport(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshReport() async {
    final fresh = await ReportService.instance.findReportById(_report.id);
    if (fresh == null || !mounted) return;

    final oldCount = ReportUtils.upvoteCount(_report.upvotes_on_report);
    final newCount = ReportUtils.upvoteCount(fresh.upvotes_on_report);
    if (oldCount == newCount &&
        _report.status == fresh.status &&
        _report.description == fresh.description) {
      return;
    }

    setState(() => _report = fresh);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showReportDeleteDialog(context);
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await ReportService.instance.deleteReport(_report.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zgłoszenie zostało usunięte.')),
      );
      if (widget.onDeleted != null) {
        widget.onDeleted!();
      } else if (widget.onBack != null) {
        widget.onBack!();
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserFacingError.deleteReport(e))),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        widget.onEdit?.call();
      case 'delete':
        _confirmDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final position = LatLng(_report.latitude, _report.longitude);
    final photos = _report.reportPhotos_on_report;
    final photoUrls = photos.map((p) => p.imageUrl).toList();
    final upvoteCount = ReportUtils.upvoteCount(_report.upvotes_on_report);

    void goBack() {
      if (widget.onBack != null) {
        widget.onBack!();
      } else {
        Navigator.of(context).pop();
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Szczegóły zgłoszenia'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _isDeleting ? null : goBack,
          ),
          actions: [
            if (widget.canManage)
              PopupMenuButton<String>(
                enabled: !_isDeleting,
                onSelected: _handleMenuAction,
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edytuj'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('Usuń', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            if (_isDeleting)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: ScrollPadding.list(context, includeNavBar: true),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (photoUrls.isNotEmpty)
                  SizedBox(
                    height: 220,
                    child: PageView.builder(
                      itemCount: photoUrls.length,
                      itemBuilder: (_, i) => TappableNetworkPhoto(
                        imageUrl: photoUrls[i],
                        height: 220,
                        borderRadius: 0,
                        allUrls: photoUrls,
                        urlIndex: i,
                      ),
                    ),
                  )
                else
                  Container(
                    height: 160,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      ReportUtils.categoryIcon(_report.category.iconName),
                      size: 64,
                      color: Colors.grey,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(ReportUtils.categoryIcon(_report.category.iconName)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _report.category.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Chip(
                            label: Text(ReportUtils.statusLabel(_report.status)),
                            backgroundColor: ReportUtils.statusColor(_report.status)
                                .withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: ReportUtils.statusColor(_report.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Zgłoszono: ${ReportUtils.formatDateTime(_report.createdAt)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      widget.upvoteButton ??
                          UpvoteButton(
                            key: ValueKey('upvote-$upvoteCount'),
                            reportId: _report.id,
                            initialCount: upvoteCount,
                            isSignedIn: AuthService.instance.isSignedIn,
                            initialHasUpvoted: ReportUtils.userHasUpvoted(
                              _report.upvotes_on_report,
                              AuthService.instance.currentUser?.uid,
                            ),
                          ),
                      const SizedBox(height: 20),
                      Text('Opis', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(_report.description ?? 'Brak opisu'),
                      const SizedBox(height: 16),
                      Text('Lokalizacja', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 180,
                          child: GoogleMap(
                            initialCameraPosition:
                                CameraPosition(target: position, zoom: 16),
                            markers: {
                              Marker(markerId: MarkerId(_report.id), position: position),
                            },
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                            scrollGesturesEnabled: false,
                            zoomGesturesEnabled: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_report.latitude.toStringAsFixed(5)}, ${_report.longitude.toStringAsFixed(5)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      widget.commentsSection ??
                          CommentsSection(
                            reportId: _report.id,
                            isSignedIn: AuthService.instance.isSignedIn,
                            currentUserId: AuthService.instance.currentUser?.uid,
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
