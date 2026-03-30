import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudda_frontend/features/auth/application/auth_notifier.dart';
import 'package:mudda_frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:mudda_frontend/features/auth/presentation/screens/signup_screen.dart';
import 'package:mudda_frontend/features/issues/presentation/screens/issue_feed_screen.dart';
import 'package:mudda_frontend/features/issues/presentation/screens/create_issue_screen.dart';
import 'package:mudda_frontend/features/activity/presentation/screens/activity_screen.dart';
import 'package:mudda_frontend/features/profile/presentation/screens/profile_screen.dart';
import 'package:mudda_frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:mudda_frontend/features/about/presentation/screens/about_us_screen.dart';
import 'package:mudda_frontend/features/issues/presentation/screens/issue_detail_screen.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/core/navigation/bottom_nav_shell.dart';
import 'package:mudda_frontend/features/community/domain/entities/community_models.dart';
import 'package:mudda_frontend/features/community/presentation/screens/initiative_detail_screen.dart';

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
  static const String initiativeDetail = '/initiative/:id';
  static const String dashboard = '/dashboard';
  static const String about = '/about';
}

/// Notifier to listen to auth state changes and trigger router refresh without rebuilding the GoRouter instance
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (_, __) {
      notifyListeners();
    });
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authNotifierProvider);

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
  }
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter provider
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: notifier.redirect,
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

      // About Us
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        builder: (context, state) => const AboutUsPage(),
      ),

      GoRoute(
        path: AppRoutes.issueDetail,
        name: 'issueDetail',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final issue = state.extra as IssueResponse?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: IssueDetailScreen(issueId: id, initialIssue: issue),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 350),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final slideTween =
                      Tween<Offset>(
                        begin: const Offset(1.0, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );
                  return SlideTransition(position: slideTween, child: child);
                },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.initiativeDetail,
        name: 'initiativeDetail',
        pageBuilder: (context, state) {
          final initiative = state.extra as CommunityInitiative;
          return CustomTransitionPage(
            key: state.pageKey,
            child: InitiativeDetailScreen(initiative: initiative),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 350),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final slideTween =
                      Tween<Offset>(
                        begin: const Offset(1.0, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );
                  return SlideTransition(position: slideTween, child: child);
                },
          );
        },
      ),
    ],
  );
});
