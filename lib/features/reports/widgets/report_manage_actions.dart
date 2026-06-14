import 'package:flutter/material.dart';

Future<bool?> showReportDeleteDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Usunąć zgłoszenie?'),
      content: const Text(
        'Tej operacji nie można cofnąć. Zgłoszenie wraz ze zdjęciami, '
        'komentarzami i głosami zostanie trwale usunięte.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Usuń'),
        ),
      ],
    ),
  );
}
