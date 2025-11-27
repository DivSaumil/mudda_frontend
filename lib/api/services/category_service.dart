import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/category_models.dart';

class CategoryService {
  final Dio _dio;

  CategoryService(this._dio);

  Future<List<CategoryResponse>> getAll({String? search}) async {
    final queryParams = <String, String>{};
    if (search != null) queryParams['search'] = search;

    try {
      final response = await _dio.get(
        '/issues/categories',
        queryParameters: queryParams,
      );
      final data = response.data as List;
      return data.map((e) => CategoryResponse.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<CategoryResponse> getById(int id) async {
    try {
      final response = await _dio.get('/issues/categories/$id');
      return CategoryResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch category: $e');
    }
  }

  Future<CategoryResponse> create(CreateCategoryRequest request) async {
    try {
      final response = await _dio.post(
        '/issues/categories',
        data: request.toJson(),
      );
      return CategoryResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete('/issues/categories/$id');
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}
