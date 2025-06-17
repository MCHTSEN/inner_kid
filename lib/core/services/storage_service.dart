import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Service for handling file uploads to Firebase Storage
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  // Storage paths
  static const String drawingsPath = 'drawings';
  static const String reportsPath = 'reports';
  static const String profilesPath = 'profiles';
  static const String avatarsPath = 'avatars';

  // ✅ Drawing operations

  /// Upload a child's drawing to Firebase Storage
  Future<String> uploadDrawing({
    required File imageFile,
    required String userId,
    required String childId,
    required String drawingId,
  }) async {
    try {
      _logger.i('Uploading drawing: $drawingId');

      // Create path for the drawing
      final fileName =
          '${drawingId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'drawings/$userId/$childId/$fileName';

      // Create reference
      final ref = _storage.ref().child(path);

      // Upload the file
      final uploadTask = await ref.putFile(
        imageFile,
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

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      _logger.i('Drawing uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _logger.e('Failed to upload drawing: $e');
      throw Exception('Failed to upload drawing: $e');
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

  /// Upload profile image
  Future<String> uploadProfileImage({
    required File imageFile,
    required String userId,
    required String imageId,
  }) async {
    try {
      _logger.i('Uploading profile image: $imageId');

      final fileName =
          '${imageId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'profile_images/$userId/$fileName';

      final ref = _storage.ref().child(path);

      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'imageId': imageId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      _logger.i('Profile image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _logger.e('Failed to upload profile image: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Upload data as bytes
  Future<String> uploadBytes({
    required Uint8List data,
    required String path,
    required String contentType,
    Map<String, String>? metadata,
  }) async {
    try {
      _logger.i('Uploading bytes to: $path');

      final ref = _storage.ref().child(path);

      final uploadTask = await ref.putData(
        data,
        SettableMetadata(
          contentType: contentType,
          customMetadata: metadata ?? {},
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      _logger.i('Bytes uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _logger.e('Failed to upload bytes: $e');
      throw Exception('Failed to upload bytes: $e');
    }
  }

  /// Delete a file from storage
  Future<void> deleteFile(String downloadUrl) async {
    try {
      _logger.i('Deleting file: $downloadUrl');

      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();

      _logger.i('File deleted successfully');
    } catch (e) {
      _logger.e('Failed to delete file: $e');
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Get file metadata
  Future<FullMetadata> getFileMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e) {
      _logger.e('Failed to get file metadata: $e');
      throw Exception('Failed to get file metadata: $e');
    }
  }

  /// List files in a directory
  Future<List<String>> listFiles(String path, {int maxResults = 100}) async {
    try {
      _logger.i('Listing files in: $path');

      final ref = _storage.ref().child(path);
      final result = await ref.listAll();

      final downloadUrls = <String>[];
      for (final item in result.items) {
        final url = await item.getDownloadURL();
        downloadUrls.add(url);
      }

      _logger.i('Found ${downloadUrls.length} files');
      return downloadUrls;
    } catch (e) {
      _logger.e('Failed to list files: $e');
      throw Exception('Failed to list files: $e');
    }
  }

  /// Monitor upload progress
  Stream<TaskSnapshot> uploadWithProgress({
    required File file,
    required String path,
    SettableMetadata? metadata,
  }) {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file, metadata);

    return uploadTask.snapshotEvents;
  }

  /// Generate unique file ID
  String generateFileId() => _uuid.v4();
}
