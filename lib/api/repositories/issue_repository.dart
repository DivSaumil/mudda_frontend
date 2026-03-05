import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/api/services/issue_service.dart';
import 'package:mudda_frontend/api/services/issue_cache_service.dart';

/// Result wrapper that indicates whether data came from cache.
class FetchIssuesResult {
  final List<IssueResponse> issues;
  final bool isFromCache;

  FetchIssuesResult({required this.issues, this.isFromCache = false});
}

class IssueRepository {
  final IssueService service;
  final IssueCacheService cacheService;

  IssueRepository({required this.service, required this.cacheService});

  /// Fetches issues with cache-then-network strategy.
  ///
  /// On success: caches the result and returns it.
  /// On failure: returns cached issues if available (with [isFromCache] = true).
  Future<FetchIssuesResult> fetchIssues({
    IssueFilterRequest? filter,
    String? category,
    int page = 0,
    int size = 20,
  }) async {
    // If category is provided, ensure it's added to the filter
    IssueFilterRequest requestFilter = filter ?? IssueFilterRequest();
    if (category != null && category.isNotEmpty && category != 'All') {
      requestFilter = IssueFilterRequest(
        status: requestFilter.status,
        search: requestFilter.search,
      );
    }

    final cacheCategory = category ?? 'All';

    try {
      final pageData = await service.getAllIssues(
        filter: requestFilter,
        page: page,
        size: size,
      );

      // Cache only the first page to keep storage light
      if (page == 0) {
        await cacheService.cacheIssues(
          pageData.issues,
          category: cacheCategory,
        );
      }

      return FetchIssuesResult(issues: pageData.issues);
    } catch (e) {
      // On network error, try to serve cached data (only first page)
      if (page == 0) {
        final cached = await cacheService.getCachedIssues(
          category: cacheCategory,
        );
        if (cached != null && cached.isNotEmpty) {
          return FetchIssuesResult(issues: cached, isFromCache: true);
        }
      }
      rethrow;
    }
  }

  /// Fetches a single issue with cache fallback.
  Future<IssueResponse> getIssue(int id) async {
    try {
      final issue = await service.getIssueById(id);
      await cacheService.cacheIssueDetail(issue);
      return issue;
    } catch (e) {
      final cached = await cacheService.getCachedIssueDetail(id);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<IssueResponse> createIssue(CreateIssueRequest request) async {
    return await service.createIssue(request);
  }

  Future<IssueResponse> updateIssue(int id, UpdateIssueRequest request) async {
    return await service.updateIssue(id, request);
  }

  Future<void> deleteIssue(int id) async {
    return await service.deleteIssue(id);
  }

  /// -------- Cluster Fetching --------

  Future<IssueClusterResponse> getClusters(int k) async {
    return await service.getIssueClusters(
      IssueClusterRequest(numberOfClusters: k),
    );
  }
}
