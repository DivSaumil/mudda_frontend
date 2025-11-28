import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/api/services/issue_service.dart';

class IssueRepository {
  final IssueService service;

  IssueRepository({required this.service});

  Future<List<IssueResponse>> fetchIssues({
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
        severity: requestFilter.severity,
        category: category,
      );
    }

    final pageData = await service.getAllIssues(
      filter: requestFilter,
      page: page,
      size: size,
    );
    return pageData.issues;
  }

  Future<IssueResponse> getIssue(int id) async {
    return await service.getIssueById(id);
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
