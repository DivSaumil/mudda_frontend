import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import 'storage_service.dart';

class AuthService {
  final Dio _dio;
  final StorageService _storageService;

  AuthService({required Dio dio, required StorageService storageService})
    : _dio = dio,
      _storageService = storageService;

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/auth/login', data: request.toJson());
      final loginResponse = LoginResponse.fromJson(response.data);
      await _storageService.saveToken(loginResponse.token);
      return loginResponse;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> signup(SignupRequest request) async {
    try {
      final response = await _dio.post('/auth/signup', data: request.toJson());

      if (response.statusCode == 201) {
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
