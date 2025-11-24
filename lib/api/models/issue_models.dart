class IssueResponse {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final int likes;
  final int comments;
  final String fullContent;

  IssueResponse({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.likes,
    required this.comments,
    required this.fullContent,
  });

  factory IssueResponse.fromJson(Map<String, dynamic> json) {
    return IssueResponse(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      fullContent: json['fullContent'] ?? json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments,
      'fullContent': fullContent,
    };
  }
}

class CreateIssueRequest {
  final String title;
  final String content;
  final String? imageUrl;

  CreateIssueRequest({
    required this.title,
    required this.content,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}

class UpdateIssueRequest {
  final String? title;
  final String? content;
  final String? imageUrl;

  UpdateIssueRequest({this.title, this.content, this.imageUrl});

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}

class IssueFilterRequest {
  final String? status;
  final String? severity;

  IssueFilterRequest({this.status, this.severity});

  Map<String, dynamic> toJson() {
    return {
      if (status != null) 'status': status,
      if (severity != null) 'severity': severity,
    };
  }
}

/// -------- Issue Cluster Models -------

class IssueClusterRequest {
  final int numberOfClusters;

  IssueClusterRequest({required this.numberOfClusters});

  Map<String, dynamic> toJson() {
    return {
      'numberOfClusters': numberOfClusters,
    };
  }
}

class IssueClusterResponse {
  final List<IssueResponse> clusteredIssues;

  IssueClusterResponse({required this.clusteredIssues});

  factory IssueClusterResponse.fromJson(Map<String, dynamic> json) {
    return IssueClusterResponse(
      clusteredIssues: (json['issues'] as List)
          .map((i) => IssueResponse.fromJson(i))
          .toList(),
    );
  }
}

/// -------- Paginated Issue Summary -------

class PageIssueSummaryResponse {
  final List<IssueResponse> issues;
  final int totalPages;
  final int totalElements;

  PageIssueSummaryResponse({
    required this.issues,
    required this.totalPages,
    required this.totalElements,
  });

  factory PageIssueSummaryResponse.fromJson(Map<String, dynamic> json) {
    return PageIssueSummaryResponse(
      issues: (json['content'] as List)
          .map((i) => IssueResponse.fromJson(i))
          .toList(),
      totalPages: json['totalPages'] ?? 1,
      totalElements: json['totalElements'] ?? 0,
    );
  }
}
