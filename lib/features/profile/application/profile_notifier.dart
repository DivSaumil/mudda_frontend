import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mudda_frontend/core/di/providers.dart';
import 'package:mudda_frontend/api/services/auth_service.dart';

part 'profile_notifier.g.dart';

/// State for user profile
class ProfileState {
  final Map<String, dynamic>? profile;
  final bool isLoading;
  final String? error;

  const ProfileState({this.profile, this.isLoading = false, this.error});

  ProfileState copyWith({
    Map<String, dynamic>? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Convenience getters for common profile fields
  String get username => profile?['userName'] ?? 'User';
  String get name => profile?['name'] ?? '';
  String get email => profile?['email'] ?? '';
  String? get profileImageUrl => profile?['profileImageUrl'];
}

/// Notifier for managing user profile state.
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  ProfileState build() {
    // Auto-fetch profile on build
    Future.microtask(() => fetchProfile());
    return const ProfileState(isLoading: true);
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final storage = ref.read(storageServiceProvider);
      final dio = ref.read(dioProvider);
      final authService = AuthService(dio: dio, storageService: storage);

      final profile = await authService.getProfile();

      state = state.copyWith(isLoading: false, profile: profile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await fetchProfile();
  }
}
