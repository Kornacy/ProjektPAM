class OfflineException implements Exception {
  OfflineException(this.message);

  final String message;

  @override
  String toString() => message;
}
