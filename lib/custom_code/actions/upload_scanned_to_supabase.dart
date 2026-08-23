// Automatic FlutterFlow imports
import '/api/resources/users_api.dart';
import '/backend/supabase/supabase.dart';
import '/theme/app_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;

Future<String?> uploadScannedToSupabase(
  dynamic fileData,
  String bucketName,
  String folderPath,
) async {
  // Add your function code here!
  try {
    Uint8List? fileBytes;
    String? fileName;

    // Handle different input types
    if (fileData is String) {
      // 1. If it's a file path
      final file = File(fileData);
      if (!await file.exists()) {
        print('File does not exist: $fileData');
        return null;
      }
      fileBytes = await file.readAsBytes();
      fileName = path.basename(fileData);
    } else if (fileData is Uint8List) {
      // 2. If it's byte data (from uploaded file)
      fileBytes = fileData;
      fileName = 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg';
    } else if (fileData is FFUploadedFile && fileData.bytes != null) {
      // 3. If it's FFUploadedFile from FlutterFlow
      fileBytes = fileData.bytes;
      fileName = fileData.name ??
          'upload_${DateTime.now().millisecondsSinceEpoch}.jpg';
    } else {
      print('Unsupported file data type: ${fileData.runtimeType}');
      return null;
    }

    if (fileBytes == null || fileBytes.isEmpty) {
      print('File data is empty');
      return null;
    }

    // Generate a unique file name
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(fileName ?? '.jpg');
    final baseName = path.basenameWithoutExtension(fileName ?? 'upload');
    final uniqueFileName = '${baseName}_$timestamp$extension';

    if (bucketName == 'profiles' || bucketName == 'profile_photos') {
      final resp = await ShphUsersApi.instance.uploadPhoto(
        fileBytes,
        uniqueFileName,
      );
      final url = resp['photo_url'] ?? resp['photo'] ?? resp['url'];
      if (url != null) {
        return url.toString();
      }
    }

    // No SHPH upload endpoint for this bucket yet - stub with the storage path.
    return '$folderPath/$uniqueFileName';
  } catch (e) {
    print("Upload Error: $e");
    return "error";
  }
}
