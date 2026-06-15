import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/components/back_button/back_button_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'document_scan_widget.dart' show DocumentScanWidget;

class DocumentScanModel extends FlutterFlowModel<DocumentScanWidget> {
  ///  State fields for stateful widgets in this page.

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late BackButtonModel backButtonModel;

  File? selectedImage;
  String? documentUrl;
  bool isUploading = false;

  @override
  void initState(BuildContext context) {
    backButtonModel = createModel(context, BackButtonModel.new);
  }

  // Upload document to Supabase storage
  Future<void> uploadDocument(XFile image,
      {required Function() onUploadStart,
      required Function() onUploadComplete,
      required Function(String) onError}) async {
    try {
      onUploadStart();

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        onError('You are not authenticated. Please log in again.');
        return;
      }

      // Upload to provider-verification bucket
      final fileBytes = await image.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final filePath = '$userId/documents/$fileName';

      await Supabase.instance.client.storage
          .from('provider-verification')
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      // Get public URL
      final imageUrl = Supabase.instance.client.storage
          .from('provider-verification')
          .getPublicUrl(filePath);

      // Update profile with document URL and set verification status to pending
      await Supabase.instance.client.from('profiles').update({
        'document_url': imageUrl,
        'verification_status': 'pending',
        'submitted_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      documentUrl = imageUrl;
      onUploadComplete();
    } catch (e) {
      var errorMessage = 'Failed to upload document. Please try again.';
      if (e.toString().contains('StorageException')) {
        errorMessage =
            'Storage error. Please check your connection and try again.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      }
      onError(errorMessage);
      onUploadComplete();
    }
  }

  @override
  void dispose() {
    backButtonModel.dispose();
  }
}
