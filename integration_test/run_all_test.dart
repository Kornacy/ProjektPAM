import 'package:integration_test/integration_test.dart';

import 'suites/auth_service_suite.dart';
import 'suites/report_service_suite.dart';
import 'suites/smoke_suite.dart';

/// Single integration test entry point for CI — one APK build, one app process.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  registerSmokeSuite();
  registerReportServiceSuite();
  registerAuthServiceSuite();
}
