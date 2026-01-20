import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/features/issues/presentation/widgets/issue_card.dart';

void main() {
  group('IssueCard Widget Tests', () {
    late IssueResponse mockIssue;

    setUp(() {
      mockIssue = IssueResponse(
        id: 1,
        title: 'Test Issue Title',
        content: 'This is a test issue description',
        fullContent: 'This is a test issue description',
        status: 'OPEN',
        voteCount: 42,
        comments: 5,
        hasUserVoted: false,
        canUserVote: true,
        username: 'testuser',
        createdAt: DateTime.now().toIso8601String(),
        mediaUrls: [],
      );
    });

    // Helper to wrap widget with necessary providers and suppress image errors
    Widget buildTestableWidget(Widget child) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // This suppresses network image errors in tests
                return child;
              },
            ),
          ),
        ),
      );
    }

    testWidgets('renders issue title correctly', (tester) async {
      // Suppress image errors in tests
      final originalHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains(
          'NetworkImageLoadException',
        )) {
          return; // Ignore network image errors
        }
        originalHandler?.call(details);
      };

      await tester.pumpWidget(
        buildTestableWidget(IssueCard(issue: mockIssue, onTap: (_) {})),
      );

      expect(find.text('Test Issue Title'), findsOneWidget);

      FlutterError.onError = originalHandler;
    });

    testWidgets('renders issue content correctly', (tester) async {
      final originalHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains(
          'NetworkImageLoadException',
        )) {
          return;
        }
        originalHandler?.call(details);
      };

      await tester.pumpWidget(
        buildTestableWidget(IssueCard(issue: mockIssue, onTap: (_) {})),
      );

      expect(find.text('This is a test issue description'), findsOneWidget);

      FlutterError.onError = originalHandler;
    });

    testWidgets('renders vote count correctly', (tester) async {
      final originalHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains(
          'NetworkImageLoadException',
        )) {
          return;
        }
        originalHandler?.call(details);
      };

      await tester.pumpWidget(
        buildTestableWidget(IssueCard(issue: mockIssue, onTap: (_) {})),
      );

      expect(find.text('42'), findsOneWidget);

      FlutterError.onError = originalHandler;
    });

    testWidgets('renders username correctly', (tester) async {
      final originalHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains(
          'NetworkImageLoadException',
        )) {
          return;
        }
        originalHandler?.call(details);
      };

      await tester.pumpWidget(
        buildTestableWidget(IssueCard(issue: mockIssue, onTap: (_) {})),
      );

      expect(find.text('testuser'), findsOneWidget);

      FlutterError.onError = originalHandler;
    });

    testWidgets('renders OPEN status badge', (tester) async {
      final originalHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains(
          'NetworkImageLoadException',
        )) {
          return;
        }
        originalHandler?.call(details);
      };

      await tester.pumpWidget(
        buildTestableWidget(IssueCard(issue: mockIssue, onTap: (_) {})),
      );

      expect(find.text('OPEN'), findsOneWidget);

      FlutterError.onError = originalHandler;
    });

    testWidgets('shows unvoted icon when hasUserVoted is false', (
      tester,
    ) async {
      final originalHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains(
          'NetworkImageLoadException',
        )) {
          return;
        }
        originalHandler?.call(details);
      };

      await tester.pumpWidget(
        buildTestableWidget(IssueCard(issue: mockIssue, onTap: (_) {})),
      );

      expect(find.byIcon(Icons.pan_tool_outlined), findsOneWidget);

      FlutterError.onError = originalHandler;
    });

    testWidgets('shows voted icon when hasUserVoted is true', (tester) async {
      final originalHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains(
          'NetworkImageLoadException',
        )) {
          return;
        }
        originalHandler?.call(details);
      };

      final votedIssue = IssueResponse(
        id: 1,
        title: 'Test Issue',
        content: 'Content',
        fullContent: 'Content',
        status: 'OPEN',
        voteCount: 43,
        comments: 5,
        hasUserVoted: true,
        canUserVote: true,
        username: 'testuser',
        createdAt: DateTime.now().toIso8601String(),
        mediaUrls: [],
      );

      await tester.pumpWidget(
        buildTestableWidget(IssueCard(issue: votedIssue, onTap: (_) {})),
      );

      expect(find.byIcon(Icons.pan_tool), findsOneWidget);

      FlutterError.onError = originalHandler;
    });
  });
}
