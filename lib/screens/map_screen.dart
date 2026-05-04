import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:city_issues/services/location_service.dart';

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

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(52.2297, 21.0122),
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    // Najpierw pokaż ostatnią zapisaną pozycję — bez żadnego wywołania GPS
    final last = await LocationService.instance.getLastKnownLocation();
    if (last != null) {
      setState(() {
        _currentPosition = LatLng(last.lat, last.lng);
        _isLoading = false;
      });
      _moveCameraTo(_currentPosition!);
    }

    // Następnie pobierz aktualną pozycję w tle i zaktualizuj jeśli się różni
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

  void _moveCameraTo(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _currentPosition != null
                ? CameraPosition(target: _currentPosition!, zoom: 15)
                : _defaultPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
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