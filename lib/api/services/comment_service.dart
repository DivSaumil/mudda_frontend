import 'package:dio/dio.dart';
import 'package:mudda_frontend/api/models/comment_models.dart';

class CommentService {
  final Dio _dio;

  CommentService(this._dio);

  Future<CommentResponse> getCommentById(int commentId) async {
    try {
      final response = await _dio.get('/comments/$commentId');
      return CommentResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch comment: $e');
    }
  }

  Future<CommentResponse> createComment(
    int issueId,
    CreateCommentRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/issues/$issueId/comments',
        data: request.toJson(),
      );
      return CommentResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create comment: $e');
    }
  }

  Future<CommentResponse> createReply(
    int commentId,
    CreateCommentRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/comments/$commentId/replies',
        data: request.toJson(),
      );
      return CommentResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create reply: $e');
    }
  }

  Future<void> updateComment(int commentId, String content) async {
    try {
      await _dio.put('/comments/$commentId', data: {'content': content});
    } catch (e) {
      throw Exception('Failed to update comment: $e');
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      await _dio.delete('/comments/$commentId');
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  Future<PageCommentDetailResponse> getCommentsByIssue(
    int issueId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/issues/$issueId/comments',
        queryParameters: {'page': page, 'size': size},
      );
      return PageCommentDetailResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch comments: $e');
    }
  }

  Future<PageReplyResponse> getRepliesByComment(
    int commentId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/comments/$commentId/replies',
        queryParameters: {'page': page, 'size': size},
      );
      return PageReplyResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch replies: $e');
    }
  }

  Future<CommentLikeResponse> likeComment(int commentId) async {
    try {
      final response = await _dio.post('/comments/$commentId/like');
      return CommentLikeResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to like comment: $e');
    }
  }

  Future<CommentLikeResponse> removeLike(int commentId) async {
    try {
      final response = await _dio.delete('/comments/$commentId/like');
      return CommentLikeResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to remove like: $e');
    }
  }
}
