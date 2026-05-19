import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/location_service.dart';
import 'package:city_issues/services/report_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _isLoading = true;
  String? _error;
  Set<Marker> _markers = {};

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(52.2297, 21.0122),
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadReports();
  }

  Future<void> _initLocation() async {
    final last = await LocationService.instance.getLastKnownLocation();
    if (last != null) {
      setState(() {
        _currentPosition = LatLng(last.lat, last.lng);
        _isLoading = false;
      });
      _moveCameraTo(_currentPosition!);
    }
    await _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final Position position =
          await LocationService.instance.getCurrentLocation();
      final newPosition = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentPosition = newPosition;
        _isLoading = false;
        _error = null;
      });
      _moveCameraTo(newPosition);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReports() async {
    try {
      final reports = await ReportService.instance.getReports();
      final markers = reports.map((report) => _buildMarker(report)).toSet();
      setState(() => _markers = markers);
    } catch (e) {
      // Błąd przy ładowaniu zgłoszeń nie blokuje mapy
      debugPrint('Błąd ładowania zgłoszeń: $e');
    }
  }

  Marker _buildMarker(GetReportsReports report) {
    // Kolor pinu z kategorii — format #RRGGBB
    final color = _parseColor(report.category.pinColor);

    return Marker(
      markerId: MarkerId(report.id),
      position: LatLng(report.latitude, report.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        _colorToHue(color),
      ),
      infoWindow: InfoWindow(
        title: report.category.name,
        snippet: report.description ?? report.status,
      ),
      onTap: () => _showReportDetails(report),
    );
  }

  void _showReportDetails(GetReportsReports report) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.category.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Status: ${report.status}'),
            if (report.description != null) ...[
              const SizedBox(height: 8),
              Text(report.description!),
            ],
            const SizedBox(height: 8),
            Text('Zdjęcia: ${report.reportPhotos_on_report.length}'),
            Text('Głosy: ${report.upvotes_on_report.length}'),
          ],
        ),
      ),
    );
  }

  void _moveCameraTo(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15),
      ),
    );
  }

  // Parsuje kolor z formatu #RRGGBB do Color
  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.red;
    }
  }

  // Konwertuje Color na hue dla BitmapDescriptor (0-360)
  double _colorToHue(Color color) {
    final HSVColor hsv = HSVColor.fromColor(color);
    return hsv.hue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
            tooltip: 'Odśwież zgłoszenia',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _currentPosition != null
                ? CameraPosition(target: _currentPosition!, zoom: 15)
                : _defaultPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
              if (_currentPosition != null) {
                _moveCameraTo(_currentPosition!);
              }
            },
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchCurrentLocation,
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