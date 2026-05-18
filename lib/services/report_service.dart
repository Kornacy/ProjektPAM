import 'dart:io';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/storage_service.dart';

class ReportService {
  ReportService._();
  static final ReportService instance = ReportService._();

  Future<void> createReport({
    required String categoryId,
    String? description,
    required List<File> photos,
    required double latitude,
    required double longitude,
  }) async {
    if (photos.isEmpty) {
      throw Exception('Dodaj co najmniej jedno zdjęcie.');
    }

    final result = await DefaultConnector.instance
        .createReport(
          category: categoryId,
          lat: latitude,
          lng: longitude,
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
