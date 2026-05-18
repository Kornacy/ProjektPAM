import 'package:flutter/material.dart';

Future<void> showMapHoldTutorialDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(Icons.touch_app, color: Theme.of(ctx).colorScheme.primary, size: 40),
      title: const Text('Dodawanie zgłoszenia na mapie'),
      content: const Text(
        'Dotknij wybrane miejsce na mapie. Przez 3 sekundy zobaczysz '
        'okrągły wskaźnik — dotknij ponownie lub „Anuluj”, aby przerwać.',
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
