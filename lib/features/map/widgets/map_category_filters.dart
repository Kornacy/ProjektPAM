import 'package:flutter/material.dart';
import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/dataconnect_generated/default.dart';

class MapCategoryFilters extends StatelessWidget {
  const MapCategoryFilters({
    super.key,
    required this.categories,
    required this.enabledIds,
    required this.onToggle,
    required this.onClearAll,
    required this.onSelectAll,
  });

  final List<GetCategoriesCategories> categories;
  final Set<String> enabledIds;
  final void Function(String categoryId) onToggle;
  final VoidCallback onClearAll;
  final VoidCallback onSelectAll;

  @override
  Widget build(BuildContext context) {
    final allEnabled = enabledIds.length == categories.length;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: allEnabled ? 'Ukryj wszystkie' : 'Pokaż wszystkie',
              child: InkWell(
                onTap: allEnabled ? onClearAll : onSelectAll,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    allEnabled ? Icons.filter_alt_off : Icons.filter_alt,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const Divider(height: 1, indent: 8, endIndent: 8),
            ...categories.map((category) {
              final color = ReportUtils.parsePinColor(category.pinColor);
              final enabled = enabledIds.contains(category.id);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Tooltip(
                  message: category.name,
                  preferBelow: false,
                  child: InkWell(
                    onTap: () => onToggle(category.id),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: enabled
                            ? color.withValues(alpha: 0.25)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: enabled ? color : Colors.grey.shade400,
                          width: enabled ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        ReportUtils.categoryIcon(category.iconName),
                        color: enabled ? color : Colors.grey,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
