import '../models/issue_model.dart';
import '../services/api_service.dart';

class IssueRepository {
  final ApiService apiService = ApiService();

  Future<List<Issue>> getAllIssues() => apiService.fetchIssues();
  Future<bool> addIssue(Issue issue) => apiService.createIssue(issue);
}
