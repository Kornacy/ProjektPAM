import 'package:flutter/material.dart';

class MapHoldOverlay extends StatelessWidget {
  const MapHoldOverlay({
    super.key,
    required this.progress,
    required this.onCancel,
  });

  final double progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final remaining = ((1 - progress) * 5).ceil().clamp(0, 5);

    return Stack(
      children: [
        ModalBarrier(
          color: Colors.black.withValues(alpha: 0.25),
          dismissible: false,
        ),
        Center(
          child: Material(
            elevation: 12,
            shape: const CircleBorder(),
            color: Theme.of(context).colorScheme.surface,
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$remaining',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'sek.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          right: 16,
          child: IconButton.filledTonal(
            onPressed: onCancel,
            icon: const Icon(Icons.close),
            tooltip: 'Anuluj',
          ),
        ),
      ],
    );
  }
}
