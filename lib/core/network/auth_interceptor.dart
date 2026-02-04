/// Authentication interceptor for Dio HTTP client.
///
/// Automatically attaches JWT tokens to outgoing requests
/// and handles authentication errors.
library;

import 'package:dio/dio.dart';
import '../storage/storage_service.dart';

/// Dio interceptor that handles authentication token injection.
///
/// Automatically adds the Bearer token to all requests except
/// login and signup endpoints. Also handles 401/403 responses.
class AuthInterceptor extends Interceptor {
  final StorageService _storageService;

  /// Creates an AuthInterceptor with the given storage service.
  AuthInterceptor(this._storageService);

  /// Paths that should not have authentication headers added.
  static const List<String> _publicPaths = [
    '/auth/login',
    '/auth/signup',
    '/auth/refresh',
  ];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    final isPublicPath = _publicPaths.any(
      (path) => options.path.contains(path),
    );

    // Add client type header for breaking changes in latest stage
    options.headers['X-Client-Type'] = 'mobile';

    if (!isPublicPath) {
      final token = await _storageService.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle authentication errors
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      // Token might be expired or invalid
      // In a full implementation, we could:
      // 1. Try to refresh the token
      // 2. Clear the token and redirect to login
      // 3. Emit an event for the app to handle

      // For now, we just pass the error through
      // The UI layer will handle showing login
    }

    super.onError(err, handler);
  }
}
