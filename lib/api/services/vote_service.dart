import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import 'package:mudda_frontend/api/models/vote_models.dart';

class VoteService {
  final String baseUrl = AppConstants.baseUrl;

  Future<int> fetchVotes(int issueId) async {
    final response = await http.get(Uri.parse('$baseUrl/issues/$issueId/votes'));
    if (response.statusCode == 200) {
      return int.parse(response.body); // since API returns an integer
    } else {
      throw Exception("Failed to load votes");
    }
  }

  Future<Vote?> addVote(int issueId, int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/issues/$issueId/votes/$userId'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 201) {
      return Vote.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }
}
