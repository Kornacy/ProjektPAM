import 'dart:io';

import 'package:city_issues/services/storage_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StorageService.uploadReportPhoto', () {
    test('throws when user is not signed in', () async {
      final service = StorageService.forTesting(
        firebaseAuth: MockFirebaseAuth(signedIn: false),
      );
      final photo = File('test_photo.jpg');

      await expectLater(
        service.uploadReportPhoto(photo),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('nie jest zalogowany'),
          ),
        ),
      );
    });

    test('requires signed-in user before upload', () async {
      final service = StorageService.forTesting(
        firebaseAuth: MockFirebaseAuth(signedIn: false),
      );
      final photo = File('test_photo.jpg');

      await expectLater(
        service.uploadReportPhoto(photo),
        throwsA(isA<Exception>()),
      );
    });
  });
}
