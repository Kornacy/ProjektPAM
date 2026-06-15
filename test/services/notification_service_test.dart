import 'package:city_issues/services/app_preferences.dart';
import 'package:city_issues/services/auth_service.dart';
import 'package:city_issues/services/notification_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

NotificationSettings _notificationSettings(AuthorizationStatus status) {
  return NotificationSettings(
    authorizationStatus: status,
    alert: AppleNotificationSetting.enabled,
    announcement: AppleNotificationSetting.notSupported,
    badge: AppleNotificationSetting.enabled,
    carPlay: AppleNotificationSetting.notSupported,
    lockScreen: AppleNotificationSetting.enabled,
    notificationCenter: AppleNotificationSetting.enabled,
    showPreviews: AppleShowPreviewSetting.always,
    timeSensitive: AppleNotificationSetting.notSupported,
    criticalAlert: AppleNotificationSetting.notSupported,
    sound: AppleNotificationSetting.enabled,
    providesAppNotificationSettings: AppleNotificationSetting.notSupported,
  );
}

class FakeFirebaseMessaging extends Fake implements FirebaseMessaging {
  FakeFirebaseMessaging({
    this.authorizationStatus = AuthorizationStatus.authorized,
    this.token = 'test-fcm-token',
  });

  AuthorizationStatus authorizationStatus;
  String? token;

  int requestPermissionCalls = 0;
  int getTokenCalls = 0;
  int deleteTokenCalls = 0;

  @override
  Future<void> deleteToken() async {
    deleteTokenCalls++;
    token = null;
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    return _notificationSettings(authorizationStatus);
  }

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
    bool providesAppNotificationSettings = false,
  }) async {
    requestPermissionCalls++;
    return _notificationSettings(authorizationStatus);
  }

  @override
  Future<String?> getToken({String? vapidKey}) async {
    getTokenCalls++;
    return token;
  }
}

void main() {
  group('NotificationService.syncToken', () {
    test('does nothing when user is not signed in', () async {
      final messaging = FakeFirebaseMessaging();
      String? savedToken;

      final service = NotificationService.forTesting(
        messaging: messaging,
        authService: AuthService.forTesting(
          firebaseAuth: MockFirebaseAuth(signedIn: false),
        ),
        persistFcmToken: (token) async => savedToken = token,
      );

      await service.syncToken();

      expect(messaging.requestPermissionCalls, 0);
      expect(messaging.getTokenCalls, 0);
      expect(savedToken, isNull);
    });

    test('does not persist token when permission is denied', () async {
      final messaging = FakeFirebaseMessaging(
        authorizationStatus: AuthorizationStatus.denied,
      );
      String? savedToken;

      final service = NotificationService.forTesting(
        messaging: messaging,
        authService: AuthService.forTesting(
          firebaseAuth: MockFirebaseAuth(signedIn: true),
        ),
        persistFcmToken: (token) async => savedToken = token,
      );

      await service.syncToken();

      expect(messaging.requestPermissionCalls, 1);
      expect(messaging.getTokenCalls, 0);
      expect(savedToken, isNull);
    });

    test('does not persist token when FCM returns empty token', () async {
      final messaging = FakeFirebaseMessaging(token: '');
      String? savedToken;

      final service = NotificationService.forTesting(
        messaging: messaging,
        authService: AuthService.forTesting(
          firebaseAuth: MockFirebaseAuth(signedIn: true),
        ),
        persistFcmToken: (token) async => savedToken = token,
      );

      await service.syncToken();

      expect(messaging.getTokenCalls, 1);
      expect(savedToken, isNull);
    });

    test('persists token when user is signed in and permission granted',
        () async {
      final messaging = FakeFirebaseMessaging(token: 'device-token-123');
      String? savedToken;

      final service = NotificationService.forTesting(
        messaging: messaging,
        authService: AuthService.forTesting(
          firebaseAuth: MockFirebaseAuth(signedIn: true),
        ),
        persistFcmToken: (token) async => savedToken = token,
      );

      await service.syncToken();

      expect(messaging.requestPermissionCalls, 1);
      expect(messaging.getTokenCalls, 1);
      expect(savedToken, 'device-token-123');
    });

    test('accepts provisional notification permission', () async {
      final messaging = FakeFirebaseMessaging(
        authorizationStatus: AuthorizationStatus.provisional,
        token: 'provisional-token',
      );
      String? savedToken;

      final service = NotificationService.forTesting(
        messaging: messaging,
        authService: AuthService.forTesting(
          firebaseAuth: MockFirebaseAuth(signedIn: true),
        ),
        persistFcmToken: (token) async => savedToken = token,
      );

      await service.syncToken();

      expect(savedToken, 'provisional-token');
    });

    test('swallows errors from messaging without throwing', () async {
      final messaging = _ThrowingFirebaseMessaging();

      final service = NotificationService.forTesting(
        messaging: messaging,
        authService: AuthService.forTesting(
          firebaseAuth: MockFirebaseAuth(signedIn: true),
        ),
        persistFcmToken: (_) async {},
      );

      await expectLater(service.syncToken(), completes);
    });

    test('does not persist token when notifications disabled in app', () async {
      SharedPreferences.setMockInitialValues({'notifications_enabled': false});
      final prefs = AppPreferences.instance;
      await prefs.load();

      final messaging = FakeFirebaseMessaging();
      String? savedToken;

      final service = NotificationService.forTesting(
        messaging: messaging,
        authService: AuthService.forTesting(
          firebaseAuth: MockFirebaseAuth(signedIn: true),
        ),
        appPreferences: prefs,
        persistFcmToken: (token) async => savedToken = token,
      );

      await service.syncToken();

      expect(messaging.requestPermissionCalls, 0);
      expect(savedToken, isNull);
    });
  });

  group('NotificationService report notification taps', () {
    test('invokes handler for upvote payload', () {
      String? openedReportId;
      final service = NotificationService.forTesting(
        messaging: FakeFirebaseMessaging(),
      );

      service.setOnReportOpened((reportId) => openedReportId = reportId);
      service.handleReportNotificationData(
        const {'type': 'upvote', 'reportId': 'report-42'},
      );

      expect(openedReportId, 'report-42');
    });

    test('stores pending report id until handler is registered', () {
      String? openedReportId;
      final service = NotificationService.forTesting(
        messaging: FakeFirebaseMessaging(),
      );

      service.handleReportNotificationData(
        const {'type': 'upvote', 'reportId': 'report-pending'},
      );
      service.setOnReportOpened((reportId) => openedReportId = reportId);

      expect(openedReportId, 'report-pending');
    });

    test('ignores unknown notification types', () {
      String? openedReportId;
      final service = NotificationService.forTesting(
        messaging: FakeFirebaseMessaging(),
      );

      service.setOnReportOpened((reportId) => openedReportId = reportId);
      service.handleReportNotificationData(
        const {'type': 'comment', 'reportId': 'report-1'},
      );

      expect(openedReportId, isNull);
    });
  });

  group('NotificationService.disablePushRegistration', () {
    test('deletes FCM token', () async {
      final messaging = FakeFirebaseMessaging();
      final service = NotificationService.forTesting(messaging: messaging);

      await service.disablePushRegistration();

      expect(messaging.deleteTokenCalls, 1);
    });
  });

  group('NotificationService.notifyUpvoteOnReport', () {
    test('invokes cloud function with reportId', () async {
      String? functionName;
      Map<String, dynamic>? payload;

      final service = NotificationService.forTesting(
        messaging: FakeFirebaseMessaging(),
        invokeCallable: (name, data) async {
          functionName = name;
          payload = data;
        },
      );

      await service.notifyUpvoteOnReport('report-abc');

      expect(functionName, 'notifyUpvoteOnReport');
      expect(payload, {'reportId': 'report-abc'});
    });

    test('swallows cloud function errors without throwing', () async {
      final service = NotificationService.forTesting(
        messaging: FakeFirebaseMessaging(),
        invokeCallable: (_, _) async {
          throw Exception('functions/unavailable');
        },
      );

      await expectLater(
        service.notifyUpvoteOnReport('report-abc'),
        completes,
      );
    });
  });
}

class _ThrowingFirebaseMessaging extends Fake implements FirebaseMessaging {
  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
    bool providesAppNotificationSettings = false,
  }) {
    throw Exception('permission failed');
  }
}
