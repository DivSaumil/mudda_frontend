import 'package:image_picker/image_picker.dart';
import '../models/amazon_model.dart';
import '../services/amazon_service.dart';

class AmazonImageRepository {
  final AmazonImageService _service;

  AmazonImageRepository({required AmazonImageService service})
    : _service = service;

  /// Upload a single image to Amazon S3.
  /// Returns [ImageUploadResponse] containing the fileKey.
  Future<ImageUploadResponse> uploadImage(XFile file) async {
    try {
      return await _service.uploadImage(file);
    } catch (e) {
      throw Exception('Repository error: Failed to upload image - $e');
    }
  }

  /// Upload multiple images to Amazon S3 (batch).
  /// Returns [BatchImageUploadResponse] containing results for each file.
  Future<BatchImageUploadResponse> uploadImages(List<XFile> files) async {
    try {
      if (files.isEmpty) {
        throw Exception('No files provided for upload');
      }
      return await _service.uploadImages(files);
    } catch (e) {
      throw Exception('Repository error: Failed to upload images - $e');
    }
  }

  /// Delete an image from Amazon S3 by its fileKey.
  Future<void> deleteImage(String fileKey) async {
    try {
      if (fileKey.isEmpty) {
        throw Exception('File key cannot be empty');
      }
      await _service.deleteImage(fileKey);
    } catch (e) {
      throw Exception('Repository error: Failed to delete image - $e');
    }
  }
}
