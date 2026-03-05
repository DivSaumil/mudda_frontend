import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/core/di/providers.dart';

part 'create_issue_notifier.g.dart';

/// State for issue creation form
class CreateIssueState {
  final String title;
  final String description;
  final int? categoryId;
  final int? locationId;
  final List<String> imageKeys;
  final bool isSubmitting;
  final String? error;
  final IssueResponse? createdIssue;

  const CreateIssueState({
    this.title = '',
    this.description = '',
    this.categoryId,
    this.locationId,
    this.imageKeys = const [],
    this.isSubmitting = false,
    this.error,
    this.createdIssue,
  });

  CreateIssueState copyWith({
    String? title,
    String? description,
    int? categoryId,
    int? locationId,
    List<String>? imageKeys,
    bool? isSubmitting,
    String? error,
    IssueResponse? createdIssue,
  }) {
    return CreateIssueState(
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      locationId: locationId ?? this.locationId,
      imageKeys: imageKeys ?? this.imageKeys,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      createdIssue: createdIssue,
    );
  }

  bool get isValid => title.trim().isNotEmpty && description.trim().isNotEmpty;
}

/// Notifier for managing issue creation state.
@riverpod
class CreateIssueNotifier extends _$CreateIssueNotifier {
  @override
  CreateIssueState build() {
    return const CreateIssueState();
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateContent(String description) {
    state = state.copyWith(description: description);
  }

  void updateCategory(int? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void updateLocation(int? locationId) {
    state = state.copyWith(locationId: locationId);
  }

  void updateSeverity(int score) {
    // Severity is no longer sent in create request (v1.1)
    // Keeping method signature for UI compatibility
  }

  void updateUrgency(bool urgent) {
    // Urgency is no longer sent in create request (v1.1)
    // Keeping method signature for UI compatibility
  }

  void addImageKey(String key) {
    state = state.copyWith(imageKeys: [...state.imageKeys, key]);
  }

  void removeImageKey(String key) {
    state = state.copyWith(
      imageKeys: state.imageKeys.where((k) => k != key).toList(),
    );
  }

  void clearImages() {
    state = state.copyWith(imageKeys: []);
  }

  /// Submits the issue to the backend.
  Future<bool> submitIssue() async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Title and content are required');
      return false;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final repository = ref.read(issueRepositoryProvider);
      final request = CreateIssueRequest(
        title: state.title.trim(),
        description: state.description.trim(),
        categoryId: state.categoryId,
        locationId: state.locationId,
        mediaUrls: state.imageKeys,
      );

      final issue = await repository.createIssue(request);

      state = state.copyWith(isSubmitting: false, createdIssue: issue);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  /// Resets form to initial state.
  void reset() {
    state = const CreateIssueState();
  }
}
