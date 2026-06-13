import 'package:city_issues/services/report_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/integration_setup.dart';

void main() {
  testWidgets('Firebase emulator bootstrap can query public categories',
      (tester) async {
    await setUpIntegrationTests();

    final categories = await ReportService.instance.getCategories();

    expect(categories, isNotEmpty);
  });
}
