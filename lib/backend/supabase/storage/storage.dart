import '/api/resources/users_api.dart';
import '/flutter_flow/upload_data.dart';
import '/services/logging_service.dart';

/// File upload helpers.
///
/// Supabase Storage has been removed. Uploads are routed through the SHPH
/// API (user profile photo endpoint) where possible; other buckets are stubbed
/// since no SHPH upload endpoint exists yet.
Future<List<String>> uploadSupabaseStorageFiles({
  required String bucketName,
  required List<SelectedFile> selectedFiles,
}) =>
    Future.wait(
      selectedFiles.map(
        (media) => uploadSupabaseStorageFile(
          bucketName: bucketName,
          selectedFile: media,
        ),
      ),
    );

Future<String> uploadSupabaseStorageFile({
  required String bucketName,
  required SelectedFile selectedFile,
}) async {
  final fileName = selectedFile.originalFilename.isNotEmpty
      ? selectedFile.originalFilename
      : (selectedFile.storagePath.split('/').last);
  try {
    if (bucketName == 'profiles' || bucketName == 'profile_photos') {
      final resp = await ShphUsersApi.instance.uploadPhoto(
        selectedFile.bytes,
        fileName,
      );
      final url = resp['photo_url'] ?? resp['photo'] ?? resp['url'];
      if (url != null) {
        return url.toString();
      }
    }
  } catch (e) {
    LoggingService.error('SHPH upload failed: $e', tag: 'Storage');
  }
  // No SHPH endpoint for this bucket yet - stub with the storage path.
  return selectedFile.storagePath;
}

Future deleteSupabaseFileFromPublicUrl(String publicUrl) async {
  // SHPH API does not expose file deletion; no-op.
}
