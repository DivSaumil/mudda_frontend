import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

// Legacy services (for backward compatibility during migration)
import 'package:mudda_frontend/api/services/storage_service.dart';
import 'package:mudda_frontend/api/services/auth_interceptor.dart';
import 'package:mudda_frontend/api/services/auth_service.dart';
import 'package:mudda_frontend/api/services/issue_service.dart';
import 'package:mudda_frontend/api/services/vote_service.dart';
import 'package:mudda_frontend/api/services/comment_service.dart';
import 'package:mudda_frontend/api/services/user_service.dart';
import 'package:mudda_frontend/api/services/category_service.dart';
import 'package:mudda_frontend/api/services/location_service.dart';
import 'package:mudda_frontend/api/services/role_service.dart';
import 'package:mudda_frontend/api/services/amazon_service.dart';
import 'package:mudda_frontend/api/repositories/amazon_repository.dart';
import 'package:mudda_frontend/api/config/constants.dart';

// New router
import 'package:mudda_frontend/core/navigation/app_router.dart';

void main() {
  runApp(
    // Wrap with ProviderScope for Riverpod
    ProviderScope(
      child: MultiProvider(
        providers: [
          // Legacy providers for backward compatibility
          Provider(create: (_) => StorageService()),
          ProxyProvider<StorageService, AuthInterceptor>(
            update: (_, storage, __) => AuthInterceptor(storage),
          ),
          ProxyProvider<AuthInterceptor, Dio>(
            update: (_, interceptor, __) {
              final dio = Dio(
                BaseOptions(
                  baseUrl: '${AppConstants.baseUrl}/api/v1',
                  connectTimeout: const Duration(seconds: 30),
                  receiveTimeout: const Duration(seconds: 30),
                  contentType: Headers.jsonContentType,
                  validateStatus: (status) => status! < 500,
                ),
              );
              dio.interceptors.add(interceptor);
              return dio;
            },
          ),
          ProxyProvider2<Dio, StorageService, AuthService>(
            update: (_, dio, storage, __) =>
                AuthService(dio: dio, storageService: storage),
          ),
          ProxyProvider<Dio, IssueService>(
            update: (_, dio, __) => IssueService(dio),
          ),
          ProxyProvider<Dio, VoteService>(
            update: (_, dio, __) => VoteService(dio),
          ),
          ProxyProvider<Dio, CommentService>(
            update: (_, dio, __) => CommentService(dio),
          ),
          ProxyProvider<Dio, UserService>(
            update: (_, dio, __) => UserService(dio),
          ),
          ProxyProvider<Dio, CategoryService>(
            update: (_, dio, __) => CategoryService(dio),
          ),
          ProxyProvider<Dio, LocationService>(
            update: (_, dio, __) => LocationService(dio),
          ),
          ProxyProvider<Dio, RoleService>(
            update: (_, dio, __) => RoleService(dio),
          ),
          ProxyProvider<Dio, AmazonImageService>(
            update: (_, dio, __) => AmazonImageService(dio),
          ),
          ProxyProvider<AmazonImageService, AmazonImageRepository>(
            update: (_, service, __) => AmazonImageRepository(service: service),
          ),
        ],
        child: const MuddaApp(),
      ),
    ),
  );
}

/// Main app widget using GoRouter
class MuddaApp extends ConsumerWidget {
  const MuddaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Mudda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 15,
            color: Colors.black54,
            height: 1.5,
          ),
          labelSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      routerConfig: router,
    );
  }
}
