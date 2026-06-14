import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/auth_service.dart';
import 'package:city_issues/services/notification_service.dart';
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
  ReportService._({
    AuthService? authService,
    Future<void> Function(String reportId)? onUpvoteNotify,
  })  : _authService = authService ?? AuthService.instance,
        _onUpvoteNotify = onUpvoteNotify ??
            ((reportId) =>
                NotificationService.instance.notifyUpvoteOnReport(reportId));

  static final ReportService instance = ReportService._();

  @visibleForTesting
  factory ReportService.forTesting({
    AuthService? authService,
    Future<void> Function(String reportId)? onUpvoteNotify,
  }) =>
      ReportService._(
        authService: authService,
        onUpvoteNotify: onUpvoteNotify,
      );

  final AuthService _authService;
  final Future<void> Function(String reportId) _onUpvoteNotify;

  final Map<String, UpvoteDisplayState> _upvoteCache = {};
  final Map<String, int> _lastOwnerUpvoteCounts = {};
  final Map<String, bool> _lastOwnerSelfUpvoted = {};
  final Set<String> _selfUpvoteNotifySuppress = {};
  bool _ownerUpvoteBaselineReady = false;

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

  void _notifyOwnerUpvoteIncreases(List<GetReportsReports> reports) {
    final userId = _authService.currentUser?.uid;

    for (final report in reports) {
      final count = ReportUtils.upvoteCount(report.upvotes_on_report);
      final previous = _lastOwnerUpvoteCounts[report.id];
      final selfUpvoted = userId != null &&
          ReportUtils.userHasUpvoted(report.upvotes_on_report, userId);
      final wasSelfUpvoted = _lastOwnerSelfUpvoted[report.id] ?? false;

      if (_ownerUpvoteBaselineReady && previous != null && count > previous) {
        final onlySelfUpvote =
            count == previous + 1 && selfUpvoted && !wasSelfUpvoted;
        final suppressedSelfAction = _selfUpvoteNotifySuppress.remove(report.id);

        if (!onlySelfUpvote && !suppressedSelfAction) {
          NotificationService.instance.showUpvoteReceived(
            reportId: report.id,
            categoryName: report.category.name,
            description: report.description,
            newCount: count,
          );
        }
      }

      _lastOwnerUpvoteCounts[report.id] = count;
      _lastOwnerSelfUpvoted[report.id] = selfUpvoted;
    }
    _ownerUpvoteBaselineReady = true;
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

  Future<GetReportsReports?> findReportById(
    String reportId, {
    bool forceRefresh = true,
  }) async {
    final reports = await getReports(forceRefresh: forceRefresh);
    for (final report in reports) {
      if (report.id == reportId) {
        return report;
      }
    }
    return null;
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
    await _authService.ensureUserProfile();
    await DefaultConnector.instance.upvoteReport(reportId: reportId).execute();
    _selfUpvoteNotifySuppress.add(reportId);
    if (_lastOwnerUpvoteCounts.containsKey(reportId)) {
      _lastOwnerUpvoteCounts[reportId] =
          (_lastOwnerUpvoteCounts[reportId] ?? 0) + 1;
      _lastOwnerSelfUpvoted[reportId] = true;
    }
    await _onUpvoteNotify(reportId);
  }

  Future<void> removeUpvote(String reportId) async {
    await _authService.ensureUserProfile();
    await DefaultConnector.instance.removeUpvote(reportId: reportId).execute();
    if (_lastOwnerUpvoteCounts.containsKey(reportId)) {
      final next = (_lastOwnerUpvoteCounts[reportId] ?? 1) - 1;
      _lastOwnerUpvoteCounts[reportId] = next < 0 ? 0 : next;
      _lastOwnerSelfUpvoted[reportId] = false;
    }
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
      GetReportsReportsReportPhotosOnReport(id: p.id, imageUrl: p.imageUrl)
    ).toList(),
    upvotes_on_report: r.upvotes_on_report.map((u) =>
      GetReportsReportsUpvotesOnReport(
        id: u.id,
        user: GetReportsReportsUpvotesOnReportUser(id: u.user.id),
      )
    ).toList(),
    )).toList();
  _notifyOwnerUpvoteIncreases(reports);
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

  Future<void> editReport({
    required String reportId,
    required String categoryId,
    String? description,
    required LatLng location,
    List<File> photos = const [],
    List<String> removedPhotoIds = const [],
  }) async {
    await _authService.ensureUserProfile();

    final urlsToDelete = <String>[];
    if (removedPhotoIds.isNotEmpty) {
      final myReports = await getMyReports();
      final reportMatches = myReports.where((r) => r.id == reportId);
      if (reportMatches.isEmpty) {
        throw Exception('Nie znaleziono zgłoszenia.');
      }

      for (final photo in reportMatches.first.reportPhotos_on_report) {
        if (removedPhotoIds.contains(photo.id)) {
          urlsToDelete.add(photo.imageUrl);
        }
      }
    }

    final result = await DefaultConnector.instance
        .editReport(
          reportId: reportId,
          category: categoryId,
          lat: location.latitude,
          lng: location.longitude,
        )
        .desc(description)
        .execute();

    if (result.data.report_updateMany == 0) {
      throw Exception(
        'Nie znaleziono zgłoszenia lub nie masz uprawnień do jego edycji.',
      );
    }

    for (final photoId in removedPhotoIds) {
      final deleteResult = await DefaultConnector.instance
          .removeReportPhoto(photoId: photoId)
          .execute();
      if (deleteResult.data.reportPhoto_deleteMany == 0) {
        throw Exception('Nie udało się usunąć zdjęcia lub brak uprawnień.');
      }
    }

    for (final url in urlsToDelete) {
      await StorageService.instance.deleteReportPhoto(url);
    }

    for (final photo in photos) {
      final url = await StorageService.instance.uploadReportPhoto(photo);
      await DefaultConnector.instance
          .addPhoto(reportId: reportId, url: url)
          .execute();
    }
  }

  Future<void> deleteReport(String reportId) async {
    await _authService.ensureUserProfile();

    final result = await DefaultConnector.instance
        .deleteReport(reportId: reportId)
        .execute();

    if (result.data.report_deleteMany == 0) {
      throw Exception(
        'Nie znaleziono zgłoszenia lub nie masz uprawnień do jego usunięcia.',
      );
    }
  }
}
