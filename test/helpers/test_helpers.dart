// Test helpers and utilities
// Common setup functions for widget and integration tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:mudda_frontend/api/services/storage_service.dart';
import 'package:mudda_frontend/api/services/auth_service.dart';
import 'package:mudda_frontend/api/services/issue_service.dart';
import 'package:mudda_frontend/api/services/vote_service.dart';
import 'package:mudda_frontend/api/services/comment_service.dart';
import 'package:mudda_frontend/api/services/auth_interceptor.dart';
import 'package:mudda_frontend/api/config/constants.dart';

import '../mocks/mock_services.dart';

/// Extension to easily pump widgets with all required providers
extension PumpApp on WidgetTester {
  /// Pump a widget wrapped with all necessary providers for testing
  ///
  /// Example:
  /// ```dart
  /// await tester.pumpApp(
  ///   storageService: mockStorage,
  ///   child: const LoginPage(),
  /// );
  /// ```
  Future<void> pumpApp({
    StorageService? storageService,
    AuthService? authService,
    IssueService? issueService,
    VoteService? voteService,
    CommentService? commentService,
    Widget? child,
    ThemeData? theme,
  }) async {
    final storage = storageService ?? MockStorageService();

    await pumpWidget(
      MultiProvider(
        providers: [
          Provider<StorageService>.value(value: storage),
          if (authService != null)
            Provider<AuthService>.value(value: authService),
          if (issueService != null)
            Provider<IssueService>.value(value: issueService),
          if (voteService != null)
            Provider<VoteService>.value(value: voteService),
          if (commentService != null)
            Provider<CommentService>.value(value: commentService),
        ],
        child: MaterialApp(
          theme: theme ?? ThemeData.light(),
          home: child ?? const Scaffold(body: Text('Test')),
        ),
      ),
    );
  }
}

/// Creates a mock Dio instance for testing HTTP calls
Dio createTestDio() {
  return Dio(
    BaseOptions(
      baseUrl: '${AppConstants.baseUrl}/api/v1',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );
}

/// Widget wrapper for testing with theme
Widget testableWidget({required Widget child, ThemeData? theme}) {
  return MaterialApp(theme: theme ?? ThemeData.light(), home: child);
}

/// Finds a widget by key and text content
Finder findByKeyAndText(Key key, String text) {
  return find.descendant(of: find.byKey(key), matching: find.text(text));
}

/// Waits for all animations to complete
Future<void> settleAllAnimations(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}
