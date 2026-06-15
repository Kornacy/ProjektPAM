import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  ConnectivityService._({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  static final ConnectivityService instance = ConnectivityService._();

  @visibleForTesting
  factory ConnectivityService.forTesting({Connectivity? connectivity}) =>
      ConnectivityService._(connectivity: connectivity);

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = true;

  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = _hasNetwork(results);
    _subscription ??= _connectivity.onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = _hasNetwork(results);
      if (wasOnline != _isOnline) {
        notifyListeners();
      }
    });
    notifyListeners();
  }

  bool _hasNetwork(List<ConnectivityResult> results) {
    if (results.isEmpty) return true;
    return results.any((result) => result != ConnectivityResult.none);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @visibleForTesting
  void setOnlineForTesting(bool value) {
    _isOnline = value;
    notifyListeners();
  }
}
