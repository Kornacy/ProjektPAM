import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/core/widgets/app_error.dart';
import 'package:city_issues/core/widgets/app_loading.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/features/map/widgets/map_hold_overlay.dart';
import 'package:city_issues/features/map/widgets/report_marker_sheet.dart';
import 'package:city_issues/features/reports/screens/create_report_screen.dart';
import 'package:city_issues/services/location_service.dart';
import 'package:city_issues/services/reports_repository.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

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

  LatLng? _holdTarget;
  Timer? _holdTimer;
  double _holdProgress = 0;
  int _holdSecondsLeft = 5;
  static const Duration _holdDuration = Duration(seconds: 5);

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(52.2297, 21.0122),
    zoom: 13,
  );

  bool get _isHolding => _holdTarget != null;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> refreshReports() => _loadReports();

  Future<void> _init() async {
    await Future.wait([_initLocation(), _loadReports()]);
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
        _markers = _buildMarkers(reports);
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = 'Nie udało się załadować zgłoszeń: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

    if (_holdTarget != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pending_report'),
          position: _holdTarget!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Nowe zgłoszenie'),
        ),
      );
    }

    return markers;
  }

  double _hueFromColor(Color color) {
    return HSLColor.fromColor(color).hue;
  }

  void _showReportSheet(GetReportsReports report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReportMarkerSheet(report: report),
    );
  }

  void _onMapLongPress(LatLng position) {
    _cancelHold();
    setState(() {
      _holdTarget = position;
      _holdProgress = 0;
      _holdSecondsLeft = 5;
      _markers = _buildMarkers(_reports);
    });

    var elapsedMs = 0;
    _holdTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      elapsedMs += 100;
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _holdProgress = elapsedMs / _holdDuration.inMilliseconds;
        _holdSecondsLeft =
            ((_holdDuration.inMilliseconds - elapsedMs) / 1000).ceil().clamp(0, 5);
      });
      if (elapsedMs >= _holdDuration.inMilliseconds) {
        timer.cancel();
        final target = _holdTarget;
        _cancelHold();
        if (target != null) _openCreateReportAt(target);
      }
    });
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
    if (_holdTarget != null) {
      setState(() {
        _holdTarget = null;
        _holdProgress = 0;
        _holdSecondsLeft = 5;
        _markers = _buildMarkers(_reports);
      });
    }
  }

  Future<void> _openCreateReportAt(LatLng location) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateReportScreen(initialLocation: location),
      ),
    );
    if (created == true) {
      setState(() => _isLoading = true);
      await _loadReports();
    }
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
            onLongPress: _onMapLongPress,
            onTap: (_) {
              if (_isHolding) _cancelHold();
            },
            onCameraMoveStarted: () {
              if (_isHolding) _cancelHold();
            },
          ),
          if (!_isHolding)
            Positioned(
              top: 8,
              left: 16,
              right: 16,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Przytrzymaj mapę przez 5 s, aby dodać zgłoszenie w wybranym miejscu',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_isHolding)
            MapHoldOverlay(
              progress: _holdProgress,
              secondsLeft: _holdSecondsLeft,
              onCancel: _cancelHold,
            ),
          if (_isLoading && _reports.isEmpty)
            const AppLoading(message: 'Ładowanie mapy...'),
          if (_error != null && _reports.isEmpty)
            AppError(message: _error!, onRetry: _init),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchCurrentLocation,
        tooltip: 'Moja lokalizacja',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
