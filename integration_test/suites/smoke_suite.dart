import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/data_connect_retry.dart';
import '../helpers/integration_setup.dart';

void registerSmokeSuite() {
  testWidgets('Firebase emulator bootstrap can query public categories',
      (tester) async {
    await setUpIntegrationTests();

    final categories = await withDataConnectRetry(() async {
      final result =
          await DefaultConnector.instance.getCategories().ref().execute(
                fetchPolicy: QueryFetchPolicy.serverOnly,
              );
      return result.data.categories;
    });

    expect(categories, isNotEmpty);
  });
}
