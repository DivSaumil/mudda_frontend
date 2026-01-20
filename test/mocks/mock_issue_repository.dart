import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/core/repositories/i_issue_repository.dart';

/// Mock implementation of IIssueRepository for testing.
class MockIssueRepository implements IIssueRepository {
  final List<IssueResponse> _mockIssues = [];
  bool shouldThrow = false;
  String errorMessage = 'Mock error';

  MockIssueRepository() {
    // Initialize with sample data
    _mockIssues.addAll([
      IssueResponse(
        id: 1,
        title: 'Test Issue 1',
        content: 'Description 1',
        fullContent: 'Full description 1',
        status: 'OPEN',
        voteCount: 10,
        comments: 5,
        hasUserVoted: false,
        canUserVote: true,
        username: 'user1',
        createdAt: DateTime.now().toIso8601String(),
        mediaUrls: [],
      ),
      IssueResponse(
        id: 2,
        title: 'Test Issue 2',
        content: 'Description 2',
        fullContent: 'Full description 2',
        status: 'PENDING',
        voteCount: 25,
        comments: 12,
        hasUserVoted: true,
        canUserVote: true,
        username: 'user2',
        createdAt: DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        mediaUrls: ['https://example.com/image.jpg'],
      ),
    ]);
  }

  @override
  Future<PageIssueSummaryResponse> getIssues({
    int page = 0,
    int size = 20,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);

    await Future.delayed(const Duration(milliseconds: 100));

    final start = page * size;
    final end = (start + size).clamp(0, _mockIssues.length);
    final pageIssues = start < _mockIssues.length
        ? _mockIssues.sublist(start, end)
        : <IssueResponse>[];

    return PageIssueSummaryResponse(
      issues: pageIssues,
      totalPages: (_mockIssues.length / size).ceil(),
      totalElements: _mockIssues.length,
    );
  }

  @override
  Future<IssueResponse> getIssue(int issueId) async {
    if (shouldThrow) throw Exception(errorMessage);

    await Future.delayed(const Duration(milliseconds: 50));
    return _mockIssues.firstWhere(
      (i) => i.id == issueId,
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
      content: request.content,
      fullContent: request.content,
      status: 'PENDING',
      voteCount: 0,
      comments: 0,
      hasUserVoted: false,
      canUserVote: true,
      username: 'testuser',
      createdAt: DateTime.now().toIso8601String(),
      mediaUrls: request.mediaUrls,
    );
    _mockIssues.add(newIssue);
    return newIssue;
  }

  @override
  Future<IssueResponse> updateIssue(
    int issueId,
    UpdateIssueRequest request,
  ) async {
    if (shouldThrow) throw Exception(errorMessage);

    final index = _mockIssues.indexWhere((i) => i.id == issueId);
    if (index == -1) throw Exception('Issue not found');

    // Return the same issue (simplified mock)
    return _mockIssues[index];
  }

  @override
  Future<void> deleteIssue(int issueId) async {
    if (shouldThrow) throw Exception(errorMessage);
    _mockIssues.removeWhere((i) => i.id == issueId);
  }

  @override
  Future<IssueClusterResponse> getClusters(int numberOfClusters) async {
    if (shouldThrow) throw Exception(errorMessage);
    return IssueClusterResponse(clusteredIssues: _mockIssues);
  }

  @override
  Future<PageIssueSummaryResponse> filterIssues(
    IssueFilterRequest filter, {
    int page = 0,
    int size = 20,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);

    var filtered = _mockIssues.toList();
    if (filter.status != null) {
      filtered = filtered.where((i) => i.status == filter.status).toList();
    }

    return PageIssueSummaryResponse(
      issues: filtered,
      totalPages: 1,
      totalElements: filtered.length,
    );
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
