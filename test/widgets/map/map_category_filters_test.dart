import 'package:city_issues/features/map/widgets/map_category_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

void main() {
  group('MapCategoryFilters', () {
    testWidgets('expands panel and toggles category filter', (tester) async {
      final enabledIds = TestFixtures.sampleCategories.map((c) => c.id).toSet();
      String? toggledId;

      await pumpWidget(
        tester,
        MapCategoryFilters(
          categories: TestFixtures.sampleCategories,
          enabledIds: enabledIds,
          onToggle: (id) => toggledId = id,
          onClearAll: () {},
          onSelectAll: () {},
        ),
      );

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byIcon(Icons.add_road), findsNothing);

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.filter_list_off), findsOneWidget);
      expect(find.byIcon(Icons.add_road), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add_road));
      await tester.pump();

      expect(toggledId, 'cat-1');
    });

    testWidgets('calls onClearAll when all categories are enabled', (tester) async {
      var cleared = false;

      await pumpWidget(
        tester,
        MapCategoryFilters(
          categories: TestFixtures.sampleCategories,
          enabledIds: TestFixtures.sampleCategories.map((c) => c.id).toSet(),
          onToggle: (_) {},
          onClearAll: () => cleared = true,
          onSelectAll: () {},
        ),
      );

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(cleared, isTrue);
    });

    testWidgets('calls onSelectAll when no categories are enabled', (tester) async {
      var selectedAll = false;

      await pumpWidget(
        tester,
        MapCategoryFilters(
          categories: TestFixtures.sampleCategories,
          enabledIds: const {},
          onToggle: (_) {},
          onClearAll: () {},
          onSelectAll: () => selectedAll = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      expect(selectedAll, isTrue);
    });
  });
}
