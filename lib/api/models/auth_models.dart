enum UserRole { citizen, government, creator }

extension UserRoleJson on UserRole {
  String toJson() {
    return switch (this) {
      UserRole.citizen => 'CITIZEN',
      UserRole.government => 'GOVERNMENT',
      UserRole.creator => 'CREATOR',
    };
  }
}

class SignupRequest {
  /// Kept for backwards compatibility with existing UI/business logic.
  /// New API expects the field name `username`.
  final String userName;
  final String name;
  final String email;
  final String dateOfBirth; // Format: YYYY-MM-DD
  final String phoneNumber;
  final String password;
  final UserRole role;
  final String? profileImageUrl;
  final String? fcmToken;

  SignupRequest({
    required this.userName,
    required this.name,
    required this.email,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.password,
    this.role = UserRole.citizen,
    this.profileImageUrl,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': userName,
      'name': name,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'password': password,
      'role': role.toJson(),
      'profileImageUrl': profileImageUrl,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }
}

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}

class LoginResponse {
  /// New API uses `accessToken` / `refreshToken` (see lib/api2/models/AuthResponse.ts)
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final int? accessExpiresInMs;
  final Map<String, dynamic>? user;

  /// Backwards-compatible accessor used across the existing app.
  String get token => accessToken ?? '';

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.accessExpiresInMs,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      tokenType: json['tokenType'] as String?,
      accessExpiresInMs: json['accessExpiresInMs'] as int?,
      user: json['user'] as Map<String, dynamic>?,
    );
  }
}
