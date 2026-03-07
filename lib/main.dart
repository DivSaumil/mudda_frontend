import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// New router
import 'package:mudda_frontend/core/navigation/app_router.dart';
import 'package:mudda_frontend/shared/theme/app_theme.dart';
import 'package:mudda_frontend/shared/theme/theme_controller.dart';
import 'package:mudda_frontend/core/notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Register background handler for FCM
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize notifications
  await NotificationService().initialize();

  runApp(const ProviderScope(child: MuddaApp()));
}

/// Main app widget using GoRouter
class MuddaApp extends ConsumerWidget {
  const MuddaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'Mudda',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
