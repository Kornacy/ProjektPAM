import 'package:flutter/material.dart';

class MapHoldOverlay extends StatelessWidget {
  const MapHoldOverlay({
    super.key,
    required this.progress,
    required this.secondsLeft,
    required this.onCancel,
  });

  final double progress;
  final int secondsLeft;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(value: progress),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dodawanie zgłoszenia…',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          'Przytrzymaj mapę — $secondsLeft s',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close),
                    tooltip: 'Anuluj',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress),
            ],
          ),
        ),
      ),
    );
  }
}
