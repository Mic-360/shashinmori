class AppError implements Exception {
  const AppError({
    required this.code,
    required this.message,
    this.requestId,
    this.statusCode,
    this.details,
  });

  final String code;
  final String message;
  final String? requestId;
  final int? statusCode;
  final Object? details;

  @override
  String toString() => 'AppError(code: $code, message: $message)';
}
