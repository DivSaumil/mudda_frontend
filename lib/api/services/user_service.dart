import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_models.dart';

class UserService {
  final String baseUrl;

  UserService({required this.baseUrl});

  Future<UserDetailResponse> getUserById(int id) async {
    final url = Uri.parse('$baseUrl/api/v1/users/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return UserDetailResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch user: ${response.body}');
    }
  }

  Future<UserSummaryResponse> updateUser(int id, UpdateUserRequest request) async {
    final url = Uri.parse('$baseUrl/api/v1/users/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return UserSummaryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  Future<void> deleteUser(int id) async {
    final url = Uri.parse('$baseUrl/api/v1/users/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }

  Future<PageUserSummaryResponse> getAllUsers({
    required UserFilterRequest filterRequest,
    int page = 0,
    int size = 20,
    String sortBy = 'CREATED_AT',
    String sortOrder = 'desc',
  }) async {
    final queryParameters = {
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      'filterRequest': jsonEncode(filterRequest.toJson()),
    };

    final url = Uri.parse('$baseUrl/api/v1/users').replace(queryParameters: queryParameters);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return PageUserSummaryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch users: ${response.body}');
    }
  }

  Future<UserDetailResponse> createUser(CreateUserRequest request) async {
    final url = Uri.parse('$baseUrl/api/v1/users');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserDetailResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }
}
