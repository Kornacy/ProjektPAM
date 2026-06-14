import 'package:city_issues/services/app_preferences.dart';
import 'package:city_issues/services/auth_service.dart';
import 'package:city_issues/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationSettingsTile extends StatefulWidget {
  const NotificationSettingsTile({super.key});

  @override
  State<NotificationSettingsTile> createState() =>
      _NotificationSettingsTileState();
}

class _NotificationSettingsTileState extends State<NotificationSettingsTile> {
  AuthorizationStatus? _systemStatus;
  TokenSyncResult? _tokenSyncResult;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    final status = await NotificationService.instance.systemPermissionStatus();
    TokenSyncResult? syncResult;
    if (AuthService.instance.isSignedIn &&
        AppPreferences.instance.notificationsEnabled) {
      syncResult = await NotificationService.instance.syncToken();
    } else {
      syncResult = NotificationService.instance.lastTokenSyncResult;
    }
    if (mounted) {
      setState(() {
        _systemStatus = status;
        _tokenSyncResult = syncResult;
      });
    }
  }

  Future<void> _onChanged(bool enabled) async {
    if (_busy) return;

    setState(() => _busy = true);
    try {
      if (enabled) {
        await AppPreferences.instance.setNotificationsEnabled(true);
        final result = await NotificationService.instance.syncToken();
        if (mounted) setState(() => _tokenSyncResult = result);
      } else {
        await NotificationService.instance.disablePushRegistration();
        await AppPreferences.instance.setNotificationsEnabled(false);
        if (mounted) {
          setState(() => _tokenSyncResult = null);
        }
      }
      await _refreshStatus();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _subtitle(bool enabled, AuthorizationStatus? status) {
    if (!AuthService.instance.isSignedIn) {
      return 'Powiadomienia o podbiciu Twoich zgłoszeń';
    }
    if (!enabled) {
      return 'Wyłączone w aplikacji';
    }
    if (_tokenSyncResult?.status == TokenSyncStatus.saved) {
      return 'Gotowe — otrzymasz powiadomienie, gdy ktoś podbije Twoje zgłoszenie';
    }
    if (_tokenSyncResult != null &&
        _tokenSyncResult!.status != TokenSyncStatus.saved) {
      return _tokenSyncResult!.message;
    }
    return switch (status) {
      AuthorizationStatus.authorized =>
        'Włączone — powiadomienia o podbiciu zgłoszeń',
      AuthorizationStatus.provisional =>
        'Włączone (ograniczone) — powiadomienia o podbiciu',
      AuthorizationStatus.denied =>
        'Brak zgody systemowej — włącz w ustawieniach telefonu',
      AuthorizationStatus.notDetermined =>
        'Dotknij, aby włączyć powiadomienia',
      _ => 'Powiadomienia o podbiciu Twoich zgłoszeń',
    };
  }

  @override
  Widget build(BuildContext context) {
    final prefs = AppPreferences.instance;
    final signedIn = AuthService.instance.isSignedIn;
    final tokenReady = _tokenSyncResult?.status == TokenSyncStatus.saved;

    return SwitchListTile(
      secondary: Icon(
        tokenReady && prefs.notificationsEnabled
            ? Icons.notifications_active_outlined
            : Icons.notifications_outlined,
      ),
      title: const Text('Powiadomienia push'),
      subtitle: Text(_subtitle(prefs.notificationsEnabled, _systemStatus)),
      value: signedIn && prefs.notificationsEnabled,
      onChanged: signedIn && !_busy ? _onChanged : null,
    );
  }
}
