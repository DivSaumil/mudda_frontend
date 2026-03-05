import '../models/user_models.dart';
import '../models/issue_models.dart';
import '../services/account_service.dart';

/// Repository for account-related operations (current user).
class AccountRepository {
  final AccountService _service;

  AccountRepository({required AccountService service}) : _service = service;

  /// Get current user's profile.
  Future<AccountInfoResponse> getMe() => _service.getMe();

  /// Update the current user's profile image.
  /// [imageKey] is the fileKey from the image upload API.
  Future<void> updateProfileImage(String imageKey) =>
      _service.updateProfileImage(imageKey);

  /// Get current user's issues (paginated).
  Future<PageIssueSummaryResponse> getMyIssues({
    int page = 0,
    int size = 20,
    String sortBy = 'CREATED_AT',
    String sortOrder = 'desc',
  }) => _service.getMyIssues(
    page: page,
    size: size,
    sortBy: sortBy,
    sortOrder: sortOrder,
  );

  /// Delete current user's account.
  Future<void> deleteAccount() => _service.deleteAccount();
}
