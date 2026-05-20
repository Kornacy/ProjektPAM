import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/storage_service.dart';
import 'package:city_issues/services/location_service.dart';

class ReportService {
  ReportService._();
  static final ReportService instance = ReportService._();

  Future<List<GetReportsReports>> getReports() async {
    final result = await DefaultConnector.instance.getReports().execute();
    return result.data.reports;
  }
  Future<List<GetCategoriesCategories>> getCategories() async{
    final result = await DefaultConnector.instance.getCategories().execute();
    return result.data.categories;
  }
  

  Future<List<GetActiveReportsReports>> getActiveReports() async {
    final result =
        await DefaultConnector.instance.getActiveReports().execute();
    return result.data.reports;
  }

  Future<List<GetReportsReports>> getMyReports() async {
  final result = await DefaultConnector.instance.getMyReports().execute();
  return result.data.reports.map((r) => GetReportsReports(
    id: r.id,
    latitude: r.latitude,
    longitude: r.longitude,
    description: r.description,
    status: r.status,
    category: GetReportsReportsCategory(
      name: r.category.name,
      iconName: r.category.iconName,
      pinColor: r.category.pinColor,
    ),
    reportPhotos_on_report: r.reportPhotos_on_report.map((p) =>
      GetReportsReportsReportPhotosOnReport(imageUrl: p.imageUrl)
    ).toList(),
    upvotes_on_report: r.upvotes_on_report.map((u) =>
      GetReportsReportsUpvotesOnReport(id: u.id)
    ).toList(),
  )).toList();
}

  Future<void> createReport({
    required String categoryId,
    String? description,
    required List<File> photos,
    LatLng? selectedLocation, // jeśli null — pobiera aktualną lokalizację GPS
  }) async {
    double lat;
    double lng;

    if (selectedLocation != null) {
      lat = selectedLocation.latitude;
      lng = selectedLocation.longitude;
    } else {
      final position = await LocationService.instance.getCurrentLocation();
      lat = position.latitude;
      lng = position.longitude;
    }

    final result = await DefaultConnector.instance
        .createReport(
          category: categoryId,
          lat: lat,
          lng: lng,
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
