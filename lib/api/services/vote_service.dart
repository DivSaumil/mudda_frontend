import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vote_models.dart';

class VoteService {
  final String baseUrl;

  VoteService({required this.baseUrl});

  Future<VoteResponse> createVote(int issueId) async {
    final url = Uri.parse('$baseUrl/api/v1/issues/$issueId/votes');
    final response = await http.post(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return VoteResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create vote: ${response.body}');
    }
  }

  Future<VoteResponse> deleteVote(int issueId) async {
    final url = Uri.parse('$baseUrl/api/v1/issues/$issueId/votes');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return VoteResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to delete vote: ${response.body}');
    }
  }

  Future<PageVote> getAllVotes({int page = 0, int size = 20}) async {
    final url = Uri.parse('$baseUrl/api/v1/votes?page=$page&size=$size');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return PageVote.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch votes: ${response.body}');
    }
  }

  Future<Vote> getVoteById(int voteId) async {
    final url = Uri.parse('$baseUrl/api/v1/votes/$voteId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Vote.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch vote: ${response.body}');
    }
  }

  Future<void> deleteVoteById(int voteId) async {
    final url = Uri.parse('$baseUrl/api/v1/votes/$voteId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete vote: ${response.body}');
    }
  }
}
