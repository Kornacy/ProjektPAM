/// Retry helper for flaky Data Connect WebSocket reconnects in CI emulators.
Future<T> withDataConnectRetry<T>(
  Future<T> Function() action, {
  int maxAttempts = 5,
}) async {
  Object? lastError;
  StackTrace? lastStackTrace;

  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await action();
    } catch (error, stackTrace) {
      lastError = error;
      lastStackTrace = stackTrace;
      if (!_isRetryableDataConnectError(error) || attempt == maxAttempts) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      await Future<void>.delayed(Duration(milliseconds: 750 * attempt));
    }
  }

  Error.throwWithStackTrace(lastError!, lastStackTrace!);
}

bool _isRetryableDataConnectError(Object error) {
  final message = error.toString().toLowerCase();
  return message.contains('network reconnected') ||
      message.contains('mutations cannot be safely retried') ||
      message.contains('websocket') ||
      message.contains('connection') ||
      message.contains('socketexception') ||
      message.contains('connection refused') ||
      message.contains('failed host lookup') ||
      message.contains('timed out') ||
      message.contains('unavailable');
}
