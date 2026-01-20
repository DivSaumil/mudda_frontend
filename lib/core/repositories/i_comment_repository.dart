import 'package:mudda_frontend/api/models/comment_models.dart';

/// Abstract interface for comment data operations.
abstract class ICommentRepository {
  /// Gets a single comment by ID.
  Future<CommentResponse> getComment(int commentId);

  /// Creates a comment on an issue.
  Future<CommentResponse> createComment(
    int issueId,
    CreateCommentRequest request,
  );

  /// Creates a reply to a comment.
  Future<CommentResponse> createReply(
    int commentId,
    CreateCommentRequest request,
  );

  /// Updates a comment.
  Future<void> updateComment(int commentId, String content);

  /// Deletes a comment.
  Future<void> deleteComment(int commentId);

  /// Gets comments for an issue.
  Future<PageCommentDetailResponse> getCommentsByIssue(
    int issueId, {
    int page = 0,
    int size = 20,
  });

  /// Gets replies for a comment.
  Future<PageReplyResponse> getRepliesByComment(
    int commentId, {
    int page = 0,
    int size = 20,
  });

  /// Likes a comment.
  Future<CommentLikeResponse> likeComment(int commentId);

  /// Removes a like from a comment.
  Future<CommentLikeResponse> removeLike(int commentId);
}
