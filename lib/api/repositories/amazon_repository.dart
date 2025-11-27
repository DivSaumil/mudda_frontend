import 'dart:io';
import '../models/amazon_model.dart';
import '../services/amazon_service.dart';

class AmazonImageRepository {
  final AmazonImageService _service;

  AmazonImageRepository({required AmazonImageService service})
      : _service = service;

  /// Get all bucket contents
  /// Returns a list of image file names
  Future<List<String>> getBucketContents() async {
    try {
      return await _service.getBucketContents();
    } catch (e) {
      throw Exception('Repository error: Failed to get bucket contents - $e');
    }
  }

  /// Upload one or more images to Amazon S3
  /// Returns a list of uploaded AmazonImage objects
  Future<List<AmazonImage>> uploadImages(List<File> files) async {
    try {
      if (files.isEmpty) {
        throw Exception('No files provided for upload');
      }
      return await _service.uploadImages(files);
    } catch (e) {
      throw Exception('Repository error: Failed to upload images - $e');
    }
  }

  /// Upload a single image to Amazon S3
  /// Returns the uploaded AmazonImage object
  Future<AmazonImage> uploadImage(File file) async {
    try {
      return await _service.uploadImage(file);
    } catch (e) {
      throw Exception('Repository error: Failed to upload image - $e');
    }
  }

  /// Delete an image from Amazon S3
  /// [fileName] is the name of the file to delete
  Future<void> deleteImage(String fileName) async {
    try {
      if (fileName.isEmpty) {
        throw Exception('File name cannot be empty');
      }
      await _service.deleteImage(fileName);
    } catch (e) {
      throw Exception('Repository error: Failed to delete image - $e');
    }
  }
}

