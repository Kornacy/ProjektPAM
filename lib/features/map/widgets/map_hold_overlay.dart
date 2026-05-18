import 'package:flutter/material.dart';

class MapHoldOverlay extends StatelessWidget {
  const MapHoldOverlay({
    super.key,
    required this.center,
    required this.progress,
    required this.holdSeconds,
    required this.onCancel,
  });

  final Offset center;
  final double progress;
  final int holdSeconds;
  final VoidCallback onCancel;

  static const double _size = 88;

  @override
  Widget build(BuildContext context) {
    final remaining = ((1 - progress) * holdSeconds).ceil().clamp(0, holdSeconds);

    return Stack(
      children: [
        Positioned(
          left: center.dx - _size / 2,
          top: center.dy - _size / 2,
          child: Material(
            elevation: 8,
            shape: const CircleBorder(),
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            child: SizedBox(
              width: _size,
              height: _size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: _size - 12,
                    height: _size - 12,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '$remaining',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Dotknij ponownie mapy, aby anulować',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  TextButton(onPressed: onCancel, child: const Text('Anuluj')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
