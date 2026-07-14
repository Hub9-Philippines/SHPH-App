import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;

import '/api/resources/kyc_api.dart';
import '/api/resources/users_api.dart';
import '/flutter_flow/uploaded_file.dart';

Future<String?> uploadScannedToSupabase(
  dynamic fileData,
  String bucketName,
  String folderPath,
) async {
  try {
    late final Uint8List bytes;
    late final String fileName;
    if (fileData is String) {
      bytes = await File(fileData).readAsBytes();
      fileName = path.basename(fileData);
    } else if (fileData is Uint8List) {
      bytes = fileData;
      fileName = 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg';
    } else if (fileData is FFUploadedFile && fileData.bytes != null) {
      bytes = fileData.bytes!;
      fileName = fileData.name ?? 'upload.jpg';
    } else {
      return null;
    }
    if (bucketName.toLowerCase().contains('kyc') ||
        folderPath.toLowerCase().contains('kyc')) {
      final result = await ShphKycApi.instance
          .submitKyc(documentBytes: bytes, fileName: fileName);
      return (result['document_url'] ?? result['url'])?.toString();
    }
    final result = await ShphUsersApi.instance.uploadPhoto(bytes, fileName);
    return (result['photo_url'] ?? result['url'])?.toString();
  } catch (_) {
    return null;
  }
}
