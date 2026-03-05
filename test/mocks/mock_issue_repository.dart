import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/api/repositories/issue_repository.dart';
import 'package:mudda_frontend/api/services/issue_service.dart';
import 'package:mudda_frontend/api/services/issue_cache_service.dart';

/// Mock implementation of IssueRepository for testing.
class MockIssueRepository implements IssueRepository {
  final List<IssueResponse> _mockIssues = [];
  bool shouldThrow = false;
  String errorMessage = 'Mock error';

  MockIssueRepository() {
    // Initialize with sample data
    _mockIssues.addAll([
      IssueResponse(
        id: 1,
        title: 'Test Issue 1',
        description: 'Description 1',
        status: 'OPEN',
        voteCount: 10,
        hasUserVoted: false,
        canUserVote: true,
        authorName: 'user1',
        authorImageUrl: '',
        createdAt: DateTime.now().toIso8601String(),
        mediaUrls: [],
      ),
      IssueResponse(
        id: 2,
        title: 'Test Issue 2',
        description: 'Description 2',
        status: 'PENDING',
        voteCount: 25,
        hasUserVoted: true,
        canUserVote: true,
        authorName: 'user2',
        authorImageUrl: '',
        createdAt: DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        mediaUrls: ['https://example.com/image.jpg'],
      ),
    ]);
  }

  @override
  IssueService get service => throw UnimplementedError();

  @override
  IssueCacheService get cacheService => throw UnimplementedError();

  @override
  Future<FetchIssuesResult> fetchIssues({
    IssueFilterRequest? filter,
    String? category,
    int page = 0,
    int size = 20,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);

    await Future.delayed(const Duration(milliseconds: 100));

    var filtered = _mockIssues.toList();
    if (filter != null) {
      if (filter.status != null) {
        filtered = filtered.where((i) => i.status == filter.status).toList();
      }
    }

    if (category != null && category.isNotEmpty && category != 'All') {
      // filter by category if possible
    }

    final start = page * size;
    final end = (start + size).clamp(0, filtered.length);
    if (start >= filtered.length) return FetchIssuesResult(issues: []);

    return FetchIssuesResult(issues: filtered.sublist(start, end));
  }

  @override
  Future<IssueResponse> getIssue(int id) async {
    if (shouldThrow) throw Exception(errorMessage);

    await Future.delayed(const Duration(milliseconds: 50));
    return _mockIssues.firstWhere(
      (i) => i.id == id,
      orElse: () => throw Exception('Issue not found'),
    );
  }

  @override
  Future<IssueResponse> createIssue(CreateIssueRequest request) async {
    if (shouldThrow) throw Exception(errorMessage);

    await Future.delayed(const Duration(milliseconds: 100));
    final newIssue = IssueResponse(
      id: _mockIssues.length + 1,
      title: request.title,
      description: request.description,
      status: 'PENDING', // Default status
      voteCount: 0,
      hasUserVoted: false,
      canUserVote: true,
      authorName: 'testuser',
      authorImageUrl: '',
      createdAt: DateTime.now().toIso8601String(),
      mediaUrls: request.mediaUrls,
    );
    _mockIssues.add(newIssue);
    return newIssue;
  }

  @override
  Future<IssueResponse> updateIssue(int id, UpdateIssueRequest request) async {
    if (shouldThrow) throw Exception(errorMessage);

    final index = _mockIssues.indexWhere((i) => i.id == id);
    if (index == -1) throw Exception('Issue not found');

    // Return the same issue (simplified mock) - normally we'd update it
    return _mockIssues[index];
  }

  @override
  Future<void> deleteIssue(int id) async {
    if (shouldThrow) throw Exception(errorMessage);
    _mockIssues.removeWhere((i) => i.id == id);
  }

  @override
  Future<IssueClusterResponse> getClusters(int k) async {
    if (shouldThrow) throw Exception(errorMessage);
    return IssueClusterResponse(clusteredIssues: _mockIssues);
  }

  /// Adds a mock issue for testing.
  void addMockIssue(IssueResponse issue) {
    _mockIssues.add(issue);
  }

  /// Clears all mock issues.
  void clear() {
    _mockIssues.clear();
  }
}
