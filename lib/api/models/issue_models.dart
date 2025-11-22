class Issue{
  final String title;
  final String description;
  final int reporterId;
  final int locationId;
  final int categoryId;
  final List<String> mediaUrls;

  Issue({
    required this.title,
    required this.description,
    required this.reporterId,
    required this.locationId,
    required this.categoryId,
    required this.mediaUrls,
  });

  // Convert JSON to Dart object
  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      title: json['title'],
      description: json['description'],
      reporterId: json['reporter_id'],
      locationId: json['location_id'],
      categoryId: json['category_id'],
      mediaUrls: List<String>.from(json['media_urls']),
    );
  }

  //Convert Dart object to json
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "reporter_id": reporterId,
      "location_id": locationId,
      "category_id": categoryId,
      "media_urls": mediaUrls,
    };
  }
}