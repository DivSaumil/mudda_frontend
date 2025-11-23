class UserDetailResponse {
  final int id;
  final String userName;
  final String name;
  final String dateOfBirth;
  final String createdAt;
  final String updatedAt;

  UserDetailResponse({
    required this.id,
    required this.userName,
    required this.name,
    required this.dateOfBirth,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserDetailResponse.fromJson(Map<String, dynamic> json) {
    return UserDetailResponse(
      id: json['id'],
      userName: json['userName'],
      name: json['name'],
      dateOfBirth: json['dateOfBirth'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'name': name,
        'dateOfBirth': dateOfBirth,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class UserSummaryResponse {
  final int id;
  final String userName;
  final String name;

  UserSummaryResponse({
    required this.id,
    required this.userName,
    required this.name,
  });

  factory UserSummaryResponse.fromJson(Map<String, dynamic> json) {
    return UserSummaryResponse(
      id: json['id'],
      userName: json['userName'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'name': name,
      };
}

class CreateUserRequest {
  final String userName;
  final String name;
  final String dateOfBirth;

  CreateUserRequest({
    required this.userName,
    required this.name,
    required this.dateOfBirth,
  });

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'name': name,
        'dateOfBirth': dateOfBirth,
      };
}

class UpdateUserRequest {
  final String? name;
  final String? dateOfBirth;

  UpdateUserRequest({this.name, this.dateOfBirth});

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      };
}

class UserFilterRequest {
  final String? search;

  UserFilterRequest({this.search});

  Map<String, dynamic> toJson() => {
        if (search != null) 'search': search,
      };
}

class PageUserSummaryResponse {
  final List<UserSummaryResponse> content;
  final int totalPages;
  final int totalElements;

  PageUserSummaryResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
  });

  factory PageUserSummaryResponse.fromJson(Map<String, dynamic> json) {
    return PageUserSummaryResponse(
      content: (json['content'] as List)
          .map((e) => UserSummaryResponse.fromJson(e))
          .toList(),
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
    );
  }
}
