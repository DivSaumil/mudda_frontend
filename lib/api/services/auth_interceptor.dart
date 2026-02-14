import 'package:dio/dio.dart';
import 'storage_service.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storageService;

  AuthInterceptor(this._storageService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['X-Client-Type'] = 'mobile';

    final token = await _storageService.getToken();
    if (token != null &&
        !options.path.contains('/auth/login') &&
        !options.path.contains('/auth/signup')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 403 || err.response?.statusCode == 401) {
      // Handle token expiration (e.g., logout user)
      // For now, we might just want to clear the token or notify the app
      // await _storageService.deleteToken();
    }
    super.onError(err, handler);
  }
}
