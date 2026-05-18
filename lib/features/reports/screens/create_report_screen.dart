import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:city_issues/core/widgets/app_error.dart';
import 'package:city_issues/core/widgets/app_loading.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/camera_service.dart';
import 'package:city_issues/services/location_service.dart';
import 'package:city_issues/services/report_service.dart';
import 'package:city_issues/services/reports_repository.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final TextEditingController _descController = TextEditingController();

  List<GetCategoriesCategories> _categories = [];
  String? _selectedCategoryId;
  final List<File> _photos = [];

  LatLng? _location;
  bool _locationLoading = true;
  String? _locationError;

  bool _categoriesLoading = true;
  bool _isSubmitting = false;
  String? _submitError;

  bool get _canSubmit =>
      !_isSubmitting &&
      !_categoriesLoading &&
      !_locationLoading &&
      _selectedCategoryId != null &&
      _location != null &&
      _photos.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadLocation();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ReportsRepository.instance.fetchCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _categoriesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categoriesLoading = false;
          _submitError = 'Nie udało się pobrać kategorii: $e';
        });
      }
    }
  }

  Future<void> _loadLocation() async {
    setState(() {
      _locationLoading = true;
      _locationError = null;
    });
    try {
      final Position position =
          await LocationService.instance.getCurrentLocation();
      if (mounted) {
        setState(() {
          _location = LatLng(position.latitude, position.longitude);
          _locationLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = e.toString();
          _locationLoading = false;
        });
      }
    }
  }

  Future<void> _addPhoto() async {
    final File? photo = await CameraService.instance.showPickerDialog(context);
    if (photo != null) {
      setState(() => _photos.add(photo));
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await ReportService.instance.createReport(
        categoryId: _selectedCategoryId!,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        photos: _photos,
        latitude: _location!.latitude,
        longitude: _location!.longitude,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zgłoszenie zostało wysłane.')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _submitError = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nowe zgłoszenie')),
      body: _categoriesLoading
          ? const AppLoading(message: 'Ładowanie formularza...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Kategoria *'),
                    value: _selectedCategoryId,
                    items: _categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategoryId = value),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Opis problemu',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    maxLength: 500,
                  ),
                  const SizedBox(height: 8),
                  Text('Zdjęcie *', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _buildPhotos(),
                  const SizedBox(height: 16),
                  Text('Lokalizacja *', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _buildLocationSection(),
                  if (_submitError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _submitError!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _canSubmit ? _submit : null,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Wyślij zgłoszenie'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPhotos() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._photos.map(
          (photo) => Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(photo, width: 100, height: 100, fit: BoxFit.cover),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => setState(() => _photos.remove(photo)),
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _addPhoto,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add_a_photo, color: Colors.grey, size: 32),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    if (_locationLoading) {
      return const SizedBox(height: 160, child: AppLoading(message: 'Pobieranie GPS...'));
    }
    if (_locationError != null) {
      return AppError(message: _locationError!, onRetry: _loadLocation);
    }
    if (_location == null) {
      return const AppError(message: 'Brak lokalizacji.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 160,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _location!, zoom: 16),
              markers: {
                Marker(markerId: const MarkerId('report'), position: _location!),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Współrzędne: ${_location!.latitude.toStringAsFixed(5)}, ${_location!.longitude.toStringAsFixed(5)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        TextButton.icon(
          onPressed: _loadLocation,
          icon: const Icon(Icons.refresh),
          label: const Text('Odśwież lokalizację'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }
}
