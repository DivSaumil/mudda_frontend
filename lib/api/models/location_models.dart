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
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Location',
      address: json['address'] ?? 'Unknown Address',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
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

class CoordinateDTO {
  final double latitude;
  final double longitude;

  CoordinateDTO({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}

class CreateLocationRequest {
  final String pinCode;
  final String addressLine;
  final String state;
  final String city;
  final CoordinateDTO coordinate;

  CreateLocationRequest({
    required this.pinCode,
    required this.addressLine,
    required this.state,
    required this.city,
    required this.coordinate,
  });

  Map<String, dynamic> toJson() => {
    'pin_code': pinCode,
    'address_line': addressLine,
    'state': state,
    'city': city,
    'coordinate': coordinate.toJson(),
  };
}

class UpdateLocationRequest {
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;

  UpdateLocationRequest({
    this.name,
    this.address,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (address != null) 'address': address,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
  };
}
