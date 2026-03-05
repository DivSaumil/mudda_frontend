/// Response from uploading a single image via POST /api/v1/amazon/images
/// or each item in the batch upload response.
class ImageUploadResponse {
  final String originalFileName;
  final String fileKey;
  final String url;
  final String status; // "SUCCESS" | "FAILED"
  final String? errorMessage;

  ImageUploadResponse({
    required this.originalFileName,
    required this.fileKey,
    required this.url,
    required this.status,
    this.errorMessage,
  });

  bool get isSuccess => status == 'SUCCESS';

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) {
    return ImageUploadResponse(
      originalFileName: (json['originalFileName'] as String?) ?? '',
      fileKey: (json['fileKey'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'FAILED',
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalFileName': originalFileName,
      'fileKey': fileKey,
      'url': url,
      'status': status,
      'errorMessage': errorMessage,
    };
  }

  @override
  String toString() {
    return 'ImageUploadResponse(fileKey: $fileKey, status: $status)';
  }
}

/// Response from batch uploading images via POST /api/v1/amazon/images/batch
class BatchImageUploadResponse {
  final int successCount;
  final int failureCount;
  final List<ImageUploadResponse> results;

  BatchImageUploadResponse({
    required this.successCount,
    required this.failureCount,
    required this.results,
  });

  factory BatchImageUploadResponse.fromJson(Map<String, dynamic> json) {
    return BatchImageUploadResponse(
      successCount: (json['successCount'] as int?) ?? 0,
      failureCount: (json['failureCount'] as int?) ?? 0,
      results:
          (json['results'] as List<dynamic>?)
              ?.map(
                (item) =>
                    ImageUploadResponse.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}
