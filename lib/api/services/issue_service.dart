import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/issue_models.dart';

class IssueService {
  final String baseUrl;

  IssueService({required this.baseUrl});

  Future<IssueResponse> getIssueById(int id) async {
    final url = Uri.parse('$baseUrl/api/v1/issues/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return IssueResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load issue: ${response.body}');
    }
  }

  Future<IssueResponse> createIssue(CreateIssueRequest request) async {
    final url = Uri.parse('$baseUrl/api/v1/issues');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return IssueResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create issue: ${response.body}');
    }
  }

  Future<IssueResponse> updateIssue(int id, UpdateIssueRequest request) async {
    final url = Uri.parse('$baseUrl/api/v1/issues/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return IssueResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update issue: ${response.body}');
    }
  }

  Future<void> deleteIssue(int id) async {
    final url = Uri.parse('$baseUrl/api/v1/issues/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete issue: ${response.body}');
    }
  }

  Future<PageIssueSummaryResponse> getAllIssues({
    IssueFilterRequest? filter,
    int page = 0,
    int size = 20,
    String sortBy = 'CREATED_AT',
    String sortOrder = 'desc',
  }) async {
    final queryParams = {
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };

    if (filter != null) {
      queryParams['filterRequest'] = jsonEncode(filter.toJson());
    }

    final url = Uri.parse('$baseUrl/api/v1/issues')
        .replace(queryParameters: queryParams);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        return PageIssueSummaryResponse.fromJson(jsonData);
      } catch (e) {
        throw Exception('Failed to parse issues response: $e. Response body: ${response.body}');
      }
    } else {
      throw Exception('Failed to fetch issues: ${response.statusCode} - ${response.body}');
    }
  }

  /// -------------------- Issue Clusters --------------------
  Future<IssueClusterResponse> getIssueClusters(
      IssueClusterRequest request) async {
    final url = Uri.parse('$baseUrl/api/v1/issues/clusters')
        .replace(queryParameters: {
      'clusterRequest': jsonEncode(request.toJson()),
    });

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return IssueClusterResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch clusters: ${response.body}');
    }
  }
}
