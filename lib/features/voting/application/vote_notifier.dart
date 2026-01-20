import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mudda_frontend/core/di/providers.dart';

part 'vote_notifier.g.dart';

/// State of a single vote - tracks count and whether user has voted
class VoteState {
  final int issueId;
  final int voteCount;
  final bool hasVoted;
  final bool isLoading;

  const VoteState({
    required this.issueId,
    required this.voteCount,
    required this.hasVoted,
    this.isLoading = false,
  });

  VoteState copyWith({int? voteCount, bool? hasVoted, bool? isLoading}) {
    return VoteState(
      issueId: issueId,
      voteCount: voteCount ?? this.voteCount,
      hasVoted: hasVoted ?? this.hasVoted,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier for managing votes on a specific issue.
/// Uses optimistic updates for better UX.
@riverpod
class VoteNotifier extends _$VoteNotifier {
  @override
  VoteState build(
    int issueId, {
    required int initialCount,
    required bool initialHasVoted,
  }) {
    return VoteState(
      issueId: issueId,
      voteCount: initialCount,
      hasVoted: initialHasVoted,
    );
  }

  Future<void> toggleVote() async {
    if (state.isLoading) return;

    final repository = ref.read(voteRepositoryProvider);
    final wasVoted = state.hasVoted;

    // Optimistic update
    state = state.copyWith(
      isLoading: true,
      hasVoted: !wasVoted,
      voteCount: wasVoted ? state.voteCount - 1 : state.voteCount + 1,
    );

    try {
      if (!wasVoted) {
        await repository.createVote(state.issueId);
      } else {
        await repository.deleteVote(state.issueId);
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      // Revert on error
      state = state.copyWith(
        isLoading: false,
        hasVoted: wasVoted,
        voteCount: wasVoted ? state.voteCount + 1 : state.voteCount - 1,
      );
      rethrow;
    }
  }
}
