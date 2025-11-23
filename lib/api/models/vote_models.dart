class Vote {
  final int id;
  final int issueId;
  final int userId;
  final DateTime createdAt;

  Vote({
    required this.id,
    required this.issueId,
    required this.userId,
    required this.createdAt,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      id: json['id'],
      issueId: json['issueId'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'issueId': issueId,
        'userId': userId,
        'createdAt': createdAt.toIso8601String(),
      };
}

class VoteResponse {
  final Vote vote;

  VoteResponse({required this.vote});

  factory VoteResponse.fromJson(Map<String, dynamic> json) {
    return VoteResponse(vote: Vote.fromJson(json['vote']));
  }
}

class PageVote {
  final List<Vote> content;
  final int totalPages;
  final int totalElements;

  PageVote({
    required this.content,
    required this.totalPages,
    required this.totalElements,
  });

  factory PageVote.fromJson(Map<String, dynamic> json) {
    return PageVote(
      content: (json['content'] as List).map((e) => Vote.fromJson(e)).toList(),
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
    );
  }
}
