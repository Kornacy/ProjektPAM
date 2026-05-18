import 'package:flutter/material.dart';

Future<void> showMapHoldTutorialDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(Icons.touch_app, color: Theme.of(ctx).colorScheme.primary, size: 40),
      title: const Text('Dodawanie zgłoszenia na mapie'),
      content: const Text(
        'Przytrzymaj palec na mapie. Po 1 sekundzie pojawi się duże kółko '
        'wokół palca — trzymaj dalej przez 3 sekundy aż się zapełni. '
        'Puść wcześniej, aby anulować.',
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Rozumiem'),
        ),
      ],
    ),
  );
}
