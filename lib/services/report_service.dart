import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/auth_service.dart';
import 'package:city_issues/services/location_service.dart';
import 'package:city_issues/services/offline/connectivity_service.dart';
import 'package:city_issues/services/offline/offline_cache_store.dart';
import 'package:city_issues/services/offline/offline_exception.dart';
import 'package:city_issues/services/offline/offline_sync_service.dart';
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
    OfflineCacheStore? cacheStore,
    ConnectivityService? connectivity,
    OfflineSyncService? offlineSync,
  })  : _authService = authService ?? AuthService.instance,
        _cacheStore = cacheStore ?? OfflineCacheStore.instance,
        _connectivity = connectivity ?? ConnectivityService.instance,
        _offlineSync = offlineSync ?? OfflineSyncService.instance;

  static final ReportService instance = ReportService._();

  @visibleForTesting
  factory ReportService.forTesting({
    AuthService? authService,
    OfflineCacheStore? cacheStore,
    ConnectivityService? connectivity,
    OfflineSyncService? offlineSync,
  }) =>
      ReportService._(
        authService: authService,
        cacheStore: cacheStore,
        connectivity: connectivity,
        offlineSync: offlineSync,
      );

  final AuthService _authService;
  final OfflineCacheStore _cacheStore;
  final ConnectivityService _connectivity;
  final OfflineSyncService _offlineSync;

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

  Future<T> _fetchWithOfflineFallback<T>({
    required Future<T> Function() fetch,
    required Future<T?> Function() loadCache,
    required Future<void> Function(T data) saveCache,
    bool forceRefresh = false,
  }) async {
    try {
      final data = await fetch();
      await saveCache(data);
      return data;
    } catch (e) {
      if (!forceRefresh) {
        final cached = await loadCache();
        if (cached != null) return cached;
      }
      if (!_connectivity.isOnline) {
        throw OfflineException(
          'Brak połączenia z internetem i zapisanych danych.',
        );
      }
      rethrow;
    }
  }

  Future<void> _ensureAuthenticatedForMutation() async {
    if (!_authService.isSignedIn) {
      throw Exception('Musisz być zalogowany, aby wykonać tę akcję.');
    }
    if (_connectivity.isOnline) {
      await _authService.ensureUserProfile();
    }
  }

  void _requireOnlineForWrite() {
    if (!_connectivity.isOnline) {
      throw OfflineException(
        'Ta operacja wymaga połączenia z internetem.',
      );
    }
  }

  Future<List<GetReportsReports>> getReports({bool forceRefresh = false}) async {
    final reports = await _fetchWithOfflineFallback(
      forceRefresh: forceRefresh,
      fetch: () async {
        final result =
            await DefaultConnector.instance.getReports().ref().execute(
                  fetchPolicy: forceRefresh
                      ? QueryFetchPolicy.serverOnly
                      : QueryFetchPolicy.preferCache,
                );
        return result.data.reports;
      },
      loadCache: _cacheStore.loadReports,
      saveCache: _cacheStore.saveReports,
    );
    _reconcileUpvoteCache(reports);
    return reports;
  }

  Future<List<GetCategoriesCategories>> getCategories() async {
    return _fetchWithOfflineFallback(
      fetch: () async {
        final result =
            await DefaultConnector.instance.getCategories().execute();
        return result.data.categories;
      },
      loadCache: _cacheStore.loadCategories,
      saveCache: _cacheStore.saveCategories,
    );
  }

  Future<List<GetActiveReportsReports>> getActiveReports() async {
    final result =
        await DefaultConnector.instance.getActiveReports().execute();
    return result.data.reports;
  }

  Future<void> upvoteReport(String reportId) async {
    await _ensureAuthenticatedForMutation();
    if (!_connectivity.isOnline) {
      await _offlineSync.enqueue(
        type: PendingOperationType.upvote,
        payload: {'reportId': reportId},
      );
      return;
    }
    await DefaultConnector.instance.upvoteReport(reportId: reportId).execute();
  }

  Future<void> removeUpvote(String reportId) async {
    await _ensureAuthenticatedForMutation();
    if (!_connectivity.isOnline) {
      await _offlineSync.enqueue(
        type: PendingOperationType.removeUpvote,
        payload: {'reportId': reportId},
      );
      return;
    }
    await DefaultConnector.instance.removeUpvote(reportId: reportId).execute();
  }

  List<GetReportsReports> _mapMyReports(List<GetMyReportsReports> reports) {
    return reports
        .map(
          (r) => GetReportsReports(
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
            reportPhotos_on_report: r.reportPhotos_on_report
                .map(
                  (p) => GetReportsReportsReportPhotosOnReport(
                    id: p.id,
                    imageUrl: p.imageUrl,
                  ),
                )
                .toList(),
            upvotes_on_report: r.upvotes_on_report
                .map(
                  (u) => GetReportsReportsUpvotesOnReport(
                    id: u.id,
                    user: GetReportsReportsUpvotesOnReportUser(id: u.user.id),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  Future<List<GetReportsReports>> getMyReports({bool forceRefresh = false}) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      throw Exception('Musisz być zalogowany, aby zobaczyć swoje zgłoszenia.');
    }

    final reports = await _fetchWithOfflineFallback(
      forceRefresh: forceRefresh,
      fetch: () async {
        final result =
            await DefaultConnector.instance.getMyReports().ref().execute(
                  fetchPolicy: forceRefresh
                      ? QueryFetchPolicy.serverOnly
                      : QueryFetchPolicy.preferCache,
                );
        return _mapMyReports(result.data.reports);
      },
      loadCache: () => _cacheStore.loadMyReports(userId),
      saveCache: (data) => _cacheStore.saveMyReports(userId, data),
    );
    _reconcileUpvoteCache(reports);
    return reports;
  }

  Future<bool> isOwnReport(String reportId) async {
    if (!_authService.isSignedIn) return false;
    final myReports = await getMyReports();
    return myReports.any((report) => report.id == reportId);
  }

  Future<void> createReport({
    required String categoryId,
    String? description,
    required List<File> photos,
    LatLng? selectedLocation,
  }) async {
    _requireOnlineForWrite();
    await _authService.ensureUserProfile();

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
    _requireOnlineForWrite();
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
    _requireOnlineForWrite();
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
