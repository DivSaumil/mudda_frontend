import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import 'package:mudda_frontend/api/models/comment_models.dart';

class CommentService {
  final String baseUrl = AppConstants.baseUrl;

  Future<List<Comment>> fetchComments(int issueId) async {
    final response = await http.get(Uri.parse('$baseUrl/issues/$issueId/comments'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Comment.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load comments");
    }
  }

  Future<bool> addComment({
    required String text,
    required int issueId,
    required int userId,
    int? parentId,
  }) async {
    final body = {
      "text": text,
      "issueId": issueId,
      "userId": userId,
      "parentId": parentId ?? 0
    };

    final response = await http.post(
      Uri.parse('$baseUrl/comments'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    return response.statusCode == 201;
  }
}