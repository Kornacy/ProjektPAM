import 'dart:async';
import 'dart:io' show Platform;

import 'package:city_issues/dataconnect_generated/default.dart';
import 'package:city_issues/services/app_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:city_issues/services/auth_service.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum TokenSyncStatus {
  skipped,
  permissionDenied,
  noToken,
  saved,
  profileMissing,
  failed,
}

class TokenSyncResult {
  const TokenSyncResult(this.status, this.message);

  final TokenSyncStatus status;
  final String message;
}

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
  void Function()? _onReportsChanged;
  StreamSubscription<User?>? _authSubscription;

  FirebaseMessaging get _messagingClient =>
      _messaging ?? FirebaseMessaging.instance;

  FirebaseFunctions get _functionsClient =>
      _functions ??
      FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'europe-central2',
      );

  bool _initialized = false;
  TokenSyncResult? _lastTokenSyncResult;

  TokenSyncResult? get lastTokenSyncResult => _lastTokenSyncResult;

  void setOnReportOpened(void Function(String reportId)? handler) {
    _onReportOpened = handler;
    final pending = _pendingReportId;
    if (handler != null && pending != null) {
      _pendingReportId = null;
      handler(pending);
    }
  }

  void setOnReportsChanged(void Function()? handler) {
    _onReportsChanged = handler;
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
    _authSubscription ??= _authService.authStateChanges.listen((user) {
      if (user != null) {
        syncToken();
      }
    });

    _initialized = true;

    final initialMessage = await _messagingClient.getInitialMessage();
    if (initialMessage != null) {
      _handleRemoteMessageTap(initialMessage);
    }

    await syncToken();
  }

  Future<TokenSyncResult> syncToken() async {
    if (!_authService.isSignedIn || !_appPreferences.notificationsEnabled) {
      return _lastTokenSyncResult = const TokenSyncResult(
        TokenSyncStatus.skipped,
        'Powiadomienia wyłączone lub brak logowania',
      );
    }

    try {
      final authorized = await _ensureNotificationPermissions();
      if (!authorized) {
        return _lastTokenSyncResult = const TokenSyncResult(
          TokenSyncStatus.permissionDenied,
          'Brak zgody systemowej na powiadomienia',
        );
      }

      final token = await _messagingClient.getToken();
      if (token == null || token.isEmpty) {
        return _lastTokenSyncResult = const TokenSyncResult(
          TokenSyncStatus.noToken,
          'Nie udało się pobrać tokena FCM z urządzenia',
        );
      }

      final saved = await _saveFcmToken(token);
      if (!saved) {
        return _lastTokenSyncResult = const TokenSyncResult(
          TokenSyncStatus.profileMissing,
          'Nie zapisano tokena — zaloguj się ponownie',
        );
      }

      return _lastTokenSyncResult = const TokenSyncResult(
        TokenSyncStatus.saved,
        'Powiadomienia skonfigurowane na tym urządzeniu',
      );
    } catch (e, stack) {
      debugPrint('NotificationService.syncToken failed: $e');
      debugPrint('$stack');
      return _lastTokenSyncResult = TokenSyncResult(
        TokenSyncStatus.failed,
        'Błąd rejestracji: $e',
      );
    }
  }

  Future<bool> _ensureNotificationPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) return true;

      final alreadyEnabled =
          await androidPlugin.areNotificationsEnabled() ?? true;
      if (alreadyEnabled) return true;

      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? true;
    }

    final settings = await _messagingClient.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> disablePushRegistration() async {
    try {
      await _messagingClient.deleteToken();
      if (_authService.isSignedIn) {
        await DefaultConnector.instance.updateFcmToken(token: '').execute();
      }
    } catch (e) {
      debugPrint('NotificationService.disablePushRegistration failed: $e');
    }
  }

  Future<void> showUpvoteReceived({
    required String reportId,
    required String categoryName,
    String? description,
    required int newCount,
  }) async {
    if (!_appPreferences.notificationsEnabled) return;

    final summary = description?.trim().isNotEmpty == true
        ? (description!.trim().length > 60
            ? '${description.trim().substring(0, 57)}...'
            : description.trim())
        : categoryName;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _upvoteChannelId,
        _upvoteChannelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _localNotifications.show(
      reportId.hashCode,
      'Nowe wsparcie zgłoszenia',
      'Ktoś podbił Twoje zgłoszenie: $summary ($newCount)',
      details,
      payload: reportId,
    );
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
      final result = await callable.call({'reportId': reportId});
      debugPrint('notifyUpvoteOnReport: ${result.data}');
    } catch (e) {
      debugPrint('notifyUpvoteOnReport failed: $e');
    }
  }

  Future<bool> _saveFcmToken(String token) async {
    if (_persistFcmToken != null) {
      await _persistFcmToken!(token);
      return true;
    }

    final result =
        await DefaultConnector.instance.updateFcmToken(token: token).execute();
    if (result.data.user_update == null) {
      debugPrint(
        'NotificationService: nie udało się zapisać FCM tokena (brak profilu użytkownika?).',
      );
      return false;
    }
    debugPrint('NotificationService: FCM token zapisany w profilu.');
    return true;
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
      _onReportsChanged?.call();
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
    if (reportId != null) {
      _onReportsChanged?.call();
    }

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
