import 'dart:io';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/auth_service.dart';
import 'package:city_issues/services/location_service.dart';
import 'package:city_issues/services/storage_service.dart';

class UpvoteDisplayState {
  const UpvoteDisplayState({
    required this.count,
    required this.hasUpvoted,
  });

  final int count;
  final bool hasUpvoted;
}

class ReportService {
  ReportService._();
  static final ReportService instance = ReportService._();

  final Map<String, UpvoteDisplayState> _upvoteCache = {};

  UpvoteDisplayState? upvoteStateFor(String reportId) =>
      _upvoteCache[reportId];

  void cacheUpvoteState(
    String reportId, {
    required int count,
    required bool hasUpvoted,
  }) {
    _upvoteCache[reportId] = UpvoteDisplayState(
      count: count,
      hasUpvoted: hasUpvoted,
    );
  }

  UpvoteDisplayState resolveUpvoteState({
    required String reportId,
    required int serverCount,
    required bool serverHasUpvoted,
  }) {
    return _upvoteCache[reportId] ??
        UpvoteDisplayState(
          count: serverCount,
          hasUpvoted: serverHasUpvoted,
        );
  }

  void _reconcileUpvoteCache(List<GetReportsReports> reports) {
    final userId = AuthService.instance.currentUser?.uid;
    if (userId == null) {
      _upvoteCache.clear();
      return;
    }

    final staleIds = <String>[];
    for (final entry in _upvoteCache.entries) {
      GetReportsReports? report;
      for (final candidate in reports) {
        if (candidate.id == entry.key) {
          report = candidate;
          break;
        }
      }
      if (report == null) continue;

      final serverHasUpvoted = ReportUtils.userHasUpvoted(
        report.upvotes_on_report,
        userId,
      );
      final serverCount = ReportUtils.upvoteCount(report.upvotes_on_report);
      final cached = entry.value;

      if (cached.hasUpvoted == serverHasUpvoted &&
          cached.count == serverCount) {
        staleIds.add(entry.key);
      }
    }

    for (final id in staleIds) {
      _upvoteCache.remove(id);
    }
  }

  Future<List<GetReportsReports>> getReports({bool forceRefresh = false}) async {
    final result = await DefaultConnector.instance.getReports().ref().execute(
          fetchPolicy: forceRefresh
              ? QueryFetchPolicy.serverOnly
              : QueryFetchPolicy.preferCache,
        );
    final reports = result.data.reports;
    _reconcileUpvoteCache(reports);
    return reports;
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
  Future<void> upvoteReport(String reportId) async {
    await AuthService.instance.ensureUserProfile();
    await DefaultConnector.instance.upvoteReport(reportId: reportId).execute();
  }

  Future<void> removeUpvote(String reportId) async {
    await AuthService.instance.ensureUserProfile();
    await DefaultConnector.instance.removeUpvote(reportId: reportId).execute();
  }

  Future<List<GetReportsReports>> getMyReports({bool forceRefresh = false}) async {
  final result = await DefaultConnector.instance.getMyReports().ref().execute(
        fetchPolicy: forceRefresh
            ? QueryFetchPolicy.serverOnly
            : QueryFetchPolicy.preferCache,
      );
  final reports = result.data.reports.map((r) => GetReportsReports(
    id: r.id,
    latitude: r.latitude,
    longitude: r.longitude,
    description: r.description,
    status: r.status,
    createdAt: r.createdAt,
    category: GetReportsReportsCategory(
      name: r.category.name,
      iconName: r.category.iconName,
      pinColor: r.category.pinColor,
    ),
    reportPhotos_on_report: r.reportPhotos_on_report.map((p) =>
      GetReportsReportsReportPhotosOnReport(imageUrl: p.imageUrl)
    ).toList(),
    upvotes_on_report: r.upvotes_on_report.map((u) =>
      GetReportsReportsUpvotesOnReport(
        id: u.id,
        user: GetReportsReportsUpvotesOnReportUser(id: u.user.id),
      )
    ).toList(),
  )).toList();
  _reconcileUpvoteCache(reports);
  return reports;
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
