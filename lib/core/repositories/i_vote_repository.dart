import 'package:mudda_frontend/api/models/vote_models.dart';

/// Abstract interface for vote data operations.
abstract class IVoteRepository {
  /// Creates a vote for an issue.
  Future<VoteResponse> createVote(int issueId);

  /// Removes a vote from an issue.
  Future<VoteResponse> deleteVote(int issueId);

  /// Gets paginated list of votes.
  Future<PageVote> getVotes({int page = 0, int size = 20});

  /// Gets a single vote by ID.
  Future<Vote> getVote(int voteId);

  /// Deletes a vote by its ID.
  Future<void> deleteVoteById(int voteId);
}
