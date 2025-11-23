import '../models/comment_models.dart';
import '../services/comment_service.dart';

class CommentRepository {
  final CommentService service;

  CommentRepository({required this.service});

  Future<CommentResponse> getComment(int commentId) => service.getCommentById(commentId);

  Future<CommentResponse> createComment(int issueId, CreateCommentRequest request) =>
      service.createComment(issueId, request);

  Future<CommentResponse> createReply(int commentId, CreateCommentRequest request) =>
      service.createReply(commentId, request);

  Future<void> updateComment(int commentId, String content) =>
      service.updateComment(commentId, content);

  Future<void> deleteComment(int commentId) => service.deleteComment(commentId);

  Future<PageCommentDetailResponse> getCommentsByIssue(int issueId, {int page = 0, int size = 20}) =>
      service.getCommentsByIssue(issueId, page: page, size: size);

  Future<PageReplyResponse> getRepliesByComment(int commentId, {int page = 0, int size = 20}) =>
      service.getRepliesByComment(commentId, page: page, size: size);

  Future<CommentLikeResponse> likeComment(int commentId) => service.likeComment(commentId);

  Future<CommentLikeResponse> removeLike(int commentId) => service.removeLike(commentId);
}
