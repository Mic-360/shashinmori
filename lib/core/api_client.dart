import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../shared/models/app_error.dart';
import 'config.dart';
import 'error_handler.dart';

class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await FirebaseAuth.instance.currentUser?.getIdToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final appError = ErrorHandler.fromResponseBody(
            error.response?.data,
            statusCode: error.response?.statusCode,
          );
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: appError,
              message: appError.message,
            ),
          );
        },
      ),
    );
  }

  late final Dio _dio;

  Dio get dio => _dio;

  static final ApiClient instance = ApiClient._();

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error) {
      throw _toAppError(error);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        options: options,
      );
    } on DioException catch (error) {
      throw _toAppError(error);
    }
  }

  AppError _toAppError(DioException error) {
    final wrapped = error.error;
    if (wrapped is AppError) {
      return wrapped;
    }

    return ErrorHandler.fromResponseBody(
      error.response?.data,
      statusCode: error.response?.statusCode,
    );
  }
}

final apiClient = ApiClient.instance;
