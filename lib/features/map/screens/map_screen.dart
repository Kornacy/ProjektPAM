import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/core/widgets/app_error.dart';
import 'package:city_issues/core/widgets/app_loading.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/features/map/widgets/map_category_filters.dart';
import 'package:city_issues/features/map/widgets/map_hold_overlay.dart';
import 'package:city_issues/features/map/widgets/map_hold_tutorial_dialog.dart';
import 'package:city_issues/features/map/widgets/report_marker_sheet.dart';
import 'package:city_issues/services/app_preferences.dart';
import 'package:city_issues/services/location_service.dart';
import 'package:city_issues/services/reports_repository.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.onCreateReportAt,
    required this.onOpenReportDetail,
  });

  final void Function(LatLng location) onCreateReportAt;
  final void Function(GetReportsReports report) onOpenReportDetail;

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _isLoading = true;
  String? _error;
  Set<Marker> _markers = {};
  List<GetReportsReports> _reports = [];
  List<GetCategoriesCategories> _categories = [];
  Set<String> _enabledCategoryIds = {};
  Size _mapSize = Size.zero;

  LatLng? _holdTarget;
  Offset? _holdScreenCenter;
  AnimationController? _holdController;
  int _holdGeneration = 0;

  static const Duration _holdDuration = Duration(seconds: 3);
  static const int _holdSeconds = 3;

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(52.2297, 21.0122),
    zoom: 13,
  );

  bool get _isHolding => _holdController != null;
  double get _holdProgress => _holdController?.value ?? 0;

  @override
  void initState() {
    super.initState();
    _init();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowMapTutorial());
  }

  Future<void> _maybeShowMapTutorial() async {
    if (!mounted) return;
    final prefs = AppPreferences.instance;
    if (!prefs.hasCompletedOnboarding || prefs.hasSeenMapHoldTutorial) return;
    await showMapHoldTutorialDialog(context);
    await prefs.setMapHoldTutorialSeen();
  }

  Future<void> refreshReports() => _loadReports();

  Future<void> _init() async {
    await Future.wait([_initLocation(), _loadReports(), _loadCategories()]);
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ReportsRepository.instance.fetchCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _enabledCategoryIds = categories.map((c) => c.id).toSet();
      });
      _applyFilters();
    } catch (_) {
      // Filtry opcjonalne — mapa działa bez nich.
    }
  }

  Future<void> _initLocation() async {
    final last = await LocationService.instance.getLastKnownLocation();
    if (last != null && mounted) {
      setState(() => _currentPosition = LatLng(last.lat, last.lng));
      _moveCameraTo(_currentPosition!);
    }
    await _fetchCurrentLocation();
  }

  Future<void> _loadReports() async {
    try {
      final reports = await ReportsRepository.instance.fetchAllReports();
      if (!mounted) return;
      setState(() {
        _reports = reports;
        _error = null;
      });
      _applyFilters();
    } catch (e) {
      if (mounted) setState(() => _error = 'Nie udało się załadować zgłoszeń: $e');
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
    final markers = reports.map((report) {
      return Marker(
        markerId: MarkerId(report.id),
        position: LatLng(report.latitude, report.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _hueFromColor(ReportUtils.parsePinColor(report.category.pinColor)),
        ),
        onTap: () => _showReportSheet(report),
      );
    }).toSet();

    return markers;
  }

  double _hueFromColor(Color color) => HSLColor.fromColor(color).hue;

  void _showReportSheet(GetReportsReports report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReportMarkerSheet(
        report: report,
        onOpenDetail: () {
          Navigator.pop(context);
          widget.onOpenReportDetail(report);
        },
      ),
    );
  }

  Future<Offset> _latLngToScreenOffset(LatLng position) async {
    final controller = _mapController;
    if (controller != null) {
      try {
        final sc = await controller.getScreenCoordinate(position);
        return Offset(sc.x.toDouble(), sc.y.toDouble());
      } catch (_) {}
    }
    return Offset(_mapSize.width / 2, _mapSize.height / 2);
  }

  Future<void> _startSelectionAt(LatLng position) async {
    if (_isHolding) {
      _cancelHold();
      return;
    }

    final controller = _mapController;
    if (controller == null) return;

    final generation = ++_holdGeneration;
    final center = await _latLngToScreenOffset(position);

    if (!mounted || generation != _holdGeneration) return;

    setState(() {
      _holdTarget = position;
      _holdScreenCenter = center;
    });

    _holdController = AnimationController(
      vsync: this,
      duration: _holdDuration,
    )..addListener(() {
        if (mounted && generation == _holdGeneration) setState(() {});
      });

    _holdController!.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      if (!mounted || generation != _holdGeneration) return;
      final target = _holdTarget;
      _finishHold(success: true);
      if (target != null) widget.onCreateReportAt(target);
    });

    _holdController!.forward();
  }

  void _onMapTap(LatLng position) => _startSelectionAt(position);

  void _finishHold({required bool success}) {
    _holdController?.stop();
    _holdController?.dispose();
    _holdController = null;
    _holdTarget = null;
    _holdScreenCenter = null;
    if (!success) _holdGeneration++;
    if (mounted) _applyFilters();
  }

  void _cancelHold() {
    if (!_isHolding && _holdTarget == null) return;
    _holdGeneration++;
    _finishHold(success: false);
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
        setState(() => _error = e.toString());
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
            onPressed: () {
              setState(() => _isLoading = true);
              _loadReports();
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _mapSize = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
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
                onTap: _onMapTap,
                onCameraMoveStarted: () {
                  if (_isHolding) _cancelHold();
                },
              ),
              if (_categories.isNotEmpty)
                Positioned(
                  left: 12,
                  top: 12,
                  bottom: 88,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
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
                ),
              if (_isHolding && _holdScreenCenter != null)
                MapHoldOverlay(
                  center: _holdScreenCenter!,
                  progress: _holdProgress,
                  holdSeconds: _holdSeconds,
                  onCancel: _cancelHold,
                ),
              if (_isLoading && _reports.isEmpty)
                const AppLoading(message: 'Ładowanie mapy...'),
              if (_error != null && _reports.isEmpty)
                AppError(message: _error!, onRetry: _init),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
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
    _holdController?.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
