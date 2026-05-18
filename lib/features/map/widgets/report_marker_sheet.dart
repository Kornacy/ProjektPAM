import 'package:flutter/material.dart';
import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/features/reports/widgets/upvote_button.dart';

class ReportMarkerSheet extends StatelessWidget {
  const ReportMarkerSheet({
    super.key,
    required this.report,
    required this.onOpenDetail,
  });

  final GetReportsReports report;
  final VoidCallback onOpenDetail;

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
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _photoUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
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
            UpvoteButton(
              reportId: report.id,
              initialCount: report.upvotes_on_report.length,
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
