import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comment_models.dart';

class CommentService {
  final String baseUrl;

  CommentService({required this.baseUrl});

  Future<CommentResponse> getCommentById(int commentId) async {
    final url = Uri.parse('$baseUrl/api/v1/comments/$commentId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return CommentResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch comment: ${response.body}');
    }
  }

  Future<CommentResponse> createComment(int issueId, CreateCommentRequest request) async {
    final url = Uri.parse('$baseUrl/api/v1/issues/$issueId/comments');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CommentResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create comment: ${response.body}');
    }
  }

  Future<CommentResponse> createReply(int commentId, CreateCommentRequest request) async {
    final url = Uri.parse('$baseUrl/api/v1/comments/$commentId/replies');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CommentResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create reply: ${response.body}');
    }
  }

  Future<void> updateComment(int commentId, String content) async {
    final url = Uri.parse('$baseUrl/api/v1/comments/$commentId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update comment: ${response.body}');
    }
  }

  Future<void> deleteComment(int commentId) async {
    final url = Uri.parse('$baseUrl/api/v1/comments/$commentId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete comment: ${response.body}');
    }
  }

  Future<PageCommentDetailResponse> getCommentsByIssue(int issueId, {int page = 0, int size = 20}) async {
    final url = Uri.parse('$baseUrl/api/v1/issues/$issueId/comments?page=$page&size=$size');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return PageCommentDetailResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch comments: ${response.body}');
    }
  }

  Future<PageReplyResponse> getRepliesByComment(int commentId, {int page = 0, int size = 20}) async {
    final url = Uri.parse('$baseUrl/api/v1/comments/$commentId/replies?page=$page&size=$size');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return PageReplyResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch replies: ${response.body}');
    }
  }

  Future<CommentLikeResponse> likeComment(int commentId) async {
    final url = Uri.parse('$baseUrl/api/v1/comments/$commentId/like');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      return CommentLikeResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to like comment: ${response.body}');
    }
  }

  Future<CommentLikeResponse> removeLike(int commentId) async {
    final url = Uri.parse('$baseUrl/api/v1/comments/$commentId/like');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return CommentLikeResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to remove like: ${response.body}');
    }
  }
}
