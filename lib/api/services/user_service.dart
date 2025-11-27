import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/user_models.dart';

class UserService {
  final Dio _dio;

  UserService(this._dio);

  Future<UserDetailResponse> getUserById(int id) async {
    try {
      final response = await _dio.get('/users/$id');
      return UserDetailResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  Future<UserSummaryResponse> updateUser(
    int id,
    UpdateUserRequest request,
  ) async {
    try {
      final response = await _dio.put('/users/$id', data: request.toJson());
      return UserSummaryResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _dio.delete('/users/$id');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
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
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      'filterRequest': jsonEncode(filterRequest.toJson()),
    };

    try {
      final response = await _dio.get(
        '/users',
        queryParameters: queryParameters,
      );
      return PageUserSummaryResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<UserDetailResponse> createUser(CreateUserRequest request) async {
    try {
      final response = await _dio.post('/users', data: request.toJson());
      return UserDetailResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }
}
