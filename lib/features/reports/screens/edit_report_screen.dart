import 'dart:io';

import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/core/utils/scroll_padding.dart';
import 'package:city_issues/core/utils/user_facing_error.dart';
import 'package:city_issues/core/widgets/app_loading.dart';
import 'package:city_issues/core/widgets/form_error_banner.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/features/reports/widgets/report_location_picker.dart';
import 'package:city_issues/services/camera_service.dart';
import 'package:city_issues/services/location_service.dart';
import 'package:city_issues/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class _ExistingPhoto {
  _ExistingPhoto({required this.id, required this.url});

  final String id;
  final String url;
  bool markedForRemoval = false;
}

class EditReportScreen extends StatefulWidget {
  const EditReportScreen({super.key, required this.report});

  final GetReportsReports report;

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  final TextEditingController _descController = TextEditingController();

  List<GetCategoriesCategories> _categories = [];
  String? _selectedCategoryId;
  final List<_ExistingPhoto> _existingPhotos = [];
  final List<File> _newPhotos = [];

  LatLng? _location;
  bool _locationLoading = false;
  String? _locationError;

  final _locationPickerKey = GlobalKey<ReportLocationPickerState>();

  bool _categoriesLoading = true;
  bool _isSubmitting = false;
  String? _submitError;

  int get _remainingPhotoCount =>
      _existingPhotos.where((p) => !p.markedForRemoval).length + _newPhotos.length;

  bool get _canSubmit =>
      !_isSubmitting &&
      !_categoriesLoading &&
      _selectedCategoryId != null &&
      _location != null &&
      _remainingPhotoCount > 0;

  @override
  void initState() {
    super.initState();
    _descController.text = widget.report.description ?? '';
    _location = LatLng(widget.report.latitude, widget.report.longitude);
    for (final photo in widget.report.reportPhotos_on_report) {
      _existingPhotos.add(_ExistingPhoto(id: photo.id, url: photo.imageUrl));
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ReportService.instance.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _categoriesLoading = false;
        _selectedCategoryId = _resolveCategoryId(categories);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categoriesLoading = false;
        _submitError = UserFacingError.loadCategories(e);
      });
    }
  }

  String? _resolveCategoryId(List<GetCategoriesCategories> categories) {
    for (final category in categories) {
      if (category.name == widget.report.category.name) {
        return category.id;
      }
    }
    return categories.isNotEmpty ? categories.first.id : null;
  }

  Future<void> _loadLocation() async {
    setState(() {
      _locationLoading = true;
      _locationError = null;
    });
    try {
      final Position position =
          await LocationService.instance.getCurrentLocation();
      if (!mounted) return;
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _location = latLng;
        _locationLoading = false;
      });
      _locationPickerKey.currentState?.recenterTo(latLng);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = UserFacingError.location(e);
        _locationLoading = false;
      });
    }
  }

  void _onPickerLocationChanged(LatLng position) {
    setState(() {
      _location = position;
      _locationError = null;
    });
  }

  Future<void> _addPhoto() async {
    final File? photo = await CameraService.instance.showPickerDialog(context);
    if (photo != null) {
      setState(() => _newPhotos.add(photo));
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await ReportService.instance.editReport(
        reportId: widget.report.id,
        categoryId: _selectedCategoryId!,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        location: _location!,
        photos: _newPhotos,
        removedPhotoIds: _existingPhotos
            .where((p) => p.markedForRemoval)
            .map((p) => p.id)
            .toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zgłoszenie zostało zaktualizowane.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitError = UserFacingError.editReport(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edytuj zgłoszenie')),
      body: _categoriesLoading
          ? const AppLoading(message: 'Ładowanie formularza...')
          : SingleChildScrollView(
              padding: ScrollPadding.list(context, includeNavBar: true),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Kategoria *'),
                    isExpanded: true,
                    value: _selectedCategoryId,
                    items: _categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Row(
                              children: [
                                Icon(
                                  ReportUtils.categoryIcon(c.iconName),
                                  size: 20,
                                  color: ReportUtils.parsePinColor(c.pinColor),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(c.name)),
                              ],
                            ),
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
                      hintText: 'Opisz krótko, na czym polega problem…',
                    ),
                    maxLines: 3,
                    maxLength: 500,
                  ),
                  const SizedBox(height: 8),
                  Text('Zdjęcia *', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Zgłoszenie musi mieć co najmniej jedno zdjęcie.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildPhotos(),
                  const SizedBox(height: 16),
                  Text('Lokalizacja *', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Przesuń mapę tak, aby pinezka wskazywała miejsce zgłoszenia.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildLocationSection(),
                  if (_submitError != null) ...[
                    const SizedBox(height: 12),
                    FormErrorBanner(message: _submitError!),
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
                        : const Text('Zapisz zmiany'),
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
        ..._existingPhotos.where((p) => !p.markedForRemoval).map(
              (photo) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      photo.url,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 100,
                        height: 100,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => photo.markedForRemoval = true),
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
        ..._newPhotos.map(
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
                  onTap: () => setState(() => _newPhotos.remove(photo)),
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
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.add_a_photo,
              color: Theme.of(context).colorScheme.outline,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    if (_locationLoading) {
      return const SizedBox(height: 200, child: AppLoading(message: 'Pobieranie GPS...'));
    }

    final target = _location ?? LatLng(widget.report.latitude, widget.report.longitude);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_locationError != null) ...[
          FormErrorBanner(message: _locationError!),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 200,
            child: ReportLocationPicker(
              key: _locationPickerKey,
              initialTarget: target,
              onLocationChanged: _onPickerLocationChanged,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_location != null)
          Text(
            'Współrzędne: ${_location!.latitude.toStringAsFixed(5)}, ${_location!.longitude.toStringAsFixed(5)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        TextButton.icon(
          onPressed: _loadLocation,
          icon: const Icon(Icons.my_location),
          label: const Text('Użyj mojej lokalizacji GPS'),
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
