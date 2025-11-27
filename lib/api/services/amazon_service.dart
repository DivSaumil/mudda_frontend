import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/amazon_model.dart';

class AmazonImageService {
  final String baseUrl;

  AmazonImageService({required this.baseUrl});

  /// Get all bucket contents
  /// Returns a list of image file names
  Future<List<String>> getBucketContents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/amazon/images'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((item) => item.toString()).toList();
      } else {
        throw Exception('Failed to get bucket contents: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bucket contents: $e');
    }
  }

  /// Upload one or more images to Amazon S3
  /// Returns a list of uploaded AmazonImage objects
  Future<List<AmazonImage>> uploadImages(List<File> files) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/amazon/images'),
      );

      // Add all files to the request
      for (var file in files) {
        var multipartFile = await http.MultipartFile.fromPath(
          'files',
          file.path,
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((item) => AmazonImage.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to upload images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading images: $e');
    }
  }

  /// Upload a single image to Amazon S3
  /// Returns the uploaded AmazonImage object
  Future<AmazonImage> uploadImage(File file) async {
    final result = await uploadImages([file]);
    return result.first;
  }

  /// Delete an image from Amazon S3
  /// [fileName] is the name of the file to delete
  Future<void> deleteImage(String fileName) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/v1/amazon/images/$fileName'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        return; // Success
      } else if (response.statusCode == 503) {
        throw Exception('Service unavailable');
      } else {
        throw Exception('Failed to delete image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting image: $e');
    }
  }
}

