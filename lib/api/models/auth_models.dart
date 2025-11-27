class SignupRequest {
  final String userName;
  final String name;
  final String email;
  final String dateOfBirth; // Format: YYYY-MM-DD
  final String phoneNumber;
  final String password;
  final String? profileImageUrl;

  SignupRequest({
    required this.userName,
    required this.name,
    required this.email,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.password,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'name': name,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'password': password,
      'profileImageUrl': profileImageUrl,
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
  final String token;
  // Add other fields if returned by backend, e.g., user info

  LoginResponse({required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(token: json['token']);
  }
}
