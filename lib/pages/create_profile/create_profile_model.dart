import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'create_profile_widget.dart' show CreateProfileWidget;

/// State for the redesigned profile-completion step. Keeps the controllers,
/// avatar upload state, and submission flags so the page stays testable.
class CreateProfileModel extends FlutterFlowModel<CreateProfileWidget> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  /// Photo chosen from the picker, staged before upload.
  List<int>? pickedPhotoBytes;
  String? pickedPhotoName;

  /// Final photo URL after a successful `uploadPhoto` call.
  String? uploadedPhotoUrl;

  bool isUploading = false;
  double uploadProgress = 0;
  bool isSubmitting = false;

  /// The share of required profile fields (first + last name) that are
  /// filled, matching the web completion step's progress indicator.
  double get progress {
    var filled = 0;
    if (firstNameController.text.trim().isNotEmpty) filled += 1;
    if (lastNameController.text.trim().isNotEmpty) filled += 1;
    return filled / 2;
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    bioController.dispose();
  }
}