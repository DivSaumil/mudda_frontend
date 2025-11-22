import '../models/comment_model.dart';
import '../services/comment_service.dart';

class CommentRepository {
  final CommentService commentService = CommentService();

  Future<List<Comment>> getComments(int issueId) => commentService.fetchComments(issueId);
  Future<bool> addComment(String text, int issueId, int userId, {int? parentId}) =>
      commentService.addComment(text: text, issueId: issueId, userId: userId, parentId: parentId);
}
