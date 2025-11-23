import '../models/location_models.dart';
import '../services/location_service.dart';

class LocationRepository {
  final LocationService service;

  LocationRepository({required this.service});

  Future<LocationResponse> getLocation(int id) => service.getLocationById(id);

  Future<LocationResponse> createLocation(CreateLocationRequest request) =>
      service.createLocation(request);

  Future<LocationResponse> updateLocation(int id, UpdateLocationRequest request) =>
      service.updateLocation(id, request);

  Future<void> deleteLocation(int id) => service.deleteLocation(id);

  Future<List<LocationResponse>> getAllLocations() => service.getAllLocations();
}
