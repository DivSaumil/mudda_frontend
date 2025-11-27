class AmazonImage {
  final String imageName;
  final String imageUrl;

  AmazonImage({
    required this.imageName,
    required this.imageUrl,
  });

  factory AmazonImage.fromJson(Map<String, dynamic> json) {
    return AmazonImage(
      imageName: json['imageName'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageName': imageName,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() {
    return 'AmazonImage(imageName: $imageName, imageUrl: $imageUrl)';
  }
}

