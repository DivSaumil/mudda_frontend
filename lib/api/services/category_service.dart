import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_models.dart';

class CategoryService {
  final String baseUrl;

  CategoryService({required this.baseUrl});

  Future<List<CategoryResponse>> getAll({String? search}) async {
    final queryParams = <String, String>{};
    if (search != null) queryParams['search'] = search;

    final url = Uri.parse('$baseUrl/api/v1/issues/categories')
        .replace(queryParameters: queryParams);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => CategoryResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch categories: ${response.body}');
    }
  }

  Future<CategoryResponse> getById(int id) async {
    final url = Uri.parse('$baseUrl/api/v1/issues/categories/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return CategoryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch category: ${response.body}');
    }
  }

  Future<CategoryResponse> create(CreateCategoryRequest request) async {
    final url = Uri.parse('$baseUrl/api/v1/issues/categories');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CategoryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create category: ${response.body}');
    }
  }

  Future<void> delete(int id) async {
    final url = Uri.parse('$baseUrl/api/v1/issues/categories/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete category: ${response.body}');
    }
  }
}
