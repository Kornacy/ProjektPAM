import 'package:flutter/material.dart';

class MapHoldOverlay extends StatelessWidget {
  const MapHoldOverlay({
    super.key,
    required this.center,
    required this.progress,
    required this.holdSeconds,
  });

  final Offset center;
  final double progress;
  final int holdSeconds;

  static const double _size = 88;

  @override
  Widget build(BuildContext context) {
    final remaining = ((1 - progress) * holdSeconds).ceil().clamp(0, holdSeconds);

    return Positioned(
      left: center.dx - _size / 2,
      top: center.dy - _size / 2,
      child: IgnorePointer(
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
    );
  }
}
