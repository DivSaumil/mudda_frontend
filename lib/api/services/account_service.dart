import 'package:dio/dio.dart';
import '../models/user_models.dart';
import '../models/issue_models.dart';

/// Service for the /api/v1/account endpoints (current user operations).
class AccountService {
  final Dio _dio;

  AccountService(this._dio);

  /// GET /api/v1/account/me
  /// Returns the current authenticated user's profile.
  Future<AccountInfoResponse> getMe() async {
    try {
      final response = await _dio.get('/account/me');
      return AccountInfoResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  /// PATCH /api/v1/account/me/profileImage
  /// Updates the current user's profile image.
  /// [imageKey] is the fileKey obtained from the image upload API.
  Future<void> updateProfileImage(String imageKey) async {
    try {
      await _dio.patch(
        '/account/me/profileImage',
        data: {'imageKey': imageKey},
      );
    } catch (e) {
      throw Exception('Failed to update profile image: $e');
    }
  }

  /// GET /api/v1/account/me/issues
  /// Returns the current user's issues (paginated).
  Future<PageIssueSummaryResponse> getMyIssues({
    int page = 0,
    int size = 20,
    String sortBy = 'CREATED_AT',
    String sortOrder = 'desc',
  }) async {
    try {
      final response = await _dio.get(
        '/account/me/issues',
        queryParameters: {
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'sortOrder': sortOrder,
        },
      );
      return PageIssueSummaryResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Failed to fetch user issues: $e');
    }
  }

  /// DELETE /api/v1/account
  /// Deletes the current user's account.
  Future<void> deleteAccount() async {
    try {
      await _dio.delete('/account');
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
