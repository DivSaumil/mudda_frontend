import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:mudda_frontend/core/navigation/app_router.dart';

/// Centralized service for handling Push Notifications.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification service.
  /// Note: Firebase.initializeApp() should be called before this.
  Future<void> initialize() async {
    try {
      await _requestPermissions();
      await _setupLocalNotifications();
      _setupForegroundMessageListener();
      _setupBackgroundMessageListener();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  /// Requests notification permissions from the user.
  Future<void> _requestPermissions() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('User granted permission: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
  }

  /// Configures flutter_local_notifications for foreground display.
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // For iOS, further setup is needed if we were actually testing on iOS.
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create a high importance channel for Android Heads-up notifications.
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Handle Notification tap when app is in foreground.
  void _onNotificationTap(NotificationResponse response) {
    debugPrint(
      'Foreground notification tapped with payload: ${response.payload}',
    );
    // Routing using rootNavigatorKey
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;
    
    // Stub logic for routing:
    // We assume payload is JSON but keep it simple string matching for now
    final payload = response.payload ?? '';
    if (payload.contains('community_announcement')) {
         // Assuming Dashboard uses Neighborhood tab as index 1, or just go to home for now
         // Given "global" vs "neighborhood" is governed by TabController in IssueFeedScreen,
         // We might just route to home which maintains the state. 
         context.go(AppRoutes.home);
         debugPrint('Routed to Home / Community Hub (Announcement)');
    } else if (payload.contains('mention')) {
         // Typical mention routes to the specific issue
         // e.g. context.go('/issue/123')
         debugPrint('Route to specific issue comment thread (Mention)');
    }
  }

  /// Sets up the listener for messages when the app is in the foreground.
  void _setupForegroundMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification}',
        );
        _showLocalNotification(message);
      }
    });
  }

  void _setupBackgroundMessageListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      
      final context = rootNavigatorKey.currentContext;
      if (context == null) return;

      if (message.data['type'] == 'community_announcement') {
        context.go(AppRoutes.home);
        debugPrint('Routed to Home / Community Hub for announcement');
      } else if (message.data['type'] == 'mention') {
        debugPrint('Route to specific issue comment thread (Mention)');
      }
    });
  }

  /// Displays a local notification using the `flutter_local_notifications` plugin.
  // ignore: unused_element
  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null && !kIsWeb) {
      await _localNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data.toString(), // Pass data for routing
      );
    }
  }

  /// Fetches the FCM Device Token.
  /// Used primarily during signup based on current backend constraints.
  Future<String?> getDeviceToken() async {
    try {
      String? token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }
}

/// Top-level background message handler.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
  
  // Stub for Community/Social background processing
  if (message.data['type'] == 'community_announcement') {
    debugPrint('Stub: Processing background community announcement');
  } else if (message.data['type'] == 'mention') {
    debugPrint('Stub: Processing background @mention logic');
  }
}
