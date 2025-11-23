class CommentResponse {
  final int id;
  final int issueId;
  final String content;
  final int? parentCommentId;
  final int likes;
  final int repliesCount;
  final String createdAt;

  CommentResponse({
    required this.id,
    required this.issueId,
    required this.content,
    this.parentCommentId,
    required this.likes,
    required this.repliesCount,
    required this.createdAt,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) {
    return CommentResponse(
      id: json['id'],
      issueId: json['issueId'],
      content: json['content'],
      parentCommentId: json['parentCommentId'],
      likes: json['likes'],
      repliesCount: json['repliesCount'] ?? 0,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'issueId': issueId,
      'content': content,
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
      'likes': likes,
      'repliesCount': repliesCount,
      'createdAt': createdAt,
    };
  }
}

class CreateCommentRequest {
  final String content;
  CreateCommentRequest({required this.content});

  Map<String, dynamic> toJson() => {'content': content};
}

class CommentLikeResponse {
  final int commentId;
  final int likes;

  CommentLikeResponse({required this.commentId, required this.likes});

  factory CommentLikeResponse.fromJson(Map<String, dynamic> json) {
    return CommentLikeResponse(
      commentId: json['commentId'],
      likes: json['likes'],
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
    return PageCommentDetailResponse(
      comments: (json['comments'] as List)
          .map((e) => CommentResponse.fromJson(e))
          .toList(),
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
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
    return PageReplyResponse(
      replies: (json['replies'] as List)
          .map((e) => CommentResponse.fromJson(e))
          .toList(),
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
    );
  }
}
