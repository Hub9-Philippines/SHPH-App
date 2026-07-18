import '/flutter_flow/upload_data.dart';

Never _apiOnly() => throw UnsupportedError(
      'Direct Supabase Storage access has been removed. Use an SHPH API upload endpoint.',
    );

Future<List<String>> uploadSupabaseStorageFiles({
  required String bucketName,
  required List<SelectedFile> selectedFiles,
}) async =>
    _apiOnly();

Future<String> uploadSupabaseStorageFile({
  required String bucketName,
  required SelectedFile selectedFile,
}) async =>
    _apiOnly();

Future<void> deleteSupabaseFileFromPublicUrl(String publicUrl) async =>
    _apiOnly();
