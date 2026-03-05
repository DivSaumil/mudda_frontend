import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/amazon_model.dart';

class AmazonImageService {
  final Dio _dio;

  AmazonImageService(this._dio);

  /// Upload a single image to Amazon S3.
  /// POST /api/v1/amazon/images
  /// Form field name: "file"
  /// Returns [ImageUploadResponse] with the fileKey to use in subsequent API calls.
  Future<ImageUploadResponse> uploadImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: file.name),
      });

      final response = await _dio.post('/amazon/images', data: formData);
      return ImageUploadResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload multiple images to Amazon S3 (batch).
  /// POST /api/v1/amazon/images/batch
  /// Form field name: "files"
  /// Returns [BatchImageUploadResponse] containing results for each file.
  Future<BatchImageUploadResponse> uploadImages(List<XFile> files) async {
    try {
      final formData = FormData();

      for (var file in files) {
        final bytes = await file.readAsBytes();
        formData.files.add(
          MapEntry(
            'files',
            MultipartFile.fromBytes(bytes, filename: file.name),
          ),
        );
      }

      final response = await _dio.post('/amazon/images/batch', data: formData);
      return BatchImageUploadResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  /// Delete an image from Amazon S3.
  /// DELETE /api/v1/amazon/images/{fileKey}
  Future<void> deleteImage(String fileKey) async {
    try {
      await _dio.delete('/amazon/images/$fileKey');
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}
