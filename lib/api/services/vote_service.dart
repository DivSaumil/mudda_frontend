import 'package:dio/dio.dart';
import 'package:mudda_frontend/api/models/vote_models.dart';

class VoteService {
  final Dio _dio;

  VoteService(this._dio);

  Future<VoteResponse> createVote(int issueId) async {
    try {
      final response = await _dio.post('/issues/$issueId/votes');
      return VoteResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create vote: $e');
    }
  }

  Future<VoteResponse> deleteVote(int issueId) async {
    try {
      final response = await _dio.delete('/issues/$issueId/votes');
      return VoteResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to delete vote: $e');
    }
  }

  Future<PageVote> getAllVotes({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        '/votes',
        queryParameters: {'page': page, 'size': size},
      );
      return PageVote.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch votes: $e');
    }
  }

  Future<Vote> getVoteById(int voteId) async {
    try {
      final response = await _dio.get('/votes/$voteId');
      return Vote.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch vote: $e');
    }
  }

  Future<void> deleteVoteById(int voteId) async {
    try {
      await _dio.delete('/votes/$voteId');
    } catch (e) {
      throw Exception('Failed to delete vote: $e');
    }
  }
}
