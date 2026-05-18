import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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

enum _HoldPhase { none, waiting, filling }

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
  final GlobalKey _mapStackKey = GlobalKey();

  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _isLoading = true;
  String? _error;
  Set<Marker> _markers = {};
  List<GetReportsReports> _reports = [];
  List<GetCategoriesCategories> _categories = [];
  Set<String> _enabledCategoryIds = {};

  _HoldPhase _holdPhase = _HoldPhase.none;
  LatLng? _holdTarget;
  Offset? _holdScreenCenter;
  Timer? _holdDelayTimer;
  AnimationController? _fillController;
  int _holdGeneration = 0;

  static const Duration _delayBeforeCircle = Duration(seconds: 1);
  static const Duration _fillDuration = Duration(seconds: 3);
  static const int _fillSeconds = 3;

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(52.2297, 21.0122),
    zoom: 13,
  );

  bool get _isHolding => _holdPhase != _HoldPhase.none;
  double get _fillProgress => _fillController?.value ?? 0;
  bool get _mapGesturesLocked => _isHolding;

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

  void _showReportSheet(GetReportsReports report) {
    if (_isHolding) return;
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

  Future<LatLng?> _screenToLatLng(Offset local) async {
    final controller = _mapController;
    if (controller == null) return null;
    try {
      final latLng = await controller.getLatLng(
        ScreenCoordinate(x: local.dx.round(), y: local.dy.round()),
      );
      return latLng;
    } catch (_) {
      return null;
    }
  }

  Future<void> _onLongPressStart(LongPressStartDetails details) async {
    if (_isHolding) {
      _cancelHold();
      return;
    }

    final generation = ++_holdGeneration;
    final local = details.localPosition;
    final latLng = await _screenToLatLng(local);

    if (!mounted || generation != _holdGeneration || latLng == null) return;

    setState(() {
      _holdPhase = _HoldPhase.waiting;
      _holdScreenCenter = local;
      _holdTarget = latLng;
    });

    _holdDelayTimer = Timer(_delayBeforeCircle, () {
      if (!mounted || generation != _holdGeneration) return;
      if (_holdPhase != _HoldPhase.waiting) return;

      setState(() => _holdPhase = _HoldPhase.filling);

      _fillController = AnimationController(
        vsync: this,
        duration: _fillDuration,
      )..addListener(() {
          if (mounted && generation == _holdGeneration) setState(() {});
        });

      _fillController!.addStatusListener((status) {
        if (status != AnimationStatus.completed) return;
        if (!mounted || generation != _holdGeneration) return;
        final target = _holdTarget;
        _finishHold(success: true);
        if (target != null) widget.onCreateReportAt(target);
      });

      _fillController!.forward();
    });
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!_isHolding) return;
    setState(() => _holdScreenCenter = details.localPosition);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (_holdPhase == _HoldPhase.filling &&
        (_fillController?.value ?? 0) >= 1.0) {
      return;
    }
    _cancelHold();
  }

  void _finishHold({required bool success}) {
    _holdDelayTimer?.cancel();
    _holdDelayTimer = null;
    _fillController?.stop();
    _fillController?.dispose();
    _fillController = null;
    _holdPhase = _HoldPhase.none;
    _holdTarget = null;
    _holdScreenCenter = null;
    if (!success) _holdGeneration++;
    if (mounted) _applyFilters();
  }

  void _cancelHold() {
    if (_holdPhase == _HoldPhase.none) return;
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
      body: GestureDetector(
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        onLongPressMoveUpdate: _onLongPressMoveUpdate,
        child: Stack(
          key: _mapStackKey,
          children: [
            GoogleMap(
              initialCameraPosition: _currentPosition != null
                  ? CameraPosition(target: _currentPosition!, zoom: 15)
                  : _defaultPosition,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              scrollGesturesEnabled: !_mapGesturesLocked,
              zoomGesturesEnabled: !_mapGesturesLocked,
              rotateGesturesEnabled: !_mapGesturesLocked,
              tiltGesturesEnabled: !_mapGesturesLocked,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              onMapCreated: (controller) {
                _mapController = controller;
                if (_currentPosition != null) {
                  _moveCameraTo(_currentPosition!);
                }
              },
              onCameraMoveStarted: () {
                if (_isHolding) _cancelHold();
              },
            ),
            if (_categories.isNotEmpty)
              Positioned(
                left: 8,
                top: 8,
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
            if (_isHolding && _holdScreenCenter != null)
              MapHoldOverlay(
                center: _holdScreenCenter!,
                progress: _fillProgress,
                fillSeconds: _fillSeconds,
                showWaiting: _holdPhase == _HoldPhase.waiting,
              ),
            if (_isLoading && _reports.isEmpty)
              const AppLoading(message: 'Ładowanie mapy...'),
            if (_error != null && _reports.isEmpty)
              AppError(message: _error!, onRetry: _init),
          ],
        ),
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
    _holdDelayTimer?.cancel();
    _fillController?.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
