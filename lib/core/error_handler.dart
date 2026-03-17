import '../shared/models/app_error.dart';

class ErrorHandler {
  static AppError fromResponseBody(Object? data, {int? statusCode}) {
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        return AppError(
          code: error['code'] as String? ?? 'API_ERROR',
          message: error['message'] as String? ?? 'Request failed.',
          requestId: error['requestId'] as String?,
          statusCode: statusCode,
          details: error['details'],
        );
      }
    }

    return AppError(
      code: 'API_ERROR',
      message: 'Request failed.',
      statusCode: statusCode,
      details: data,
    );
  }
}
