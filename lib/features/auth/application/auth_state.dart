/// Authentication state definitions.
///
/// Represents the possible states of the authentication flow.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// Represents the authentication state of the app.
///
/// Uses Freezed for immutable state with union types.
@freezed
sealed class AuthState with _$AuthState {
  /// Initial state while checking authentication
  const factory AuthState.initial() = AuthStateInitial;

  /// Loading state during auth operations
  const factory AuthState.loading() = AuthStateLoading;

  /// User is authenticated with a token
  const factory AuthState.authenticated({
    required String token,
    String? username,
    String? email,
  }) = AuthStateAuthenticated;

  /// User is not authenticated
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;

  /// Authentication error occurred
  const factory AuthState.error({required String message}) = AuthStateError;
}
