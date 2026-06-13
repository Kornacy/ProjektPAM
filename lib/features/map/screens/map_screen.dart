import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/core/utils/user_facing_error.dart';
import 'package:city_issues/core/widgets/app_error.dart';
import 'package:city_issues/core/widgets/app_loading.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/features/map/widgets/map_category_filters.dart';
import 'package:city_issues/features/map/widgets/report_marker_sheet.dart';
import 'package:city_issues/services/location_service.dart';
import 'package:city_issues/services/report_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.onOpenReportDetail,
    this.filtersKey,
    this.locationFabKey,
  });

  final void Function(GetReportsReports report) onOpenReportDetail;
  final GlobalKey? filtersKey;
  final GlobalKey? locationFabKey;

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _isLoading = true;
  String? _error;
  Set<Marker> _markers = {};
  List<GetReportsReports> _reports = [];
  List<GetCategoriesCategories> _categories = [];
  Set<String> _enabledCategoryIds = {};
  bool _reportSheetOpen = false;

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(52.2297, 21.0122),
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> refreshReports({bool forceRefresh = false}) =>
      _loadReports(forceRefresh: forceRefresh);

  Future<void> _init() async {
    await Future.wait([_initLocation(), _loadReports(), _loadCategories()]);
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ReportService.instance.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _enabledCategoryIds = categories.map((c) => c.id).toSet();
      });
      _applyFilters();
    } catch (_) {}
  }

  Future<void> _initLocation() async {
    final last = await LocationService.instance.getLastKnownLocation();
    if (last != null && mounted) {
      setState(() => _currentPosition = LatLng(last.lat, last.lng));
      _moveCameraTo(_currentPosition!);
    }
    await _fetchCurrentLocation();
  }

  Future<void> _loadReports({bool forceRefresh = false}) async {
    try {
      final reports =
          await ReportService.instance.getReports(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _reports = reports;
        _error = null;
      });
      _applyFilters();
    } catch (e) {
      if (mounted) setState(() => _error = UserFacingError.loadReports(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final filtered = _reports.where((r) {
      final id = _categoryIdForReport(r);
      return _enabledCategoryIds.contains(id);
    }).toList();
    setState(() => _markers = _buildMarkers(filtered));
  }

  String _categoryIdForReport(GetReportsReports report) {
    for (final c in _categories) {
      if (c.name == report.category.name) return c.id;
    }
    return report.category.name;
  }

  void _toggleCategory(String id) {
    setState(() {
      if (_enabledCategoryIds.contains(id)) {
        _enabledCategoryIds.remove(id);
      } else {
        _enabledCategoryIds.add(id);
      }
    });
    _applyFilters();
  }

  Set<Marker> _buildMarkers(List<GetReportsReports> reports) {
    return reports.map((report) {
      return Marker(
        markerId: MarkerId(report.id),
        position: LatLng(report.latitude, report.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _hueFromColor(ReportUtils.parsePinColor(report.category.pinColor)),
        ),
        onTap: () => _showReportSheet(report),
      );
    }).toSet();
  }

  double _hueFromColor(Color color) => HSLColor.fromColor(color).hue;

  /// Closes the marker bottom sheet if open. Returns true when a pop was attempted.
  bool closeReportSheetIfOpen() {
    if (!_reportSheetOpen) return false;
    Navigator.of(context, rootNavigator: true).pop();
    return true;
  }

  void _showReportSheet(GetReportsReports report) {
    setState(() => _reportSheetOpen = true);
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => ReportMarkerSheet(
        report: report,
        onOpenDetail: () {
          Navigator.of(context, rootNavigator: true).pop();
          widget.onOpenReportDetail(report);
        },
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _reportSheetOpen = false);
    });
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final Position position =
          await LocationService.instance.getCurrentLocation();
      final newPosition = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() {
        _currentPosition = newPosition;
        _error = null;
      });
      _moveCameraTo(newPosition);
    } catch (e) {
      if (mounted && _currentPosition == null) {
        setState(() => _error = UserFacingError.location(e));
      }
    }
  }

  void _moveCameraTo(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: position, zoom: 15)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa zgłoszeń'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież zgłoszenia',
            onPressed: () {
              setState(() => _isLoading = true);
              _loadReports(forceRefresh: true);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _currentPosition != null
                ? CameraPosition(target: _currentPosition!, zoom: 15)
                : _defaultPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              if (_currentPosition != null) {
                _moveCameraTo(_currentPosition!);
              }
            },
          ),
          if (_categories.isNotEmpty)
            Positioned(
              left: 8,
              top: 8,
              child: KeyedSubtree(
                key: widget.filtersKey,
                child: MapCategoryFilters(
                  categories: _categories,
                  enabledIds: _enabledCategoryIds,
                  onToggle: _toggleCategory,
                  onClearAll: () {
                    setState(() => _enabledCategoryIds.clear());
                    _applyFilters();
                  },
                  onSelectAll: () {
                    setState(() {
                      _enabledCategoryIds =
                          _categories.map((c) => c.id).toSet();
                    });
                    _applyFilters();
                  },
                ),
              ),
            ),
          if (_isLoading && _reports.isEmpty)
            const AppLoading(message: 'Ładowanie mapy...'),
          if (_error != null && _reports.isEmpty)
            AppError(message: _error!, onRetry: _init),
        ],
      ),
      floatingActionButton: Padding(
        key: widget.locationFabKey,
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        child: FloatingActionButton(
          onPressed: _fetchCurrentLocation,
          tooltip: 'Moja lokalizacja',
          child: const Icon(Icons.my_location),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
