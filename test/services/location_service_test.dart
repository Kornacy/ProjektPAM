import 'package:city_issues/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationService.getLastKnownLocation', () {
    test('returns null when no coordinates are saved', () async {
      SharedPreferences.setMockInitialValues({});

      final result = await LocationService.instance.getLastKnownLocation();

      expect(result, isNull);
    });

    test('returns null when only latitude is saved', () async {
      SharedPreferences.setMockInitialValues({'last_lat': 52.23});

      final result = await LocationService.instance.getLastKnownLocation();

      expect(result, isNull);
    });

    test('returns saved coordinates', () async {
      SharedPreferences.setMockInitialValues({
        'last_lat': 52.2297,
        'last_lng': 21.0122,
      });

      final result = await LocationService.instance.getLastKnownLocation();

      expect(result?.lat, 52.2297);
      expect(result?.lng, 21.0122);
    });
  });
}
