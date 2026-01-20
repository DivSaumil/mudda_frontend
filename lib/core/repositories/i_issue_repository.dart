import 'package:mudda_frontend/api/models/issue_models.dart';

/// Abstract interface for issue data operations.
///
/// This allows for different implementations:
/// - [IssueRepository] - real API implementation
/// - [MockIssueRepository] - test/mock implementation
abstract class IIssueRepository {
  /// Fetches a paginated list of issues.
  Future<PageIssueSummaryResponse> getIssues({int page = 0, int size = 20});

  /// Fetches a single issue by ID.
  Future<IssueResponse> getIssue(int issueId);

  /// Creates a new issue.
  Future<IssueResponse> createIssue(CreateIssueRequest request);

  /// Updates an existing issue.
  Future<IssueResponse> updateIssue(int issueId, UpdateIssueRequest request);

  /// Deletes an issue.
  Future<void> deleteIssue(int issueId);

  /// Fetches issue clusters.
  Future<IssueClusterResponse> getClusters(int numberOfClusters);

  /// Filters issues by criteria.
  Future<PageIssueSummaryResponse> filterIssues(
    IssueFilterRequest filter, {
    int page = 0,
    int size = 20,
  });
}
