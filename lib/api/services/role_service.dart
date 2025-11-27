import 'package:dio/dio.dart';
import '../models/role_models.dart';

class RoleService {
  final Dio _dio;

  RoleService(this._dio);

  Future<List<RoleResponse>> getAllRoles({String? name}) async {
    final queryParams = <String, String>{};
    if (name != null) queryParams['name'] = name;

    try {
      final response = await _dio.get('/roles', queryParameters: queryParams);
      final List<dynamic> data = response.data;
      return data.map((e) => RoleResponse.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch roles: $e');
    }
  }

  Future<RoleResponse> createRole(CreateRoleRequest request) async {
    try {
      final response = await _dio.post('/roles', data: request.toJson());
      return RoleResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create role: $e');
    }
  }

  Future<RoleResponse> getRoleById(int id) async {
    try {
      final response = await _dio.get('/roles/$id');
      return RoleResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch role: $e');
    }
  }

  Future<void> deleteRole(int id) async {
    try {
      await _dio.delete('/roles/$id');
    } catch (e) {
      throw Exception('Failed to delete role: $e');
    }
  }
}
