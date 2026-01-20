/// Authentication gate widget using Riverpod.
///
/// Checks authentication status and shows either the login screen
/// or the main app screen based on the user's auth state.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/auth_notifier.dart';
import '../../application/auth_state.dart';
import '../screens/login_screen.dart';

/// Widget that guards the app based on authentication state.
///
/// Shows:
/// - Loading indicator while checking auth status
/// - Login screen if not authenticated
/// - Main app if authenticated
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key, required this.authenticatedBuilder});

  /// Builder for the authenticated state.
  /// Called when the user is logged in with a valid token.
  final Widget Function(BuildContext context) authenticatedBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      data: (state) {
        return switch (state) {
          AuthStateInitial() => _buildLoading(),
          AuthStateLoading() => _buildLoading(),
          AuthStateAuthenticated() => authenticatedBuilder(context),
          AuthStateUnauthenticated() => const LoginScreen(),
          AuthStateError(:final message) => _buildError(context, ref, message),
        };
      },
      loading: () => _buildLoading(),
      error: (error, _) => _buildError(context, ref, error.toString()),
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String message) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Authentication Error',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(authNotifierProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
