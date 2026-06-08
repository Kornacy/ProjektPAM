import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/features/reports/widgets/comments_section.dart';
import 'package:city_issues/services/auth_service.dart';
import 'package:city_issues/core/utils/scroll_padding.dart';
import 'package:city_issues/features/reports/widgets/photo_viewer.dart';
import 'package:city_issues/features/reports/widgets/upvote_button.dart';

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({
    super.key,
    required this.report,
    this.onBack,
    this.commentsSection,
    this.upvoteButton,
  });

  final GetReportsReports report;
  final VoidCallback? onBack;
  final Widget? commentsSection;
  final Widget? upvoteButton;

  @override
  Widget build(BuildContext context) {
    final position = LatLng(report.latitude, report.longitude);
    final photos = report.reportPhotos_on_report;
    final photoUrls = photos.map((p) => p.imageUrl).toList();
    final upvoteCount = ReportUtils.upvoteCount(report.upvotes_on_report);

    void goBack() {
      if (onBack != null) {
        onBack!();
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
          onPressed: goBack,
        ),
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
                    ReportUtils.categoryIcon(report.category.iconName),
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
                        Icon(ReportUtils.categoryIcon(report.category.iconName)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            report.category.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Chip(
                          label: Text(ReportUtils.statusLabel(report.status)),
                          backgroundColor:
                              ReportUtils.statusColor(report.status).withValues(alpha: 0.15),
                          labelStyle: TextStyle(
                            color: ReportUtils.statusColor(report.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    upvoteButton ??
                        UpvoteButton(
                          reportId: report.id,
                          initialCount: upvoteCount,
                          isSignedIn: AuthService.instance.isSignedIn,
                          initialHasUpvoted: ReportUtils.userHasUpvoted(
                            report.upvotes_on_report,
                            AuthService.instance.currentUser?.uid,
                          ),
                        ),
                    const SizedBox(height: 20),
                    Text('Opis', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(report.description ?? 'Brak opisu'),
                    const SizedBox(height: 16),
                    Text('Lokalizacja', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 180,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(target: position, zoom: 16),
                          markers: {
                            Marker(markerId: MarkerId(report.id), position: position),
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
                      '${report.latitude.toStringAsFixed(5)}, ${report.longitude.toStringAsFixed(5)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    commentsSection ??
                        CommentsSection(
                          reportId: report.id,
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
