import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mudda_frontend/core/di/providers.dart';
import 'package:mudda_frontend/api/models/user_models.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';

part 'profile_notifier.g.dart';

/// State for user profile
class ProfileState {
  final AccountInfoResponse? profile;
  final PageIssueSummaryResponse? userIssues;
  final bool isLoading;
  final bool isIssuesLoading;
  final bool isUploadingImage;
  final String? error;
  final String? issuesError;
  final String? uploadError;

  const ProfileState({
    this.profile,
    this.userIssues,
    this.isLoading = false,
    this.isIssuesLoading = false,
    this.isUploadingImage = false,
    this.error,
    this.issuesError,
    this.uploadError,
  });

  ProfileState copyWith({
    AccountInfoResponse? profile,
    PageIssueSummaryResponse? userIssues,
    bool? isLoading,
    bool? isIssuesLoading,
    bool? isUploadingImage,
    String? error,
    String? issuesError,
    String? uploadError,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      userIssues: userIssues ?? this.userIssues,
      isLoading: isLoading ?? this.isLoading,
      isIssuesLoading: isIssuesLoading ?? this.isIssuesLoading,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      error: error,
      issuesError: issuesError,
      uploadError: uploadError,
    );
  }

  // Convenience getters for common profile fields
  String get username => profile?.username ?? 'User';
  String get name => profile?.name ?? '';
  String get email => profile?.email ?? '';
  String get role => profile?.role ?? 'CITIZEN';
  String get profileImageUrl => profile?.profileImageUrl ?? '';
}

/// Notifier for managing user profile state.
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  ProfileState build() {
    // Auto-fetch profile on build
    Future.microtask(() => fetchProfile());
    return const ProfileState(isLoading: true, isIssuesLoading: true);
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final accountService = ref.read(accountServiceProvider);
      final profile = await accountService.getMe();

      state = state.copyWith(isLoading: false, profile: profile);

      // Auto-fetch issues once profile is loaded
      fetchIssues();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchIssues({int page = 0, int size = 20}) async {
    state = state.copyWith(isIssuesLoading: true, issuesError: null);

    try {
      final accountService = ref.read(accountServiceProvider);
      final issues = await accountService.getMyIssues(page: page, size: size);

      state = state.copyWith(isIssuesLoading: false, userIssues: issues);
    } catch (e) {
      state = state.copyWith(isIssuesLoading: false, issuesError: e.toString());
    }
  }

  Future<bool> uploadProfilePicture(dynamic file) async {
    // We accept dynamic here to avoid importing image_picker in the notifier
    // it should be an XFile from image_picker.
    state = state.copyWith(isUploadingImage: true, uploadError: null);

    try {
      final amazonRepo = ref.read(amazonImageRepositoryProvider);
      final accountRepo = ref.read(accountRepositoryProvider);

      // 1. Upload to S3
      final uploadResponse = await amazonRepo.uploadImage(file);

      // 2. Update profile with new image key
      await accountRepo.updateProfileImage(uploadResponse.fileKey);

      // 3. Refresh profile to get the new image URL
      await fetchProfile();

      state = state.copyWith(isUploadingImage: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isUploadingImage: false,
        uploadError: e.toString(),
      );
      return false;
    }
  }

  Future<void> refresh() async {
    await fetchProfile();
  }
}
