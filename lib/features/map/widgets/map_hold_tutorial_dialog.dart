import 'package:flutter/material.dart';

Future<void> showMapHoldTutorialDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(Icons.touch_app, color: Theme.of(ctx).colorScheme.primary, size: 40),
      title: const Text('Dodawanie zgłoszenia na mapie'),
      content: const Text(
        'Sposób 1: przytrzymaj mapę (long press). Sposób 2: włącz ikonę '
        'pinezki na pasku i przytrzymaj palec. Po 1 s pojawi się kółko, '
        'po 3 s wypełnienia — formularz zgłoszenia. Puść wcześniej = anuluj.',
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
