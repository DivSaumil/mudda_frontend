// Unit tests for IssueService
// These tests lock in existing behavior by testing the service logic
// Note: Some tests use simpler mocking due to http_mock_adapter limitations

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mudda_frontend/api/services/issue_service.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late IssueService issueService;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.api/api/v1'));
    dioAdapter = DioAdapter(dio: dio, matcher: const FullHttpRequestMatcher());
    issueService = IssueService(dio);
  });

  group('IssueService.getIssueById', () {
    test('returns IssueResponse on success', () async {
      final issueData = {
        'id': 1,
        'title': 'Test Issue',
        'content': 'Test content',
        'media_urls': ['https://example.com/img.jpg'],
        'vote_count': 10,
        'status': 'PENDING',
        'created_at': '2024-01-01T00:00:00Z',
        'has_user_voted': false,
        'can_user_vote': true,
        'username': 'testuser',
      };
      dioAdapter.onGet('/issues/1', (server) => server.reply(200, issueData));

      final result = await issueService.getIssueById(1);

      expect(result.id, 1);
      expect(result.title, 'Test Issue');
      expect(result.content, 'Test content');
      expect(result.voteCount, 10);
      expect(result.username, 'testuser');
    });

    test('throws exception on 404', () async {
      dioAdapter.onGet(
        '/issues/999',
        (server) => server.throws(
          404,
          DioException(
            requestOptions: RequestOptions(path: '/issues/999'),
            type: DioExceptionType.badResponse,
          ),
        ),
      );

      expect(() => issueService.getIssueById(999), throwsA(isA<Exception>()));
    });
  });

  group('IssueService.deleteIssue', () {
    test('completes successfully on 204', () async {
      dioAdapter.onDelete('/issues/1', (server) => server.reply(204, null));

      await expectLater(issueService.deleteIssue(1), completes);
    });

    test('throws exception on 404', () async {
      dioAdapter.onDelete(
        '/issues/999',
        (server) => server.throws(
          404,
          DioException(
            requestOptions: RequestOptions(path: '/issues/999'),
            type: DioExceptionType.badResponse,
          ),
        ),
      );

      expect(() => issueService.deleteIssue(999), throwsA(isA<Exception>()));
    });
  });

  // Note: Tests for getAllIssues, createIssue, updateIssue are simplified
  // due to http_mock_adapter's strict URL matching with query params.
  // These will be better tested after migration to Riverpod with proper DI.
}
