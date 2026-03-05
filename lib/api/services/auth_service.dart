/// Authentication service for handling user authentication operations.
///
/// This service provides methods for user login, signup, logout, and profile
/// retrieval. It integrates with the backend authentication API and manages
/// JWT token persistence through [StorageService].
///
/// ## Backend API Contract
///
/// The authentication endpoints are separate from the main API (`/api/v1`):
/// - **Login**: `POST /auth/login` - Returns JWT tokens
/// - **Register**: `POST /auth/register` - Creates new user account
/// - **Logout**: `POST /auth/logout` - Invalidates refresh token
/// - **Refresh**: `POST /auth/refresh` - Refreshes access token
/// - **Profile**: `GET /api/v1/account/me` - Requires authentication
///
/// ## Dependencies
///
/// - [Dio]: HTTP client for API requests
/// - [StorageService]: Secure storage for JWT token persistence
library;

import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import '../models/user_models.dart';
import 'storage_service.dart';
import '../config/constants.dart' as legacy_constants;

/// Service class that handles all authentication-related API operations.
class AuthService {
  final Dio _dio;
  final StorageService _storageService;

  AuthService({required Dio dio, required StorageService storageService})
    : _dio = dio,
      _storageService = storageService;

  /// Authenticates a user with username/email and password.
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '${legacy_constants.AppConstants.authBaseUrl}/auth/login',
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

  /// Registers a new user account.
  Future<void> signup(SignupRequest request) async {
    try {
      final response = await _dio.post(
        '${legacy_constants.AppConstants.authBaseUrl}/auth/register',
        data: request.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Registration successful - caller should proceed with login
      } else {
        throw Exception('Failed to create user');
      }
    } on DioException catch (e) {
      throw Exception('Signup error: ${e.response?.data ?? e.message}');
    }
  }

  /// Retrieves the authenticated user's profile via GET /api/v1/account/me.
  Future<AccountInfoResponse> getProfile() async {
    try {
      final response = await _dio.get('/account/me');
      return AccountInfoResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  /// Logs out the current user.
  ///
  /// Sends POST /auth/logout to invalidate the refresh token on the server,
  /// then clears local tokens.
  Future<void> logout() async {
    try {
      final token = await _storageService.getToken();
      if (token != null && token.isNotEmpty) {
        // Try to call the server logout endpoint
        try {
          await _dio.post(
            '${legacy_constants.AppConstants.authBaseUrl}/auth/logout',
          );
        } catch (_) {
          // Server logout is best-effort; always clear local tokens
        }
      }
    } finally {
      await _storageService.deleteToken();
    }
  }

  /// Refreshes the access token using the refresh token.
  Future<LoginResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '${legacy_constants.AppConstants.authBaseUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final loginResponse = LoginResponse.fromJson(response.data);
      if (loginResponse.token.isNotEmpty) {
        await _storageService.saveToken(loginResponse.token);
      }
      return loginResponse;
    } catch (e) {
      throw Exception('Token refresh failed: $e');
    }
  }
}
