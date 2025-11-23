import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/role_models.dart';

class RoleService {
  final String baseUrl;

  RoleService({required this.baseUrl});

  Future<List<RoleResponse>> getAllRoles({String? name}) async {
    final url = Uri.parse('$baseUrl/api/v1/roles${name != null ? '?name=$name' : ''}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => RoleResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch roles: ${response.body}');
    }
  }

  Future<RoleResponse> createRole(CreateRoleRequest request) async {
    final url = Uri.parse('$baseUrl/api/v1/roles');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return RoleResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create role: ${response.body}');
    }
  }

  Future<RoleResponse> getRoleById(int id) async {
    final url = Uri.parse('$baseUrl/api/v1/roles/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return RoleResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch role: ${response.body}');
    }
  }

  Future<void> deleteRole(int id) async {
    final url = Uri.parse('$baseUrl/api/v1/roles/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete role: ${response.body}');
    }
  }
}
