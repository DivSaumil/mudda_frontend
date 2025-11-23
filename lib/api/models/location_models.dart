class LocationResponse {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  LocationResponse({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      };
}

class CreateLocationRequest {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  CreateLocationRequest({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      };
}

class UpdateLocationRequest {
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;

  UpdateLocationRequest({this.name, this.address, this.latitude, this.longitude});

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (address != null) 'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
}
