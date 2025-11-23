class RoleResponse {
  final int id;
  final String name;

  RoleResponse({required this.id, required this.name});

  factory RoleResponse.fromJson(Map<String, dynamic> json) {
    return RoleResponse(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class CreateRoleRequest {
  final String name;

  CreateRoleRequest({required this.name});

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}
