import 'dart:io';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/location_service.dart';
import 'package:city_issues/services/storage_service.dart';

class ReportService {
  ReportService._();
  static final ReportService instance = ReportService._();

  Future<List<GetReportsReports>> getReports() async {
    final result = await DefaultConnector.instance.getReports().execute();
    return result.data.reports;
  }

  Future<List<GetActiveReportsReports>> getActiveReports() async {
    final result =
        await DefaultConnector.instance.getActiveReports().execute();
    return result.data.reports;
  }

  Future<List<GetMyReportsReports>> getMyReports() async {
    final result = await DefaultConnector.instance.getMyReports().execute();
    return result.data.reports;
  }

  Future<void> createReport({
    required String categoryId,
    String? description,
    required List<File> photos,
    // TODO: dodać LatLng? selectedLocation gdy będzie wybór z mapy
  }) async {
    final position = await LocationService.instance.getCurrentLocation();

    final result = await DefaultConnector.instance
        .createReport(
          category: categoryId,
          lat: position.latitude,
          lng: position.longitude,
        )
        .desc(description)
        .execute();

    final reportId = result.data.report_insert.id;

    for (final photo in photos) {
      final url = await StorageService.instance.uploadReportPhoto(photo);
      await DefaultConnector.instance
          .addPhoto(reportId: reportId, url: url)
          .execute();
    }
  }
}