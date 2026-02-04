import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/amazon_model.dart';

class AmazonImageService {
  final Dio _dio;

  AmazonImageService(this._dio);

  /// Get all bucket contents
  /// Returns a list of image file names
  Future<List<String>> getBucketContents() async {
    try {
      final response = await _dio.get('/amazon/images');
      final List<dynamic> jsonList = response.data;
      return jsonList.map((item) => item.toString()).toList();
    } catch (e) {
      throw Exception('Failed to get bucket contents: $e');
    }
  }

  /// Upload one or more images to Amazon S3
  /// Returns a list of uploaded AmazonImage objects
  Future<List<AmazonImage>> uploadImages(List<XFile> files) async {
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

      // Use batch endpoint for multiple images
      final response = await _dio.post('/amazon/images/batch', data: formData);

      final List<dynamic> jsonList = response.data;
      return jsonList
          .map((item) => AmazonImage.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  /// Upload a single image to Amazon S3
  /// Returns the uploaded AmazonImage object
  Future<AmazonImage> uploadImage(XFile file) async {
    final result = await uploadImages([file]);
    return result.first;
  }

  /// Delete an image from Amazon S3
  /// [fileName] is the name of the file to delete
  Future<void> deleteImage(String fileName) async {
    try {
      await _dio.delete('/amazon/images/$fileName');
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}
