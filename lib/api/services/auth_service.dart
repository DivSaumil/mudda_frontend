import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import 'storage_service.dart';
import '../config/constants.dart' as legacy_constants;

class AuthService {
  final Dio _dio;
  final StorageService _storageService;

  AuthService({required Dio dio, required StorageService storageService})
    : _dio = dio,
      _storageService = storageService;

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      // Auth endpoints are NOT under `/api/v1` in the new API contract.
      // Use an absolute URL so we don't depend on the Dio baseUrl (which is `/api/v1`).
      final response = await _dio.post(
        '${legacy_constants.AppConstants.baseUrl}/auth/login',
        data: request.toJson(),
      );
      final loginResponse = LoginResponse.fromJson(response.data);
      if (loginResponse.token.isNotEmpty) {
        await _storageService.saveToken(loginResponse.token);
      }
      return loginResponse;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> signup(SignupRequest request) async {
    try {
      // New API uses `/auth/register` and returns MessageResponse.
      final response = await _dio.post(
        '${legacy_constants.AppConstants.baseUrl}/auth/register',
        data: request.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Handle success
      } else {
        throw Exception('Failed to create user');
      }
    } on DioException catch (e) {
      throw Exception('Signup error: ${e.response?.data ?? e.message}');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
  }
}
