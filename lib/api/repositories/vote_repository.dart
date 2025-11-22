import '../models/vote_model.dart';
import '../services/vote_service.dart';

class VoteRepository {
  final VoteService voteService = VoteService();

  Future<int> getVotes(int issueId) => voteService.fetchVotes(issueId);
  Future<Vote?> addVote(int issueId, int userId) => voteService.addVote(issueId, userId);
}
