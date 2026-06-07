import 'package:city_issues/features/reports/widgets/comments_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('CommentsPlaceholder', () {
    testWidgets('renders disabled comment form with coming soon chip', (tester) async {
      await pumpWidget(tester, const CommentsPlaceholder());

      expect(find.text('Komentarze'), findsOneWidget);
      expect(find.text('Wkrótce'), findsOneWidget);
      expect(find.text('Dodaj komentarz'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });
  });
}
