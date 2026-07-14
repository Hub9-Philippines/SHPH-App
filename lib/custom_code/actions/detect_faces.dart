// Automatic FlutterFlow imports

import '/theme/app_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:io'; // Needed for temporary file creation

Future<List<dynamic>> detectFaces(FFUploadedFile? uploadedFile) async {
  if (uploadedFile == null ||
      uploadedFile.bytes == null ||
      uploadedFile.bytes!.isEmpty) {
    return [];
  }

  final tempDir = Directory.systemTemp;
  final file = File(
      '${tempDir.path}/face_check_${DateTime.now().millisecondsSinceEpoch}.jpg');
  await file.writeAsBytes(uploadedFile.bytes!);

  // High-accuracy mode is better for eKYC
  final options = FaceDetectorOptions(
    performanceMode: FaceDetectorMode.accurate,
    enableClassification: true,
  );
  final faceDetector = FaceDetector(options: options);

  try {
    final inputImage = InputImage.fromFilePath(file.path);
    final List<Face> faces = await faceDetector.processImage(inputImage);

    List<Map<String, dynamic>> results = [];
    for (Face face in faces) {
      // VALIDATION: Ensure the person is looking straight (not turned more than 20 degrees)
      bool isStraight =
          (face.headEulerAngleY! < 20 && face.headEulerAngleY! > -20) &&
              (face.headEulerAngleX! < 20 && face.headEulerAngleX! > -20);

      results.add({
        'boundingBox': {
          'top': face.boundingBox.top,
          'left': face.boundingBox.left,
        },
        'smileProbability': face.smilingProbability,
        'isFacingCamera': isStraight,
        'headAngleY': face.headEulerAngleY,
      });
    }
    return results;
  } catch (e) {
    return [];
  } finally {
    await faceDetector.close();
    if (await file.exists()) await file.delete();
  }
}
