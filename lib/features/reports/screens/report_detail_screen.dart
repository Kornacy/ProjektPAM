import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/dataconnect_generated/default.dart';

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key, required this.report});

  final GetReportsReports report;

  @override
  Widget build(BuildContext context) {
    final position = LatLng(report.latitude, report.longitude);
    final photos = report.reportPhotos_on_report;

    return Scaffold(
      appBar: AppBar(title: const Text('Szczegóły zgłoszenia')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (photos.isNotEmpty)
              SizedBox(
                height: 220,
                child: PageView.builder(
                  itemCount: photos.length,
                  itemBuilder: (_, i) => Image.network(
                    photos[i].imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 160,
                color: Colors.grey.shade200,
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
                  const SizedBox(height: 16),
                  Text(
                    'Opis',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(report.description ?? 'Brak opisu'),
                  const SizedBox(height: 16),
                  Text(
                    'Lokalizacja',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
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
                  if (report.upvotes_on_report.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Poparcia: ${report.upvotes_on_report.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
