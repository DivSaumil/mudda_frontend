import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';

/// Service for caching issues locally using SharedPreferences.
///
/// Enables offline viewing of previously loaded issues by storing
/// them as JSON strings keyed by category or issue ID.
class IssueCacheService {
  static const _issueListPrefix = 'cached_issues_';
  static const _issueDetailPrefix = 'cached_issue_';
  static const _timestampSuffix = '_timestamp';

  /// Cache a list of issues for the given category.
  Future<void> cacheIssues(
    List<IssueResponse> issues, {
    String category = 'All',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_issueListPrefix$category';
      final jsonList = issues.map((issue) => issue.toJson()).toList();
      await prefs.setString(key, jsonEncode(jsonList));
      await prefs.setInt(
        '$key$_timestampSuffix',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Error caching issues: $e');
    }
  }

  /// Retrieve cached issues for the given category.
  /// Returns null if no cached data exists.
  Future<List<IssueResponse>?> getCachedIssues({
    String category = 'All',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_issueListPrefix$category';
      final jsonString = prefs.getString(key);

      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => IssueResponse.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error reading cached issues: $e');
      return null;
    }
  }

  /// Cache a single issue detail by its ID.
  Future<void> cacheIssueDetail(IssueResponse issue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_issueDetailPrefix${issue.id}';
      await prefs.setString(key, jsonEncode(issue.toJson()));
      await prefs.setInt(
        '$key$_timestampSuffix',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Error caching issue detail: $e');
    }
  }

  /// Retrieve a cached single issue by its ID.
  /// Returns null if no cached data exists.
  Future<IssueResponse?> getCachedIssueDetail(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_issueDetailPrefix$id';
      final jsonString = prefs.getString(key);

      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return IssueResponse.fromJson(json);
    } catch (e) {
      debugPrint('Error reading cached issue detail: $e');
      return null;
    }
  }

  /// Get the timestamp (in milliseconds since epoch) when the cache
  /// for the given key was last updated, or null if not cached.
  Future<int?> getCacheTimestamp(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('$key$_timestampSuffix');
    } catch (e) {
      return null;
    }
  }

  /// Clear all cached issue data.
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_issueListPrefix) ||
            key.startsWith(_issueDetailPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('Error clearing issue cache: $e');
    }
  }
}
