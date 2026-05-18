import 'package:flutter/material.dart';
import 'package:city_issues/core/utils/report_utils.dart';
import 'package:city_issues/dataconnect_generated/default.dart';

class MapCategoryFilters extends StatefulWidget {
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
  State<MapCategoryFilters> createState() => _MapCategoryFiltersState();
}

class _MapCategoryFiltersState extends State<MapCategoryFilters> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final allEnabled = widget.enabledIds.length == widget.categories.length;
    final enabledCount = widget.enabledIds.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          elevation: 3,
          shape: const CircleBorder(),
          color: Theme.of(context).colorScheme.surface,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Badge(
                isLabelVisible: enabledCount < widget.categories.length,
                label: Text('$enabledCount'),
                child: Icon(
                  _expanded ? Icons.filter_list_off : Icons.filter_list,
                  size: 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.97),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FilterActionButton(
                    icon: allEnabled ? Icons.visibility_off : Icons.visibility,
                    tooltip: allEnabled ? 'Ukryj wszystkie' : 'Pokaż wszystkie',
                    onTap: allEnabled ? widget.onClearAll : widget.onSelectAll,
                  ),
                  const Divider(height: 1, indent: 10, endIndent: 10),
                  ...widget.categories.map((category) {
                    final accent = ReportUtils.parsePinColor(category.pinColor);
                    final enabled = widget.enabledIds.contains(category.id);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      child: _CategoryFilterChip(
                        icon: ReportUtils.categoryIcon(category.iconName),
                        accentColor: accent,
                        enabled: enabled,
                        tooltip: category.name,
                        onTap: () => widget.onToggle(category.id),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FilterActionButton extends StatelessWidget {
  const _FilterActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.icon,
    required this.accentColor,
    required this.enabled,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color accentColor;
  final bool enabled;
  final String tooltip;
  final VoidCallback onTap;

  static const double _size = 34;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_size / 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1 : 0.45,
          child: Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              color: fill,
              shape: BoxShape.circle,
              border: Border.all(
                color: enabled ? accentColor : Colors.grey.shade500,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 17,
              color: enabled ? accentColor : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}
