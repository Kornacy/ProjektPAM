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
    Future<void> Function(String token)? persistFcmToken,
    Future<void> Function(String name, Map<String, dynamic> data)?
        invokeCallable,
  })  : _messaging = messaging,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin(),
        _functions = functions,
        _authService = authService ?? AuthService.instance,
        _persistFcmToken = persistFcmToken,
        _invokeCallable = invokeCallable;

  static final NotificationService instance = NotificationService._();

  @visibleForTesting
  factory NotificationService.forTesting({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    FirebaseFunctions? functions,
    AuthService? authService,
    Future<void> Function(String token)? persistFcmToken,
    Future<void> Function(String name, Map<String, dynamic> data)?
        invokeCallable,
  }) =>
      NotificationService._(
        messaging: messaging,
        localNotifications: localNotifications,
        functions: functions,
        authService: authService,
        persistFcmToken: persistFcmToken,
        invokeCallable: invokeCallable,
      );

  static const _upvoteChannelId = 'report_upvotes';
  static const _upvoteChannelName = 'Wsparcie zgłoszeń';

  final FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirebaseFunctions? _functions;
  final AuthService _authService;
  final Future<void> Function(String token)? _persistFcmToken;
  final Future<void> Function(String name, Map<String, dynamic> data)?
      _invokeCallable;

  FirebaseMessaging get _messagingClient =>
      _messaging ?? FirebaseMessaging.instance;

  FirebaseFunctions get _functionsClient =>
      _functions ??
      FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'europe-central2',
      );

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await _configureLocalNotifications();
    await _messagingClient.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    _messagingClient.onTokenRefresh.listen((_) => syncToken());

    _initialized = true;
    await syncToken();
  }

  Future<void> syncToken() async {
    if (!_authService.isSignedIn) return;

    try {
      final settings = await _messagingClient.requestPermission();
      final authorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!authorized) return;

      final token = await _messagingClient.getToken();
      if (token == null || token.isEmpty) return;

      await _saveFcmToken(token);
    } catch (e, stack) {
      debugPrint('NotificationService.syncToken failed: $e');
      debugPrint('$stack');
    }
  }

  Future<void> notifyUpvoteOnReport(String reportId) async {
    try {
      if (_invokeCallable != null) {
        await _invokeCallable!(
          'notifyUpvoteOnReport',
          {'reportId': reportId},
        );
        return;
      }

      final callable = _functionsClient.httpsCallable('notifyUpvoteOnReport');
      await callable.call({'reportId': reportId});
    } catch (e) {
      debugPrint('notifyUpvoteOnReport failed: $e');
    }
  }

  Future<void> _saveFcmToken(String token) async {
    if (_persistFcmToken != null) {
      await _persistFcmToken!(token);
      return;
    }

    await DefaultConnector.instance.updateFcmToken(token: token).execute();
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
