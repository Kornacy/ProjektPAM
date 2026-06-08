import 'package:flutter/material.dart';
import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/features/reports/widgets/photo_viewer.dart';
import 'package:city_issues/features/reports/widgets/upvote_button.dart';
import 'package:city_issues/services/auth_service.dart';

class ReportMarkerSheet extends StatelessWidget {
  const ReportMarkerSheet({
    super.key,
    required this.report,
    required this.onOpenDetail,
    this.upvoteButton,
  });

  final GetReportsReports report;
  final VoidCallback onOpenDetail;
  final Widget? upvoteButton;

  String? get _photoUrl {
    if (report.reportPhotos_on_report.isEmpty) return null;
    return report.reportPhotos_on_report.first.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_photoUrl != null)
              TappableNetworkPhoto(
                imageUrl: _photoUrl!,
                height: 140,
                allUrls: report.reportPhotos_on_report.map((p) => p.imageUrl).toList(),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(ReportUtils.categoryIcon(report.category.iconName)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.category.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ReportUtils.statusColor(report.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ReportUtils.statusLabel(report.status),
                    style: TextStyle(
                      color: ReportUtils.statusColor(report.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (report.description != null && report.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(report.description!, maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 12),
            upvoteButton ??
                UpvoteButton(
                  reportId: report.id,
                  initialCount: ReportUtils.upvoteCount(report.upvotes_on_report),
                  isSignedIn: AuthService.instance.isSignedIn,
                  initialHasUpvoted: ReportUtils.userHasUpvoted(
                    report.upvotes_on_report,
                    AuthService.instance.currentUser?.uid,
                  ),
                ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onOpenDetail,
              child: const Text('Zobacz szczegóły'),
            ),
          ],
        ),
      ),
    );
  }
}
