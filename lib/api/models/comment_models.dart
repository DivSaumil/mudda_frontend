class CommentResponse {
  final int id;
  final int issueId;
  final String content;
  final int? parentCommentId;
  final int likes;
  final int repliesCount;
  final String createdAt;
  final int authorId;
  final bool hasUserLiked;

  CommentResponse({
    required this.id,
    required this.issueId,
    required this.content,
    this.parentCommentId,
    required this.likes,
    required this.repliesCount,
    required this.createdAt,
    required this.authorId,
    required this.hasUserLiked,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) {
    return CommentResponse(
      id: json['comment_id'] ?? 0,
      issueId: json['issue_id'] ?? 0,
      content: json['text'] ?? '',
      parentCommentId: json['parent_comment_id'],
      likes: json['like_count'] ?? 0,
      repliesCount: json['reply_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      authorId: json['author_id'] ?? 0,
      hasUserLiked: json['has_user_liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id': id,
      'issue_id': issueId,
      'text': content,
      if (parentCommentId != null) 'parent_comment_id': parentCommentId,
      'like_count': likes,
      'reply_count': repliesCount,
      'created_at': createdAt,
      'author_id': authorId,
      'has_user_liked': hasUserLiked,
    };
  }
}

class CreateCommentRequest {
  final String content;
  CreateCommentRequest({required this.content});

  Map<String, dynamic> toJson() => {'text': content};
}

class CommentLikeResponse {
  final int commentId;
  final int likes;

  CommentLikeResponse({required this.commentId, required this.likes});

  factory CommentLikeResponse.fromJson(Map<String, dynamic> json) {
    return CommentLikeResponse(
      commentId: json['comment_id'] ?? 0,
      likes: json['like_count'] ?? 0,
    );
  }
}

class PageCommentDetailResponse {
  final List<CommentResponse> comments;
  final int totalPages;
  final int totalElements;

  PageCommentDetailResponse({
    required this.comments,
    required this.totalPages,
    required this.totalElements,
  });

  factory PageCommentDetailResponse.fromJson(Map<String, dynamic> json) {
    final page = json['page'] as Map<String, dynamic>?;
    return PageCommentDetailResponse(
      comments:
          (json['content'] as List?)
              ?.map((e) => CommentResponse.fromJson(e))
              .toList() ??
          [],
      totalPages: page?['totalPages'] ?? json['totalPages'] ?? 0,
      totalElements: page?['totalElements'] ?? json['totalElements'] ?? 0,
    );
  }
}

class PageReplyResponse {
  final List<CommentResponse> replies;
  final int totalPages;
  final int totalElements;

  PageReplyResponse({
    required this.replies,
    required this.totalPages,
    required this.totalElements,
  });

  factory PageReplyResponse.fromJson(Map<String, dynamic> json) {
    final page = json['page'] as Map<String, dynamic>?;
    return PageReplyResponse(
      replies:
          (json['content'] as List?)
              ?.map((e) => CommentResponse.fromJson(e))
              .toList() ??
          [],
      totalPages: page?['totalPages'] ?? json['totalPages'] ?? 0,
      totalElements: page?['totalElements'] ?? json['totalElements'] ?? 0,
    );
  }
}
