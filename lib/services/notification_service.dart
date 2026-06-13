import 'dart:io' show Platform;

import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/auth_service.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Rejestruje token FCM i wysyła powiadomienia push (m.in. przy upvote).
class NotificationService {
  NotificationService._({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    FirebaseFunctions? functions,
    AuthService? authService,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin(),
        _functions = functions ??
            FirebaseFunctions.instanceFor(
              app: Firebase.app(),
              region: 'europe-central2',
            ),
        _authService = authService ?? AuthService.instance;

  static final NotificationService instance = NotificationService._();

  @visibleForTesting
  factory NotificationService.forTesting({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    FirebaseFunctions? functions,
    AuthService? authService,
  }) =>
      NotificationService._(
        messaging: messaging,
        localNotifications: localNotifications,
        functions: functions,
        authService: authService,
      );

  static const _upvoteChannelId = 'report_upvotes';
  static const _upvoteChannelName = 'Wsparcie zgłoszeń';

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirebaseFunctions _functions;
  final AuthService _authService;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await _configureLocalNotifications();
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    _messaging.onTokenRefresh.listen((_) => syncToken());

    _initialized = true;
    await syncToken();
  }

  Future<void> syncToken() async {
    if (!_authService.isSignedIn) return;

    try {
      final settings = await _messaging.requestPermission();
      final authorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!authorized) return;

      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;

      await DefaultConnector.instance
          .updateFcmToken(token: token)
          .execute();
    } catch (e, stack) {
      debugPrint('NotificationService.syncToken failed: $e');
      debugPrint('$stack');
    }
  }

  Future<void> notifyUpvoteOnReport(String reportId) async {
    try {
      final callable = _functions.httpsCallable('notifyUpvoteOnReport');
      await callable.call({'reportId': reportId});
    } catch (e) {
      debugPrint('notifyUpvoteOnReport failed: $e');
    }
  }

  Future<void> _configureLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _upvoteChannelId,
        _upvoteChannelName,
        description: 'Powiadomienia, gdy ktoś podbije Twoje zgłoszenie',
        importance: Importance.high,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _upvoteChannelId,
        _upvoteChannelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
    );
  }
}
