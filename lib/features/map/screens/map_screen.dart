import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/core/widgets/app_error.dart';
import 'package:city_issues/core/widgets/app_loading.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/features/map/widgets/report_marker_sheet.dart';
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

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(52.2297, 21.0122),
    zoom: 13,
  );

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

  double _hueFromColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.hue;
  }

  void _showReportSheet(GetReportsReports report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReportMarkerSheet(report: report),
    );
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
    _mapController?.dispose();
    super.dispose();
  }
}
