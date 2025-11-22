import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/issue_model.dart';

class ApiService{
  final String baseUrl= AppConstants.baseUrl;

  Future<List<Issue>> fetchIssues() async{
    final response = await http.get(Uri.parse('$baseUrl/issues'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Issue.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load issues");
    }
  }

  Future<bool> createIssue(Issue issue) async {
    final response = await http.post(
      Uri.parse('$baseUrl/issues'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(issue.toJson()),
    );
    return response.statusCode == 201;
  }

}