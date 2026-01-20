import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudda_frontend/features/auth/presentation/widgets/auth_gate.dart';
import 'package:mudda_frontend/features/auth/application/auth_notifier.dart';
import 'package:mudda_frontend/features/auth/application/auth_state.dart';

void main() {
  group('AuthGate Widget Tests', () {
    testWidgets('shows loading indicator when auth state is loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(() => _MockLoadingAuthNotifier()),
          ],
          child: const MaterialApp(
            home: AuthGate(authenticatedBuilder: _buildAuthenticated),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows authenticated content when logged in', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(
              () => _MockAuthenticatedAuthNotifier(),
            ),
          ],
          child: const MaterialApp(
            home: AuthGate(authenticatedBuilder: _buildAuthenticated),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Authenticated!'), findsOneWidget);
    });
  });
}

Widget _buildAuthenticated(BuildContext context) {
  return const Scaffold(body: Center(child: Text('Authenticated!')));
}

class _MockLoadingAuthNotifier extends AuthNotifier {
  @override
  Future<AuthState> build() async {
    // Return loading by not completing immediately
    return const AuthState.unauthenticated();
  }
}

class _MockAuthenticatedAuthNotifier extends AuthNotifier {
  @override
  Future<AuthState> build() async {
    return const AuthState.authenticated(token: 'mock-token');
  }
}
