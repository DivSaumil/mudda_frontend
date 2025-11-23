import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_models.dart';

class LocationService {
  final String baseUrl;

  LocationService({required this.baseUrl});

  Future<LocationResponse> getLocationById(int id) async {
    final url = Uri.parse('$baseUrl/api/v1/locations/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return LocationResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch location: ${response.body}');
    }
  }

  Future<LocationResponse> createLocation(CreateLocationRequest request) async {
    final url = Uri.parse('$baseUrl/api/v1/locations');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return LocationResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create location: ${response.body}');
    }
  }

  Future<LocationResponse> updateLocation(int id, UpdateLocationRequest request) async {
    final url = Uri.parse('$baseUrl/api/v1/locations/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return LocationResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update location: ${response.body}');
    }
  }

  Future<void> deleteLocation(int id) async {
    final url = Uri.parse('$baseUrl/api/v1/locations/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete location: ${response.body}');
    }
  }

  Future<List<LocationResponse>> getAllLocations() async {
    final url = Uri.parse('$baseUrl/api/v1/locations');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => LocationResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch locations: ${response.body}');
    }
  }
}
