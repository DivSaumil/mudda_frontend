class IssueResponse {
  final int id;
  final String title;
  final String content; // Keeping this but might be empty in list view
  final List<String> mediaUrls;
  final int voteCount;
  final int comments; // Not in snippet, defaulting to 0
  final String fullContent; // Not in snippet, defaulting to content
  final String status;
  final String createdAt;
  final bool hasUserVoted;
  final bool canUserVote;

  IssueResponse({
    required this.id,
    required this.title,
    required this.content,
    required this.mediaUrls,
    required this.voteCount,
    required this.comments,
    required this.fullContent,
    required this.status,
    required this.createdAt,
    required this.hasUserVoted,
    required this.canUserVote,
  });

  // Helper to get the first image URL if available
  String? get firstImageUrl => mediaUrls.isNotEmpty ? mediaUrls.first : null;

  factory IssueResponse.fromJson(Map<String, dynamic> json) {
    // Handle id conversion
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Handle media_urls
    List<String> parseMediaUrls(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      return [];
    }

    return IssueResponse(
      id: parseId(json['id']),
      title: (json['title'] as String?) ?? '',
      content:
          (json['content'] as String?) ??
          (json['description'] as String?) ??
          '',
      mediaUrls: parseMediaUrls(json['media_urls']),
      voteCount: (json['vote_count'] as int?) ?? 0,
      comments:
          (json['comments'] as int?) ??
          0, // Defaulting as it's missing in snippet
      fullContent:
          (json['fullContent'] as String?) ??
          (json['content'] as String?) ??
          (json['description'] as String?) ??
          '',
      status: (json['status'] as String?) ?? 'PENDING',
      createdAt:
          (json['created_at'] as String?) ?? DateTime.now().toIso8601String(),
      hasUserVoted: (json['has_user_voted'] as bool?) ?? false,
      canUserVote: (json['can_user_vote'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'media_urls': mediaUrls,
      'vote_count': voteCount,
      'comments': comments,
      'fullContent': fullContent,
      'status': status,
      'created_at': createdAt,
      'has_user_voted': hasUserVoted,
      'can_user_vote': canUserVote,
    };
  }
}

class CreateIssueRequest {
  final String title;
  final String content;
  final List<String> mediaUrls;
  final int? categoryId;
  final int? locationId;
  final int severityScore;
  final bool urgencyFlag;
  final String issueStatus;

  CreateIssueRequest({
    required this.title,
    required this.content,
    this.mediaUrls = const [],
    this.categoryId,
    this.locationId,
    this.severityScore = 1,
    this.urgencyFlag = false,
    this.issueStatus = 'PENDING',
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'description': content, // Mapping content to description as required
      'media_urls': mediaUrls,
      if (categoryId != null) 'categoryId': categoryId,
      if (locationId != null) 'locationId': locationId,
      'severity_score': severityScore,
      'urgency_flag': urgencyFlag,
      'issue_status': issueStatus,
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
    return {'numberOfClusters': numberOfClusters};
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
    final content = json['content'];
    final page = json['page'];
    List<IssueResponse> issuesList = [];

    if (content != null && content is List) {
      issuesList = content
          .map((i) => IssueResponse.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    int totalPages = 1;
    int totalElements = 0;

    if (page != null && page is Map) {
      totalPages = (page['totalPages'] as int?) ?? 1;
      totalElements = (page['totalElements'] as int?) ?? 0;
    } else {
      totalPages = (json['totalPages'] as int?) ?? 1;
      totalElements = (json['totalElements'] as int?) ?? 0;
    }

    return PageIssueSummaryResponse(
      issues: issuesList,
      totalPages: totalPages,
      totalElements: totalElements,
    );
  }
}
