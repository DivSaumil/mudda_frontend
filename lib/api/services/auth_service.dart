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
/// - **Profile**: `GET /api/v1/users/profile` - Requires authentication
///
/// ## Dependencies
///
/// - [Dio]: HTTP client for API requests
/// - [StorageService]: Secure storage for JWT token persistence
///
/// ## Usage Example
///
/// ```dart
/// final authService = AuthService(dio: dio, storageService: storage);
///
/// // Login
/// final response = await authService.login(
///   LoginRequest(username: 'user', password: 'pass'),
/// );
///
/// // Logout
/// await authService.logout();
/// ```
///
/// ## Error Handling
///
/// All methods throw [Exception] with descriptive messages on failure.
/// The caller should handle these exceptions appropriately (e.g., show
/// error snackbar in UI).
library;

import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import 'storage_service.dart';
import '../config/constants.dart' as legacy_constants;

/// Service class that handles all authentication-related API operations.
///
/// This class is typically provided via dependency injection (Provider or
/// Riverpod) and should be used through [AuthNotifier] for state management.
class AuthService {
  final Dio _dio;
  final StorageService _storageService;

  /// Creates an [AuthService] instance.
  ///
  /// [dio] - Pre-configured Dio instance (with interceptors if needed)
  /// [storageService] - Service for secure token storage
  AuthService({required Dio dio, required StorageService storageService})
    : _dio = dio,
      _storageService = storageService;

  /// Authenticates a user with username/email and password.
  ///
  /// Sends credentials to `/auth/login` endpoint and stores the returned
  /// JWT access token in secure storage for subsequent authenticated requests.
  ///
  /// [request] - Contains username (or email) and password
  ///
  /// Returns [LoginResponse] containing:
  /// - `accessToken`: JWT for API authentication
  /// - `refreshToken`: Token for refreshing expired access tokens
  /// - `user`: Optional user profile data
  ///
  /// Throws [Exception] if:
  /// - Network request fails
  /// - Invalid credentials (401 Unauthorized)
  /// - Server error (5xx)
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

  /// Registers a new user account.
  ///
  /// Sends user details to `/auth/register` endpoint. On success, the user
  /// should be prompted to log in (or auto-logged in by the caller).
  ///
  /// [request] - Contains all required registration fields:
  /// - `userName`: Unique username
  /// - `name`: Display name
  /// - `email`: Email address
  /// - `dateOfBirth`: Format YYYY-MM-DD
  /// - `phoneNumber`: With country code
  /// - `password`: Minimum 6 characters
  /// - `role`: Default is CITIZEN
  ///
  /// Throws [Exception] if:
  /// - Email or username already exists (400)
  /// - Validation errors
  /// - Network/server errors
  Future<void> signup(SignupRequest request) async {
    try {
      // New API uses `/auth/register` and returns MessageResponse.
      final response = await _dio.post(
        '${legacy_constants.AppConstants.baseUrl}/auth/register',
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

  /// Retrieves the authenticated user's profile.
  ///
  /// Requires a valid JWT token in storage (added to request via
  /// [AuthInterceptor]).
  ///
  /// Returns a map containing user profile fields:
  /// - `id`, `userName`, `name`, `email`, `phoneNumber`, etc.
  ///
  /// Throws [Exception] if:
  /// - Not authenticated (401)
  /// - Token expired (401/403)
  /// - Network/server errors
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  /// Logs out the current user by clearing stored tokens.
  ///
  /// This is a local operation only - it does not call a backend logout
  /// endpoint. The JWT will still be valid on the server until it expires.
  ///
  /// After calling this method, subsequent authenticated API calls will
  /// fail with 401 until the user logs in again.
  Future<void> logout() async {
    await _storageService.deleteToken();
  }
}
