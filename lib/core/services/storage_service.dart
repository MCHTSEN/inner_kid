import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _logger = Logger();

  // Storage paths
  static const String drawingsPath = 'drawings';
  static const String reportsPath = 'reports';
  static const String profilesPath = 'profiles';
  static const String avatarsPath = 'avatars';

  // ✅ Drawing operations

  /// Upload drawing image to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadDrawing({
    required File imageFile,
    required String userId,
    required String childId,
    required String drawingId,
    bool compressImage = true,
    int quality = 85,
  }) async {
    try {
      _logger.i('Uploading drawing: $drawingId for child: $childId');

      // Compress image if needed
      File finalImageFile = imageFile;
      if (compressImage) {
        finalImageFile = await _compressImage(imageFile, quality);
      }

      // Create storage path
      final String fileName = '$drawingId.jpg';
      final String storagePath = '$drawingsPath/$userId/$childId/$fileName';

      // Create reference
      final Reference storageRef = _storage.ref().child(storagePath);

      // Upload file with metadata
      final UploadTask uploadTask = storageRef.putFile(
        finalImageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'childId': childId,
            'drawingId': drawingId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload completion
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      _logger.i('Drawing uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _logger.e('Error uploading drawing: $e');
      throw Exception('Failed to upload drawing: ${e.toString()}');
    }
  }

  /// Delete drawing from Firebase Storage
  Future<void> deleteDrawing({
    required String userId,
    required String childId,
    required String drawingId,
  }) async {
    try {
      _logger.i('Deleting drawing: $drawingId');

      final String fileName = '$drawingId.jpg';
      final String storagePath = '$drawingsPath/$userId/$childId/$fileName';

      final Reference storageRef = _storage.ref().child(storagePath);
      await storageRef.delete();

      _logger.i('Drawing deleted successfully: $drawingId');
    } catch (e) {
      _logger.e('Error deleting drawing: $e');
      throw Exception('Failed to delete drawing: ${e.toString()}');
    }
  }

  /// Get drawing download URL
  Future<String> getDrawingUrl({
    required String userId,
    required String childId,
    required String drawingId,
  }) async {
    try {
      final String fileName = '$drawingId.jpg';
      final String storagePath = '$drawingsPath/$userId/$childId/$fileName';

      final Reference storageRef = _storage.ref().child(storagePath);
      return await storageRef.getDownloadURL();
    } catch (e) {
      _logger.e('Error getting drawing URL: $e');
      throw Exception('Failed to get drawing URL: ${e.toString()}');
    }
  }

  // ✅ Avatar operations

  /// Upload child avatar image
  Future<String> uploadAvatar({
    required File imageFile,
    required String userId,
    required String childId,
    bool compressImage = true,
    int quality = 90,
  }) async {
    try {
      _logger.i('Uploading avatar for child: $childId');

      // Compress and resize avatar
      File finalImageFile = imageFile;
      if (compressImage) {
        finalImageFile = await _compressImage(imageFile, quality, maxSize: 512);
      }

      final String fileName = 'avatar.jpg';
      final String storagePath = '$profilesPath/$userId/$childId/$fileName';

      final Reference storageRef = _storage.ref().child(storagePath);

      final UploadTask uploadTask = storageRef.putFile(
        finalImageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'childId': childId,
            'type': 'avatar',
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      _logger.i('Avatar uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _logger.e('Error uploading avatar: $e');
      throw Exception('Failed to upload avatar: ${e.toString()}');
    }
  }

  /// Delete child avatar
  Future<void> deleteAvatar({
    required String userId,
    required String childId,
  }) async {
    try {
      _logger.i('Deleting avatar for child: $childId');

      final String fileName = 'avatar.jpg';
      final String storagePath = '$profilesPath/$userId/$childId/$fileName';

      final Reference storageRef = _storage.ref().child(storagePath);
      await storageRef.delete();

      _logger.i('Avatar deleted successfully for child: $childId');
    } catch (e) {
      _logger.e('Error deleting avatar: $e');
      throw Exception('Failed to delete avatar: ${e.toString()}');
    }
  }

  // ✅ Report operations

  /// Upload PDF report
  Future<String> uploadReport({
    required Uint8List pdfData,
    required String userId,
    required String childId,
    required String analysisId,
  }) async {
    try {
      _logger.i('Uploading report for analysis: $analysisId');

      final String fileName = '$analysisId.pdf';
      final String storagePath = '$reportsPath/$userId/$childId/$fileName';

      final Reference storageRef = _storage.ref().child(storagePath);

      final UploadTask uploadTask = storageRef.putData(
        pdfData,
        SettableMetadata(
          contentType: 'application/pdf',
          customMetadata: {
            'userId': userId,
            'childId': childId,
            'analysisId': analysisId,
            'type': 'report',
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      _logger.i('Report uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _logger.e('Error uploading report: $e');
      throw Exception('Failed to upload report: ${e.toString()}');
    }
  }

  /// Delete PDF report
  Future<void> deleteReport({
    required String userId,
    required String childId,
    required String analysisId,
  }) async {
    try {
      _logger.i('Deleting report for analysis: $analysisId');

      final String fileName = '$analysisId.pdf';
      final String storagePath = '$reportsPath/$userId/$childId/$fileName';

      final Reference storageRef = _storage.ref().child(storagePath);
      await storageRef.delete();

      _logger.i('Report deleted successfully: $analysisId');
    } catch (e) {
      _logger.e('Error deleting report: $e');
      throw Exception('Failed to delete report: ${e.toString()}');
    }
  }

  // ✅ Batch operations

  /// Delete all files for a child
  Future<void> deleteAllChildFiles({
    required String userId,
    required String childId,
  }) async {
    try {
      _logger.i('Deleting all files for child: $childId');

      final List<Future<void>> deleteTasks = [];

      // Delete drawings
      try {
        final ListResult drawingsResult = await _storage
            .ref()
            .child('$drawingsPath/$userId/$childId')
            .listAll();

        for (final Reference ref in drawingsResult.items) {
          deleteTasks.add(ref.delete());
        }
      } catch (e) {
        _logger.w('No drawings found for child: $childId');
      }

      // Delete reports
      try {
        final ListResult reportsResult = await _storage
            .ref()
            .child('$reportsPath/$userId/$childId')
            .listAll();

        for (final Reference ref in reportsResult.items) {
          deleteTasks.add(ref.delete());
        }
      } catch (e) {
        _logger.w('No reports found for child: $childId');
      }

      // Delete profile/avatar
      try {
        final ListResult profileResult = await _storage
            .ref()
            .child('$profilesPath/$userId/$childId')
            .listAll();

        for (final Reference ref in profileResult.items) {
          deleteTasks.add(ref.delete());
        }
      } catch (e) {
        _logger.w('No profile files found for child: $childId');
      }

      // Execute all deletions
      await Future.wait(deleteTasks);

      _logger.i('All files deleted successfully for child: $childId');
    } catch (e) {
      _logger.e('Error deleting child files: $e');
      throw Exception('Failed to delete child files: ${e.toString()}');
    }
  }

  /// Delete all files for a user
  Future<void> deleteAllUserFiles({required String userId}) async {
    try {
      _logger.i('Deleting all files for user: $userId');

      final List<Future<void>> deleteTasks = [];

      // Delete all user folders
      final List<String> folders = [drawingsPath, reportsPath, profilesPath];

      for (final String folderPath in folders) {
        try {
          final ListResult result =
              await _storage.ref().child('$folderPath/$userId').listAll();

          // Delete all items in folder
          for (final Reference ref in result.items) {
            deleteTasks.add(ref.delete());
          }

          // Delete all subfolders
          for (final Reference prefixRef in result.prefixes) {
            final ListResult subResult = await prefixRef.listAll();
            for (final Reference ref in subResult.items) {
              deleteTasks.add(ref.delete());
            }
          }
        } catch (e) {
          _logger.w('No files found in $folderPath for user: $userId');
        }
      }

      // Execute all deletions
      await Future.wait(deleteTasks);

      _logger.i('All files deleted successfully for user: $userId');
    } catch (e) {
      _logger.e('Error deleting user files: $e');
      throw Exception('Failed to delete user files: ${e.toString()}');
    }
  }

  // ✅ Utility methods

  /// Compress image file
  Future<File> _compressImage(
    File imageFile,
    int quality, {
    int maxSize = 2048,
  }) async {
    try {
      _logger.i('Compressing image with quality: $quality, maxSize: $maxSize');

      // Read image
      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Unable to decode image');
      }

      // Resize if needed
      if (image.width > maxSize || image.height > maxSize) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? maxSize : null,
          height: image.height > image.width ? maxSize : null,
        );
      }

      // Compress
      final Uint8List compressedBytes = Uint8List.fromList(
        img.encodeJpg(image, quality: quality),
      );

      // Create temporary file
      final String fileName = path.basename(imageFile.path);
      final String tempPath = path.join(
        path.dirname(imageFile.path),
        'compressed_$fileName',
      );

      final File compressedFile = File(tempPath);
      await compressedFile.writeAsBytes(compressedBytes);

      _logger.i(
          'Image compressed successfully. Original: ${imageBytes.length} bytes, Compressed: ${compressedBytes.length} bytes');

      return compressedFile;
    } catch (e) {
      _logger.e('Error compressing image: $e');
      // Return original file if compression fails
      return imageFile;
    }
  }

  /// Get file size in MB
  Future<double> getFileSizeInMB(String downloadUrl) async {
    try {
      final Reference ref = _storage.refFromURL(downloadUrl);
      final FullMetadata metadata = await ref.getMetadata();
      return (metadata.size ?? 0) / (1024 * 1024);
    } catch (e) {
      _logger.e('Error getting file size: $e');
      return 0.0;
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String storagePath) async {
    try {
      final Reference ref = _storage.ref().child(storagePath);
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get upload progress stream
  Stream<double> getUploadProgress(UploadTask uploadTask) {
    return uploadTask.snapshotEvents.map((TaskSnapshot snapshot) {
      return snapshot.bytesTransferred / snapshot.totalBytes;
    });
  }
}
