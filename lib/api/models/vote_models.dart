class Vote {
  final int voteId;
  final int issueId;
  final int userId;

  Vote({
    required this.voteId,
    required this.issueId,
    required this.userId,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      voteId: json['vote_id'],
      issueId: json['issue_id'],
      userId: json['user_id'],
    );
  }
}
