class YandexOAuthException implements Exception {
  const YandexOAuthException({
    required this.code,
    required this.message,
    this.details,
  });

  final String code;
  final String message;
  final Object? details;

  @override
  String toString() {
    return 'YandexOAuthException(code: $code, message: $message, details: $details)';
  }
}
