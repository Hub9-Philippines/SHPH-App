import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/components/back_button/back_button_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/profiles_service.dart';
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

  // Upload document to SHPH storage
  Future<void> uploadDocument(XFile image,
      {required Function() onUploadStart,
      required Function() onUploadComplete,
      required Function(String) onError}) async {
    try {
      onUploadStart();

      final fileBytes = await image.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';

      final resp = await ProfilesService.instance
          .submitKycDocument(documentBytes: fileBytes, fileName: fileName);

      if (resp == null) {
        onError('Upload failed.');
        onUploadComplete();
        return;
      }

      documentUrl = resp['document_url'] as String?;
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
