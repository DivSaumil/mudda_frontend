import '../models/vote_models.dart';
import '../services/vote_service.dart';

class VoteRepository {
  final VoteService service;

  VoteRepository({required this.service});

  Future<VoteResponse> createVote(int issueId) => service.createVote(issueId);

  Future<VoteResponse> deleteVote(int issueId) => service.deleteVote(issueId);

  Future<PageVote> getVotes({int page = 0, int size = 20}) =>
      service.getAllVotes(page: page, size: size);

  Future<Vote> getVote(int voteId) => service.getVoteById(voteId);

  Future<void> deleteVoteById(int voteId) => service.deleteVoteById(voteId);
}
