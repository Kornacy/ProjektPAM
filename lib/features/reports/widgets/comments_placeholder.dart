import 'package:flutter/material.dart';

class CommentsPlaceholder extends StatelessWidget {
  const CommentsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.chat_bubble_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Komentarze',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: const Text('Wkrótce'),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              enabled: false,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Dodawanie komentarzy będzie dostępne w kolejnej wersji…',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: null,
                icon: const Icon(Icons.send),
                label: const Text('Dodaj komentarz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
