class Comment{
  final int commentId;
  final String text;
  final int likeCount;

  Comment({
    required this.commentId,
    required this.text,
    required this.likeCount,
  });

  factory Comment.fromJson(Map<String, dynamic> json){
    return Comment(
      commentId: json['comment_id'],
      text: json['text'],
      likeCount: json['like_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "comment_id": commentId,
      "text": text,
      "like_count": likeCount,
    };
  }
  
}