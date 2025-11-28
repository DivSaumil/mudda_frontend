import 'package:dio/dio.dart';
import '../models/location_models.dart';

class LocationService {
  final Dio _dio;

  LocationService(this._dio);

  Future<LocationResponse> getLocationById(int id) async {
    try {
      final response = await _dio.get('/locations/$id');
      return LocationResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch location: $e');
    }
  }

  Future<LocationResponse> createLocation(CreateLocationRequest request) async {
    try {
      final response = await _dio.post('/locations', data: request.toJson());

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to create location: ${response.statusCode} - ${response.data}',
        );
      }

      if (response.data is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response format: Expected Map, got ${response.data.runtimeType} - Body: ${response.data}',
        );
      }

      return LocationResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create location: $e');
    }
  }

  Future<LocationResponse> updateLocation(
    int id,
    UpdateLocationRequest request,
  ) async {
    try {
      final response = await _dio.put('/locations/$id', data: request.toJson());
      return LocationResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  Future<void> deleteLocation(int id) async {
    try {
      await _dio.delete('/locations/$id');
    } catch (e) {
      throw Exception('Failed to delete location: $e');
    }
  }

  Future<List<LocationResponse>> getAllLocations() async {
    try {
      final response = await _dio.get('/locations');
      final List<dynamic> data = response.data;
      return data.map((e) => LocationResponse.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch locations: $e');
    }
  }
}
