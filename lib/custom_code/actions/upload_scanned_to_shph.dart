// Automatic FlutterFlow imports
import '/api/shph_api_client.dart';
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
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

Future<String?> uploadScannedToShph(
  dynamic fileData,
  String bucketName,
  String folderPath,
) async {
  // Add your function code here!
  try {
    final client = ShphApiClient.instance;

    Uint8List? fileBytes;
    String? fileName;
    File? tempFile;

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

    // Upload via SHPH API
    if (kIsWeb) {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: uniqueFileName),
      });
      final resp = await client.post<Map<String, dynamic>>(
        '/api/uploads/',
        data: formData,
      );
      return resp.data?['url'] as String?;
    } else {
      // For mobile, create a temp file
      final tempDir = Directory.systemTemp;
      tempFile = File('${tempDir.path}/$uniqueFileName');
      await tempFile.writeAsBytes(fileBytes);

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(tempFile.path,
            filename: uniqueFileName),
      });
      final resp = await client.post<Map<String, dynamic>>(
        '/api/uploads/',
        data: formData,
      );

      // Clean up temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      return resp.data?['url'] as String?;
    }
  } catch (e) {
    print("Upload Error: $e");
    return "error";
  }
}
