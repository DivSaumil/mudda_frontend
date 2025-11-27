import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/issue_models.dart';

class IssueService {
  final Dio _dio;

  IssueService(this._dio);

  Future<IssueResponse> getIssueById(int id) async {
    try {
      final response = await _dio.get('/issues/$id');
      return IssueResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load issue: $e');
    }
  }

  Future<IssueResponse> createIssue(CreateIssueRequest request) async {
    try {
      final response = await _dio.post('/issues', data: request.toJson());
      return IssueResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create issue: $e');
    }
  }

  Future<IssueResponse> updateIssue(int id, UpdateIssueRequest request) async {
    try {
      final response = await _dio.put('/issues/$id', data: request.toJson());
      return IssueResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update issue: $e');
    }
  }

  Future<void> deleteIssue(int id) async {
    try {
      await _dio.delete('/issues/$id');
    } catch (e) {
      throw Exception('Failed to delete issue: $e');
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
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };

    if (filter != null) {
      queryParams['filterRequest'] = jsonEncode(filter.toJson());
    }

    try {
      final response = await _dio.get('/issues', queryParameters: queryParams);
      return PageIssueSummaryResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch issues: $e');
    }
  }

  /// -------------------- Issue Clusters --------------------
  Future<IssueClusterResponse> getIssueClusters(
    IssueClusterRequest request,
  ) async {
    try {
      final response = await _dio.get(
        '/issues/clusters',
        queryParameters: {'clusterRequest': jsonEncode(request.toJson())},
      );
      return IssueClusterResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch clusters: $e');
    }
  }
}
