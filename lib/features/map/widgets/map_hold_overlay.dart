import 'package:flutter/material.dart';

/// Okrągły wskaźnik przytrzymania — wyświetlany dopiero po 1 s, wypełnia się przez [fillSeconds].
class MapHoldOverlay extends StatelessWidget {
  const MapHoldOverlay({
    super.key,
    required this.center,
    required this.progress,
    required this.fillSeconds,
    this.showWaiting = false,
    required this.onCancel,
  });

  final Offset center;
  final double progress;
  final int fillSeconds;
  final bool showWaiting;
  final VoidCallback onCancel;

  static const double _size = 120;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (showWaiting) {
      return Positioned(
        left: center.dx - 10,
        top: center.dy - 10,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withValues(alpha: 0.5),
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      );
    }

    final remaining = ((1 - progress) * fillSeconds).ceil().clamp(0, fillSeconds);

    return Stack(
      children: [
        Positioned(
          left: center.dx - _size / 2,
          top: center.dy - _size / 2,
          child: IgnorePointer(
            child: Material(
              elevation: 10,
              shape: const CircleBorder(),
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
              child: SizedBox(
                width: _size,
                height: _size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: _size - 16,
                      height: _size - 16,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 7,
                        strokeCap: StrokeCap.round,
                        color: primary,
                        backgroundColor: primary.withValues(alpha: 0.15),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$remaining',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: onSurface,
                              ),
                        ),
                        Text(
                          'sek.',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
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
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      'Puść palec, aby anulować',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                TextButton(onPressed: onCancel, child: const Text('Anuluj')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
