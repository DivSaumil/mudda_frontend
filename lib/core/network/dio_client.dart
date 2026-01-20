/// Dio HTTP client configuration.
///
/// Creates and configures the Dio instance used throughout the app.
library;

import 'package:dio/dio.dart';
import '../config/app_constants.dart';
import '../storage/storage_service.dart';
import 'auth_interceptor.dart';

/// Factory class for creating configured Dio instances.
class DioClient {
  DioClient._(); // Private constructor

  /// Creates a configured Dio instance with authentication support.
  ///
  /// [storageService] The storage service for token management.
  /// Returns a Dio instance with base URL, timeouts, and auth interceptor.
  static Dio create(StorageService storageService) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        contentType: Headers.jsonContentType,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add authentication interceptor
    dio.interceptors.add(AuthInterceptor(storageService));

    // Add logging in debug mode
    assert(() {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (object) => print('DIO: $object'),
        ),
      );
      return true;
    }());

    return dio;
  }

  /// Creates a Dio instance without authentication for public endpoints.
  ///
  /// Use this for login/signup requests that don't need a token.
  static Dio createPublic() {
    return Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        contentType: Headers.jsonContentType,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }
}
