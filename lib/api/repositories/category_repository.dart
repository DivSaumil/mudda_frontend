import '../models/category_models.dart';
import '../services/category_service.dart';

class CategoryRepository {
  final CategoryService service;

  CategoryRepository({required this.service});

  Future<List<CategoryResponse>> fetchCategories({String? search}) async {
    return await service.getAll(search: search);
  }

  Future<CategoryResponse> getCategory(int id) async {
    return await service.getById(id);
  }

  Future<CategoryResponse> createCategory(CreateCategoryRequest request) async {
    return await service.create(request);
  }

  Future<void> deleteCategory(int id) async {
    return await service.delete(id);
  }
}
