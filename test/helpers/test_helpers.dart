// Test helpers and utilities
// Common setup functions for widget and integration tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:mudda_frontend/api/services/storage_service.dart';
import 'package:mudda_frontend/api/services/auth_service.dart';
import 'package:mudda_frontend/api/services/issue_service.dart';
import 'package:mudda_frontend/api/services/vote_service.dart';
import 'package:mudda_frontend/api/services/comment_service.dart';
import 'package:mudda_frontend/api/config/constants.dart';
import 'package:mudda_frontend/core/di/providers.dart';

import '../mocks/mock_services.dart';

/// Extension to easily pump widgets with all required providers
extension PumpApp on WidgetTester {
  /// Pump a widget wrapped with Riverpod ProviderScope for testing
  ///
  /// Example:
  /// ```dart
  /// await tester.pumpApp(
  ///   storageService: mockStorage,
  ///   child: const LoginScreen(),
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
    List<Override>? overrides,
  }) async {
    final storage = storageService ?? MockStorageService();
    final allOverrides = <Override>[
      storageServiceProvider.overrideWithValue(storage),
      if (authService != null)
        authServiceProvider.overrideWithValue(authService),
      if (issueService != null)
        issueServiceProvider.overrideWithValue(issueService),
      if (voteService != null)
        voteServiceProvider.overrideWithValue(voteService),
      if (commentService != null)
        commentServiceProvider.overrideWithValue(commentService),
      ...?overrides,
    ];

    await pumpWidget(
      ProviderScope(
        overrides: allOverrides,
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
