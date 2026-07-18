import '/api/resources/users_api.dart';
import '/flutter_flow/upload_data.dart';
import '/services/logging_service.dart';

Future<List<String>> uploadShphStorageFiles({
  required String bucketName,
  required List<SelectedFile> selectedFiles,
}) =>
    Future.wait(
      selectedFiles.map(
        (media) => uploadShphStorageFile(
          bucketName: bucketName,
          selectedFile: media,
        ),
      ),
    );

Future<String> uploadShphStorageFile({
  required String bucketName,
  required SelectedFile selectedFile,
}) async {
  try {
    final result = await ShphUsersApi.instance.uploadPhoto(
      selectedFile.bytes,
      selectedFile.storagePath.split('/').last,
    );
    return result['photo_url'] as String? ?? '';
  } catch (e) {
    LoggingService.error('File upload failed: $e', tag: 'Storage');
    return '';
  }
}

Future deleteShphFileFromPublicUrl(String publicUrl) async {
  LoggingService.debug('deleteFileFromPublicUrl: $publicUrl', tag: 'Storage');
}
