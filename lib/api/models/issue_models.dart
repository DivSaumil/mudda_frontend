import 'package:mudda_frontend/api/config/constants.dart';

/// Full issue detail response from GET /api/v1/issues/{id}
/// Also used for issue summary in list responses (some fields may be absent).
class IssueResponse {
  final int id;
  final String title;
  final String description;
  final String status;
  final int voteCount;
  final List<String> mediaUrls; // Already resolved to full URLs
  final String createdAt;
  final String? updatedAt;
  final int? authorId;
  final String authorName;
  final String authorImageUrl; // Already resolved to full URL
  final bool? hasUserVoted;
  final bool? canUserVote;
  final bool? canUserComment;
  final bool? canUserEdit;
  final bool? canUserDelete;
  final double? severityScore;
  final Map<String, dynamic>? locationSummary;
  final String? category;

  IssueResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.voteCount,
    required this.mediaUrls,
    required this.createdAt,
    this.updatedAt,
    this.authorId,
    required this.authorName,
    required this.authorImageUrl,
    this.hasUserVoted,
    this.canUserVote,
    this.canUserComment,
    this.canUserEdit,
    this.canUserDelete,
    this.severityScore,
    this.locationSummary,
    this.category,
  });

  // Helper to get the first image URL if available
  String? get firstImageUrl => mediaUrls.isNotEmpty ? mediaUrls.first : null;

  // Backward-compat getters used by existing UI code
  String get content => description;
  String get fullContent => description;
  String get username => authorName;
  int get comments => 0; // No longer returned by backend; kept for compat

  factory IssueResponse.fromJson(Map<String, dynamic> json) {
    // Handle id conversion
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Handle media_urls — resolve each key to a full URL
    List<String> parseMediaUrls(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value
            .map((e) => AppConstants.resolveImageUrl(e.toString()))
            .where((url) => url.isNotEmpty)
            .toList();
      }
      return [];
    }

    return IssueResponse(
      id: parseId(json['id']),
      title: (json['title'] as String?) ?? '',
      description:
          (json['description'] as String?) ??
          (json['content'] as String?) ??
          '',
      mediaUrls: parseMediaUrls(json['media_urls']),
      voteCount: (json['vote_count'] as int?) ?? 0,
      status: (json['status'] as String?) ?? 'PENDING',
      createdAt:
          (json['created_at'] as String?) ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] as String?,
      authorId: json['author_id'] as int?,
      authorName:
          (json['author_name'] as String?) ??
          (json['username'] as String?) ??
          'Anonymous Citizen',
      authorImageUrl: AppConstants.resolveImageUrl(
        (json['author_image_url'] as String?) ?? '',
      ),
      hasUserVoted: json['has_user_voted'] as bool?,
      canUserVote: json['can_user_vote'] as bool?,
      canUserComment: json['can_user_comment'] as bool?,
      canUserEdit: json['can_user_edit'] as bool?,
      canUserDelete: json['can_user_delete'] as bool?,
      severityScore: (json['severity_score'] as num?)?.toDouble(),
      locationSummary: json['locationSummary'] as Map<String, dynamic>?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'media_urls': mediaUrls,
      'vote_count': voteCount,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'author_id': authorId,
      'author_name': authorName,
      'author_image_url': authorImageUrl,
      'has_user_voted': hasUserVoted,
      'can_user_vote': canUserVote,
      'can_user_comment': canUserComment,
      'can_user_edit': canUserEdit,
      'can_user_delete': canUserDelete,
      'severity_score': severityScore,
      'locationSummary': locationSummary,
      'category': category,
    };
  }
}

class CreateIssueRequest {
  final String title;
  final String description;
  final int? locationId;
  final int? categoryId;
  final List<String> mediaUrls; // fileKeys from image upload

  CreateIssueRequest({
    required this.title,
    required this.description,
    this.locationId,
    this.categoryId,
    this.mediaUrls = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      if (locationId != null) 'location_id': locationId,
      if (categoryId != null) 'category_id': categoryId,
      if (mediaUrls.isNotEmpty) 'media_urls': mediaUrls,
    };
  }
}

class UpdateIssueRequest {
  final String? title;
  final String? description;
  final String? status; // OPEN | PENDING | RESOLVED | CLOSED

  UpdateIssueRequest({this.title, this.description, this.status});

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
    };
  }
}

class IssueFilterRequest {
  final String? search;
  final String? status;
  final int? userId;
  final int? categoryId;
  final String? city;
  final String? state;
  final bool? urgency;
  final double? minSeverity;
  final double? maxSeverity;
  final String? createdAfter;
  final String? createdBefore;

  IssueFilterRequest({
    this.search,
    this.status,
    this.userId,
    this.categoryId,
    this.city,
    this.state,
    this.urgency,
    this.minSeverity,
    this.maxSeverity,
    this.createdAfter,
    this.createdBefore,
  });

  /// Returns query parameters for the GET /issues endpoint.
  Map<String, dynamic> toQueryParameters() {
    return {
      if (search != null) 'search': search,
      if (status != null) 'status': status,
      if (userId != null) 'userId': userId,
      if (categoryId != null) 'category_id': categoryId,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (urgency != null) 'urgency': urgency,
      if (minSeverity != null) 'min_severity': minSeverity,
      if (maxSeverity != null) 'max_severity': maxSeverity,
      if (createdAfter != null) 'created_after': createdAfter,
      if (createdBefore != null) 'created_before': createdBefore,
    };
  }

  // Keep for backward compatibility
  Map<String, dynamic> toJson() => toQueryParameters();
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
  final int currentPage;
  final int pageSize;

  PageIssueSummaryResponse({
    required this.issues,
    required this.totalPages,
    required this.totalElements,
    this.currentPage = 0,
    this.pageSize = 20,
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
    int currentPage = 0;
    int pageSize = 20;

    if (page != null && page is Map) {
      // Spring Boot nested page format
      totalPages = (page['totalPages'] as int?) ?? 1;
      totalElements = (page['totalElements'] as int?) ?? 0;
      currentPage = (page['number'] as int?) ?? 0;
      pageSize = (page['size'] as int?) ?? 20;
    } else {
      // v1.1 flat pagination fields
      totalPages = (json['totalPages'] as int?) ?? 1;
      totalElements = (json['totalElements'] as int?) ?? 0;
      currentPage = (json['number'] as int?) ?? 0;
      pageSize = (json['size'] as int?) ?? 20;
    }

    return PageIssueSummaryResponse(
      issues: issuesList,
      totalPages: totalPages,
      totalElements: totalElements,
      currentPage: currentPage,
      pageSize: pageSize,
    );
  }
}
