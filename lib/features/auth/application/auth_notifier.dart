/// Authentication notifier using Riverpod.
///
/// Manages authentication state and provides methods for
/// login, signup, logout, and checking auth status.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/di/providers.dart';
// Use existing services for compatibility during migration
import '../../../api/services/storage_service.dart';
import '../../../api/services/auth_service.dart';
import '../../../api/models/auth_models.dart';
import 'auth_state.dart';

part 'auth_notifier.g.dart';

/// Riverpod notifier that manages authentication state.
///
/// Provides methods for:
/// - Checking if user is authenticated
/// - Login with username/password
/// - Signup with user details
/// - Logout and token clearing
@riverpod
class AuthNotifier extends _$AuthNotifier {
  late StorageService _storage;
  late AuthService _authService;

  @override
  FutureOr<AuthState> build() async {
    _storage = ref.watch(storageServiceProvider);

    // Get Dio and create AuthService
    final dio = ref.watch(dioProvider);
    _authService = AuthService(dio: dio, storageService: _storage);

    // Check if we have a stored token
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      return AuthState.authenticated(token: token);
    }

    return const AuthState.unauthenticated();
  }

  /// Attempts to log in with the given credentials.
  ///
  /// [username] The user's username or email.
  /// [password] The user's password.
  ///
  /// Updates state to authenticated on success, or error on failure.
  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();

    try {
      final response = await _authService.login(
        LoginRequest(username: username, password: password),
      );

      state = AsyncValue.data(
        AuthState.authenticated(token: response.token, username: username),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Registers a new user with the provided details.
  ///
  /// On success, automatically logs in the user.
  Future<void> signup({
    required String userName,
    required String name,
    required String email,
    required String dateOfBirth,
    required String phoneNumber,
    required String password,
    String? profileImageUrl,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _authService.signup(
        SignupRequest(
          userName: userName,
          name: name,
          email: email,
          dateOfBirth: dateOfBirth,
          phoneNumber: phoneNumber,
          password: password,
          profileImageUrl: profileImageUrl,
        ),
      );

      // After signup, log the user in
      await login(userName, password);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Logs out the current user.
  ///
  /// Clears the stored token and updates state to unauthenticated.
  Future<void> logout() async {
    state = const AsyncValue.loading();

    try {
      await _authService.logout();
      state = const AsyncValue.data(AuthState.unauthenticated());
    } catch (e) {
      // Even if logout fails, clear local state
      debugPrint('Logout error: $e');
      state = const AsyncValue.data(AuthState.unauthenticated());
    }
  }

  /// Checks if the user is currently authenticated.
  bool get isAuthenticated {
    return state.when(
      data: (authState) => authState is AuthStateAuthenticated,
      loading: () => false,
      error: (_, __) => false,
    );
  }
}
