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

      // Check status code
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data;

        // Handle null or empty response
        if (data == null || (data is String && data.trim().isEmpty)) {
          // Success but no body - return a minimal response
          return _issueFromRequest(request);
        }

        // Try to parse as Map
        Map<String, dynamic> jsonData;
        if (data is Map<String, dynamic>) {
          jsonData = data;
        } else if (data is String) {
          final trimmed = data.trim();
          if (trimmed.isEmpty) {
            return _issueFromRequest(request);
          }
          try {
            jsonData = jsonDecode(trimmed) as Map<String, dynamic>;
          } catch (e) {
            throw Exception(
              'Failed to parse response JSON: $e. Response: $trimmed',
            );
          }
        } else {
          throw Exception(
            'Unexpected response type: ${data.runtimeType}. Response: $data',
          );
        }

        // Parse the issue response with error handling
        try {
          return IssueResponse.fromJson(jsonData);
        } catch (e) {
          throw Exception(
            'Failed to parse IssueResponse from JSON: $e. Data: $jsonData',
          );
        }
      } else {
        throw Exception(
          'Server returned status ${response.statusCode}: ${response.data}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to create issue: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Failed to create issue: ${e.message}');
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

  /// Fetches issues with individual query parameters (v1.1 API).
  Future<PageIssueSummaryResponse> getAllIssues({
    IssueFilterRequest? filter,
    int page = 0,
    int size = 20,
    String sortBy = 'CREATED_AT',
    String sortOrder = 'desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };

    // Add individual filter parameters (v1.1 uses query params, not JSON blob)
    if (filter != null) {
      queryParams.addAll(filter.toQueryParameters());
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

  IssueResponse _issueFromRequest(CreateIssueRequest request) {
    return IssueResponse(
      id: 0,
      title: request.title,
      description: request.description,
      mediaUrls: request.mediaUrls,
      voteCount: 0,
      status: 'PENDING',
      createdAt: DateTime.now().toIso8601String(),
      authorName: 'You',
      authorImageUrl: '',
      hasUserVoted: false,
      canUserVote: true,
    );
  }
}
