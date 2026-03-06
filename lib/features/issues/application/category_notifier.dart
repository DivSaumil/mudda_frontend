import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mudda_frontend/api/models/category_models.dart';
import 'package:mudda_frontend/core/di/providers.dart';

part 'category_notifier.g.dart';

/// Shared provider that fetches categories from the backend and caches them
/// in SharedPreferences. Both the issue feed and create-issue screens
/// watch this provider to stay in sync.
@Riverpod(keepAlive: true)
class CategoryNotifier extends _$CategoryNotifier {
  static const _cacheKey = 'cached_categories';

  @override
  Future<List<CategoryResponse>> build() async {
    return _fetchAndCache();
  }

  Future<List<CategoryResponse>> _fetchAndCache() async {
    try {
      final service = ref.read(categoryServiceProvider);
      final categories = await service.getAll();

      // Cache for offline use
      _cacheCategories(categories);

      return categories;
    } catch (e) {
      debugPrint('Failed to fetch categories, trying cache: $e');
      final cached = await _getCachedCategories();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  /// Force a refresh from the backend.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAndCache());
  }

  Future<void> _cacheCategories(List<CategoryResponse> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = categories.map((c) => c.toJson()).toList();
      await prefs.setString(_cacheKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error caching categories: $e');
    }
  }

  Future<List<CategoryResponse>?> _getCachedCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((e) => CategoryResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error reading cached categories: $e');
      return null;
    }
  }
}
