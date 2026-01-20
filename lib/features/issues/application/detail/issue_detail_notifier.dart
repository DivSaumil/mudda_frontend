import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';
import 'package:mudda_frontend/core/di/providers.dart';

part 'issue_detail_notifier.g.dart';

/// State for viewing a single issue detail
class IssueDetailState {
  final int issueId;
  final IssueResponse? issue;
  final bool isLoading;
  final String? error;

  const IssueDetailState({
    required this.issueId,
    this.issue,
    this.isLoading = false,
    this.error,
  });

  IssueDetailState copyWith({
    IssueResponse? issue,
    bool? isLoading,
    String? error,
  }) {
    return IssueDetailState(
      issueId: issueId,
      issue: issue ?? this.issue,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing single issue detail state.
@riverpod
class IssueDetailNotifier extends _$IssueDetailNotifier {
  @override
  IssueDetailState build(int issueId, {IssueResponse? initialIssue}) {
    // If initial issue provided, use it but still fetch full details
    if (initialIssue != null) {
      Future.microtask(() => fetchFullDetails());
      return IssueDetailState(issueId: issueId, issue: initialIssue);
    }
    return IssueDetailState(issueId: issueId);
  }

  /// Fetches full issue details from the API.
  Future<void> fetchFullDetails() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(issueRepositoryProvider);
      final issue = await repository.getIssue(state.issueId);

      state = state.copyWith(isLoading: false, issue: issue);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refreshes the issue details.
  Future<void> refresh() async {
    await fetchFullDetails();
  }
}
