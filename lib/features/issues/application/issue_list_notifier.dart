import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mudda_frontend/core/di/providers.dart';
import 'package:mudda_frontend/features/issues/application/issue_state.dart';

part 'issue_list_notifier.g.dart';

@riverpod
class IssueListNotifier extends _$IssueListNotifier {
  int _page = 0;
  final int _pageSize = 20;
  int? _currentCategoryId;

  @override
  IssueState build() {
    return const IssueState.initial();
  }

  Future<void> loadInitialIssues({
    String category = 'All',
    int? categoryId,
  }) async {
    state = const IssueState.loading();
    _page = 0;
    _currentCategoryId = categoryId;

    try {
      final repository = ref.read(issueRepositoryProvider);

      final result = await repository.fetchIssues(
        category: category,
        categoryId: categoryId,
        page: _page,
        size: _pageSize,
      );

      state = IssueState.loaded(
        result.issues,
        hasMore: result.issues.length >= _pageSize,
        category: category,
        isOffline: result.isFromCache,
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
        if (!loaded.hasMore || loaded.isOffline) return;

        try {
          final repository = ref.read(issueRepositoryProvider);
          final nextpage = _page + 1;

          final result = await repository.fetchIssues(
            category: loaded.category,
            categoryId: _currentCategoryId,
            page: nextpage,
            size: _pageSize,
          );

          if (result.issues.isEmpty) {
            state = loaded.copyWith(hasMore: false);
          } else {
            _page = nextpage;
            state = loaded.copyWith(
              issues: [...loaded.issues, ...result.issues],
              hasMore: result.issues.length >= _pageSize,
            );
          }
        } catch (e) {
          // Error handling — don't break existing loaded state
        }
      },
    );
  }

  Future<void> filterByCategory(String category, {int? categoryId}) async {
    final currentCat = state.maybeMap(
      loaded: (loaded) => loaded.category,
      orElse: () => null,
    );

    if (currentCat == category) return;
    await loadInitialIssues(category: category, categoryId: categoryId);
  }
}
