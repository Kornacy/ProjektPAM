import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReportLocationPicker extends StatefulWidget {
  const ReportLocationPicker({
    super.key,
    required this.initialTarget,
    required this.onLocationChanged,
    this.requireUserInteraction = false,
  });

  final LatLng initialTarget;
  final ValueChanged<LatLng> onLocationChanged;
  final bool requireUserInteraction;

  @override
  State<ReportLocationPicker> createState() => ReportLocationPickerState();
}

class ReportLocationPickerState extends State<ReportLocationPicker> {
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
  void didUpdateWidget(covariant ReportLocationPicker oldWidget) {
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
