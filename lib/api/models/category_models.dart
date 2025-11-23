class CategoryResponse {
  final int id;
  final String name;
  final String? description;

  CategoryResponse({
    required this.id,
    required this.name,
    this.description,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
    };
  }
}

class CreateCategoryRequest {
  final String name;
  final String? description;

  CreateCategoryRequest({required this.name, this.description});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
    };
  }
}
