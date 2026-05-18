import 'package:flutter/material.dart';

Future<void> showMapHoldTutorialDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(Icons.touch_app, color: Theme.of(ctx).colorScheme.primary, size: 40),
      title: const Text('Dodawanie zgłoszenia na mapie'),
      content: const Text(
        'Przytrzymaj wybrane miejsce na mapie przez 5 sekund. '
        'Zobaczysz okrągły wskaźnik postępu — po ukończeniu otworzy się formularz zgłoszenia.',
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
