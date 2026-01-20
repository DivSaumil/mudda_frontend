import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mudda_frontend/core/di/providers.dart';
import 'package:mudda_frontend/features/issues/application/issue_state.dart';

part 'issue_list_notifier.g.dart';

@riverpod
class IssueListNotifier extends _$IssueListNotifier {
  int _page = 0;
  final int _pageSize = 20;

  @override
  IssueState build() {
    return const IssueState.initial();
  }

  Future<void> loadInitialIssues({String category = 'All'}) async {
    state = const IssueState.loading();
    _page = 0;

    try {
      final repository = ref.read(issueRepositoryProvider);
      final validCategory = category == 'All' ? null : category;

      final issues = await repository.fetchIssues(
        category: validCategory,
        page: _page,
        size: _pageSize,
      );

      state = IssueState.loaded(
        issues,
        hasMore: issues.length >= _pageSize,
        category: category,
      );
    } catch (e) {
      state = IssueState.error(e.toString());
    }
  }

  Future<void> refresh() async {
    final category = state.maybeMap(
      loaded: (loaded) => loaded.category,
      orElse: () => 'All',
    );

    await loadInitialIssues(category: category);
  }

  Future<void> loadMore() async {
    // Only proceed if loaded and has more
    final currentState = state;

    // Pattern match to extract data only if loaded
    await currentState.mapOrNull(
      loaded: (loaded) async {
        if (!loaded.hasMore) return;

        try {
          final repository = ref.read(issueRepositoryProvider);
          final nextpage = _page + 1;

          final validCategory = loaded.category == 'All'
              ? null
              : loaded.category;

          final newIssues = await repository.fetchIssues(
            category: validCategory,
            page: nextpage,
            size: _pageSize,
          );

          if (newIssues.isEmpty) {
            state = loaded.copyWith(hasMore: false);
          } else {
            _page = nextpage;
            state = loaded.copyWith(
              issues: [...loaded.issues, ...newIssues],
              hasMore: newIssues.length >= _pageSize,
            );
          }
        } catch (e) {
          // Error handling
        }
      },
    );
  }

  Future<void> filterByCategory(String category) async {
    final currentCat = state.maybeMap(
      loaded: (loaded) => loaded.category,
      orElse: () => null,
    );

    if (currentCat == category) return;
    await loadInitialIssues(category: category);
  }
}
