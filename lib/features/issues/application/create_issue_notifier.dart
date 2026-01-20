import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/core/di/providers.dart';

part 'create_issue_notifier.g.dart';

/// State for issue creation form
class CreateIssueState {
  final String title;
  final String content;
  final int? categoryId;
  final int? locationId;
  final int severityScore;
  final bool urgencyFlag;
  final List<String> imageUrls;
  final bool isSubmitting;
  final String? error;
  final IssueResponse? createdIssue;

  const CreateIssueState({
    this.title = '',
    this.content = '',
    this.categoryId,
    this.locationId,
    this.severityScore = 1,
    this.urgencyFlag = false,
    this.imageUrls = const [],
    this.isSubmitting = false,
    this.error,
    this.createdIssue,
  });

  CreateIssueState copyWith({
    String? title,
    String? content,
    int? categoryId,
    int? locationId,
    int? severityScore,
    bool? urgencyFlag,
    List<String>? imageUrls,
    bool? isSubmitting,
    String? error,
    IssueResponse? createdIssue,
  }) {
    return CreateIssueState(
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: categoryId ?? this.categoryId,
      locationId: locationId ?? this.locationId,
      severityScore: severityScore ?? this.severityScore,
      urgencyFlag: urgencyFlag ?? this.urgencyFlag,
      imageUrls: imageUrls ?? this.imageUrls,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      createdIssue: createdIssue,
    );
  }

  bool get isValid => title.trim().isNotEmpty && content.trim().isNotEmpty;
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

  void updateContent(String content) {
    state = state.copyWith(content: content);
  }

  void updateCategory(int? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void updateLocation(int? locationId) {
    state = state.copyWith(locationId: locationId);
  }

  void updateSeverity(int score) {
    state = state.copyWith(severityScore: score);
  }

  void updateUrgency(bool urgent) {
    state = state.copyWith(urgencyFlag: urgent);
  }

  void addImageUrl(String url) {
    state = state.copyWith(imageUrls: [...state.imageUrls, url]);
  }

  void removeImageUrl(String url) {
    state = state.copyWith(
      imageUrls: state.imageUrls.where((u) => u != url).toList(),
    );
  }

  void clearImages() {
    state = state.copyWith(imageUrls: []);
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
        content: state.content.trim(),
        categoryId: state.categoryId,
        locationId: state.locationId,
        severityScore: state.severityScore,
        urgencyFlag: state.urgencyFlag,
        mediaUrls: state.imageUrls,
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
