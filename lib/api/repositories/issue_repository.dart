import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/api/services/issue_service.dart';

class IssueRepository {
  final ApiService apiService = ApiService();

  Future<List<Issue>> getAllIssues() => apiService.fetchIssues();
  Future<bool> addIssue(Issue issue) => apiService.createIssue(issue);
}
