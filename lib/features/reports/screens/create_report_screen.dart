import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/core/utils/scroll_padding.dart';
import 'package:city_issues/core/utils/user_facing_error.dart';
import 'package:city_issues/core/widgets/app_loading.dart';
import 'package:city_issues/core/widgets/form_error_banner.dart';
import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/camera_service.dart';
import 'package:city_issues/services/location_service.dart';
import 'package:city_issues/services/report_service.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({
    super.key,
    this.initialLocation,
    this.embedded = false,
    this.onClose,
    this.onSubmitted,
  });

  final LatLng? initialLocation;
  final bool embedded;
  final VoidCallback? onClose;
  final VoidCallback? onSubmitted;

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  static const LatLng _defaultPosition = LatLng(52.2297, 21.0122);

  final TextEditingController _descController = TextEditingController();

  List<GetCategoriesCategories> _categories = [];
  String? _selectedCategoryId;
  final List<File> _photos = [];

  LatLng? _location;
  bool _locationLoading = true;
  String? _locationError;
  bool _requireMapInteraction = false;

  final _locationPickerKey = GlobalKey<_ReportLocationPickerState>();

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
    if (widget.initialLocation != null) {
      _location = widget.initialLocation;
      _locationLoading = false;
    } else {
      _loadLocation();
    }
  }

  LatLng get _mapInitialTarget => _location ?? _defaultPosition;

  Future<void> _loadCategories() async {
    try {
      final categories = await ReportService.instance.getCategories();
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
          _submitError = UserFacingError.loadCategories(e);
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
        final latLng = LatLng(position.latitude, position.longitude);
        setState(() {
          _location = latLng;
          _locationLoading = false;
          _requireMapInteraction = false;
        });
        _locationPickerKey.currentState?.recenterTo(latLng);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = UserFacingError.location(e);
          _location = null;
          _locationLoading = false;
          _requireMapInteraction = true;
        });
      }
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
        selectedLocation: _location
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zgłoszenie zostało wysłane.')),
        );
        if (widget.embedded) {
          widget.onSubmitted?.call();
        } else {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      setState(() => _submitError = UserFacingError.submitReport(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _handleBack() {
    if (widget.embedded) {
      widget.onClose?.call();
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: AppBar(
        title: const Text('Nowe zgłoszenie'),
        leading: widget.embedded
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Wróć',
                onPressed: _handleBack,
              )
            : null,
      ),
      body: _categoriesLoading
          ? const AppLoading(message: 'Ładowanie formularza...')
          : SingleChildScrollView(
              padding: ScrollPadding.list(context, includeNavBar: widget.embedded),
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
                  Text('Zdjęcie *', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Dodaj co najmniej jedno zdjęcie problemu.',
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
                    'Przesuń mapę tak, aby pinezka wskazywała miejsce zgłoszenia. '
                    'Możesz też pobrać lokalizację z GPS.',
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
                        : const Text('Wyślij zgłoszenie'),
                  ),
                ],
              ),
            ),
    );

    return scaffold;
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
            child: _ReportLocationPicker(
              key: _locationPickerKey,
              initialTarget: _mapInitialTarget,
              requireUserInteraction: _requireMapInteraction,
              onLocationChanged: _onPickerLocationChanged,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_location != null)
          Text(
            'Współrzędne: ${_location!.latitude.toStringAsFixed(5)}, ${_location!.longitude.toStringAsFixed(5)}',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Text(
            'Przesuń mapę, aby wskazać miejsce zgłoszenia.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
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

class _ReportLocationPicker extends StatefulWidget {
  const _ReportLocationPicker({
    super.key,
    required this.initialTarget,
    required this.onLocationChanged,
    required this.requireUserInteraction,
  });

  final LatLng initialTarget;
  final ValueChanged<LatLng> onLocationChanged;
  final bool requireUserInteraction;

  @override
  State<_ReportLocationPicker> createState() => _ReportLocationPickerState();
}

class _ReportLocationPickerState extends State<_ReportLocationPicker> {
  GoogleMapController? _controller;
  LatLng? _pendingCenter;
  late final CameraPosition _initialCamera;
  bool _userMovedCamera = false;

  static final _gestureRecognizers = <Factory<OneSequenceGestureRecognizer>>{
    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
  };

  @override
  void initState() {
    super.initState();
    _initialCamera = CameraPosition(target: widget.initialTarget, zoom: 16);
  }

  @override
  void didUpdateWidget(covariant _ReportLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.requireUserInteraction && oldWidget.requireUserInteraction) {
      _userMovedCamera = false;
    }
  }

  void recenterTo(LatLng target) {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 16)),
    );
  }

  void _notifyLocationIfReady() {
    final center = _pendingCenter;
    if (center == null) return;
    if (widget.requireUserInteraction && !_userMovedCamera) return;
    widget.onLocationChanged(center);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pinColor = Theme.of(context).colorScheme.primary;

    return Stack(
      alignment: Alignment.center,
      children: [
        GoogleMap(
          initialCameraPosition: _initialCamera,
          gestureRecognizers: _gestureRecognizers,
          onMapCreated: (controller) => _controller = controller,
          onCameraMove: (position) {
            _pendingCenter = position.target;
            _userMovedCamera = true;
          },
          onCameraIdle: _notifyLocationIfReady,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
        IgnorePointer(
          child: Transform.translate(
            offset: const Offset(0, -18),
            child: Icon(Icons.location_on, size: 44, color: pinColor),
          ),
        ),
      ],
    );
  }
}
