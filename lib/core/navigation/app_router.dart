import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudda_frontend/features/auth/application/auth_notifier.dart';
import 'package:mudda_frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:mudda_frontend/features/auth/presentation/screens/signup_screen.dart';
import 'package:mudda_frontend/features/issues/presentation/screens/issue_feed_screen.dart';
import 'package:mudda_frontend/pages/createPost.dart';
import 'package:mudda_frontend/pages/ActivityPage.dart';
import 'package:mudda_frontend/pages/ProfilePage.dart';
import 'package:mudda_frontend/pages/DashboardPage.dart';
import 'package:mudda_frontend/core/navigation/bottom_nav_shell.dart';

/// Route paths
class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/';
  static const String search = '/search';
  static const String create = '/create';
  static const String activity = '/activity';
  static const String profile = '/profile';
  static const String issueDetail = '/issue/:id';
  static const String dashboard = '/dashboard';
}

/// GoRouter provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.maybeWhen(
        data: (auth) =>
            auth.maybeMap(authenticated: (_) => true, orElse: () => false),
        orElse: () => false,
      );

      final isAuthRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;

      // Not logged in and not on auth route -> redirect to login
      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }

      // Logged in and on auth route -> redirect to home
      if (isLoggedIn && isAuthRoute) {
        return AppRoutes.home;
      }

      return null; // No redirect
    },
    routes: [
      // Auth routes (no shell)
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // Main app with bottom navigation shell
      ShellRoute(
        builder: (context, state, child) => BottomNavShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const IssueFeedScreen(),
          ),
          GoRoute(
            path: AppRoutes.search,
            name: 'search',
            builder: (context, state) =>
                const Center(child: Text('Search - Coming Soon')),
          ),
          GoRoute(
            path: AppRoutes.create,
            name: 'create',
            builder: (context, state) => const CreateIssuePage(),
          ),
          GoRoute(
            path: AppRoutes.activity,
            name: 'activity',
            builder: (context, state) => const AccountActivityPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),

      // Dashboard (outside shell)
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
    ],
  );
});
