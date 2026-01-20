import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mudda_frontend/api/models/comment_models.dart';
import 'package:mudda_frontend/core/di/providers.dart';

part 'comment_notifier.g.dart';

/// State for comments on an issue
class CommentState {
  final int issueId;
  final List<CommentResponse> comments;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const CommentState({
    required this.issueId,
    this.comments = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
  });

  CommentState copyWith({
    List<CommentResponse>? comments,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return CommentState(
      issueId: issueId,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}

/// Notifier for managing comments on a specific issue.
@riverpod
class CommentNotifier extends _$CommentNotifier {
  static const int _pageSize = 20;

  @override
  CommentState build(int issueId) {
    return CommentState(issueId: issueId);
  }

  /// Fetches initial comments for the issue.
  Future<void> fetchComments() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(commentRepositoryProvider);
      final page = await repository.getCommentsByIssue(
        state.issueId,
        page: 0,
        size: _pageSize,
      );

      state = state.copyWith(
        isLoading: false,
        comments: page.comments,
        hasMore: page.comments.length >= _pageSize,
        currentPage: 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Loads more comments (pagination).
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(commentRepositoryProvider);
      final nextPage = state.currentPage + 1;
      final page = await repository.getCommentsByIssue(
        state.issueId,
        page: nextPage,
        size: _pageSize,
      );

      state = state.copyWith(
        isLoading: false,
        comments: [...state.comments, ...page.comments],
        hasMore: page.comments.length >= _pageSize,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Posts a new comment to the issue.
  Future<void> postComment(String content) async {
    if (content.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(commentRepositoryProvider);
      final newComment = await repository.createComment(
        state.issueId,
        CreateCommentRequest(content: content),
      );

      // Add to top of list
      state = state.copyWith(
        isLoading: false,
        comments: [newComment, ...state.comments],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Deletes a comment.
  Future<void> deleteComment(int commentId) async {
    try {
      final repository = ref.read(commentRepositoryProvider);
      await repository.deleteComment(commentId);

      state = state.copyWith(
        comments: state.comments.where((c) => c.id != commentId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}
