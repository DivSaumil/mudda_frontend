import 'package:mudda_frontend/api/models/vote_models.dart';
import 'package:mudda_frontend/api/services/vote_service.dart';

class VoteRepository {
  final VoteService voteService = VoteService();

  Future<int> getVotes(int issueId) => voteService.fetchVotes(issueId);
  Future<Vote?> addVote(int issueId, int userId) => voteService.addVote(issueId, userId);
}
