import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/api/services/issue_cache_service.dart';

void main() {
  late IssueCacheService cacheService;

  final testIssue1 = IssueResponse(
    id: 1,
    title: 'Test Issue 1',
    description: 'Description 1',
    status: 'OPEN',
    voteCount: 10,
    hasUserVoted: false,
    canUserVote: true,
    authorName: 'user1',
    authorImageUrl: '',
    createdAt: '2024-01-01T00:00:00Z',
    mediaUrls: ['https://example.com/img1.jpg'],
  );

  final testIssue2 = IssueResponse(
    id: 2,
    title: 'Test Issue 2',
    description: 'Description 2',
    status: 'PENDING',
    voteCount: 25,
    hasUserVoted: true,
    canUserVote: true,
    authorName: 'user2',
    authorImageUrl: '',
    createdAt: '2024-01-02T00:00:00Z',
    mediaUrls: [],
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    cacheService = IssueCacheService();
  });

  group('IssueCacheService - Issue List Caching', () {
    test('cacheIssues and getCachedIssues round-trip works', () async {
      final issues = [testIssue1, testIssue2];

      await cacheService.cacheIssues(issues, category: 'All');
      final cached = await cacheService.getCachedIssues(category: 'All');

      expect(cached, isNotNull);
      expect(cached!.length, 2);
      expect(cached[0].id, 1);
      expect(cached[0].title, 'Test Issue 1');
      expect(cached[0].mediaUrls, ['https://example.com/img1.jpg']);
      expect(cached[1].id, 2);
      expect(cached[1].title, 'Test Issue 2');
      expect(cached[1].authorName, 'user2');
    });

    test('getCachedIssues returns null when no cache exists', () async {
      final cached = await cacheService.getCachedIssues(category: 'Safety');
      expect(cached, isNull);
    });

    test('caches are separated by category', () async {
      await cacheService.cacheIssues([testIssue1], category: 'All');
      await cacheService.cacheIssues([testIssue2], category: 'Safety');

      final allCached = await cacheService.getCachedIssues(category: 'All');
      final safetyCached = await cacheService.getCachedIssues(
        category: 'Safety',
      );

      expect(allCached!.length, 1);
      expect(allCached[0].id, 1);
      expect(safetyCached!.length, 1);
      expect(safetyCached[0].id, 2);
    });
  });

  group('IssueCacheService - Issue Detail Caching', () {
    test(
      'cacheIssueDetail and getCachedIssueDetail round-trip works',
      () async {
        await cacheService.cacheIssueDetail(testIssue1);
        final cached = await cacheService.getCachedIssueDetail(1);

        expect(cached, isNotNull);
        expect(cached!.id, 1);
        expect(cached.title, 'Test Issue 1');
        expect(cached.description, 'Description 1');
        expect(cached.voteCount, 10);
      },
    );

    test('getCachedIssueDetail returns null for non-cached id', () async {
      final cached = await cacheService.getCachedIssueDetail(999);
      expect(cached, isNull);
    });
  });

  group('IssueCacheService - clearCache', () {
    test('clearCache removes all cached issue data', () async {
      await cacheService.cacheIssues([testIssue1, testIssue2]);
      await cacheService.cacheIssueDetail(testIssue1);

      await cacheService.clearCache();

      final listCached = await cacheService.getCachedIssues();
      final detailCached = await cacheService.getCachedIssueDetail(1);

      expect(listCached, isNull);
      expect(detailCached, isNull);
    });
  });
}
