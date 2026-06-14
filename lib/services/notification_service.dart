import 'dart:io' show Platform;

import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/app_preferences.dart';
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
    AppPreferences? appPreferences,
    Future<void> Function(String token)? persistFcmToken,
    Future<void> Function(String name, Map<String, dynamic> data)?
        invokeCallable,
  })  : _messaging = messaging,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin(),
        _functions = functions,
        _authService = authService ?? AuthService.instance,
        _appPreferences = appPreferences ?? AppPreferences.instance,
        _persistFcmToken = persistFcmToken,
        _invokeCallable = invokeCallable;

  static final NotificationService instance = NotificationService._();

  @visibleForTesting
  factory NotificationService.forTesting({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    FirebaseFunctions? functions,
    AuthService? authService,
    AppPreferences? appPreferences,
    Future<void> Function(String token)? persistFcmToken,
    Future<void> Function(String name, Map<String, dynamic> data)?
        invokeCallable,
  }) =>
      NotificationService._(
        messaging: messaging,
        localNotifications: localNotifications,
        functions: functions,
        authService: authService,
        appPreferences: appPreferences,
        persistFcmToken: persistFcmToken,
        invokeCallable: invokeCallable,
      );

  static const _upvoteChannelId = 'report_upvotes';
  static const _upvoteChannelName = 'Wsparcie zgłoszeń';
  static const _upvoteNotificationType = 'upvote';

  final FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirebaseFunctions? _functions;
  final AuthService _authService;
  final AppPreferences _appPreferences;
  final Future<void> Function(String token)? _persistFcmToken;
  final Future<void> Function(String name, Map<String, dynamic> data)?
      _invokeCallable;

  void Function(String reportId)? _onReportOpened;
  String? _pendingReportId;

  FirebaseMessaging get _messagingClient =>
      _messaging ?? FirebaseMessaging.instance;

  FirebaseFunctions get _functionsClient =>
      _functions ??
      FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'europe-central2',
      );

  bool _initialized = false;

  void setOnReportOpened(void Function(String reportId)? handler) {
    _onReportOpened = handler;
    final pending = _pendingReportId;
    if (handler != null && pending != null) {
      _pendingReportId = null;
      handler(pending);
    }
  }

  Future<AuthorizationStatus> systemPermissionStatus() async {
    final settings = await _messagingClient.getNotificationSettings();
    return settings.authorizationStatus;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    await _configureLocalNotifications();
    await _messagingClient.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessageTap);
    _messagingClient.onTokenRefresh.listen((_) => syncToken());

    _initialized = true;

    final initialMessage = await _messagingClient.getInitialMessage();
    if (initialMessage != null) {
      _handleRemoteMessageTap(initialMessage);
    }

    await syncToken();
  }

  Future<void> syncToken() async {
    if (!_authService.isSignedIn || !_appPreferences.notificationsEnabled) {
      return;
    }

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

  Future<void> disablePushRegistration() async {
    try {
      await _messagingClient.deleteToken();
    } catch (e) {
      debugPrint('NotificationService.disablePushRegistration failed: $e');
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
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final reportId = response.payload;
        if (reportId != null && reportId.isNotEmpty) {
          _openReportFromNotification(reportId);
        }
      },
    );

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

  void _handleRemoteMessageTap(RemoteMessage message) {
    final reportId = _extractReportId(message.data);
    if (reportId != null) {
      _openReportFromNotification(reportId);
    }
  }

  String? _extractReportId(Map<String, dynamic> data) {
    if (data['type'] != _upvoteNotificationType) return null;
    final reportId = data['reportId'];
    if (reportId is! String || reportId.isEmpty) return null;
    return reportId;
  }

  void _openReportFromNotification(String reportId) {
    final handler = _onReportOpened;
    if (handler != null) {
      handler(reportId);
      return;
    }
    _pendingReportId = reportId;
  }

  @visibleForTesting
  void handleReportNotificationData(Map<String, dynamic> data) {
    final reportId = _extractReportId(data);
    if (reportId != null) {
      _openReportFromNotification(reportId);
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    if (!_appPreferences.notificationsEnabled) return;

    final notification = message.notification;
    if (notification == null) return;

    final reportId = _extractReportId(message.data);

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
      payload: reportId,
    );
  }
}
