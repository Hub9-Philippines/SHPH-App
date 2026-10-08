import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'unified_auth_widget.dart' show UnifiedAuthWidget;

enum AuthInputMode { none, email, phone }

class UnifiedAuthModel extends FlutterFlowModel<UnifiedAuthWidget> {
  /// State fields for stateful widgets in this page.
  FocusNode? inputFocusNode;
  TextEditingController? inputTextController;

  AuthInputMode inputMode = AuthInputMode.none;
  String sanitizedPhone = '';
  String? errorMessage;
  bool isLoading = false;

  final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  final RegExp _phPhoneRegex = RegExp(
    r'^(09|\+?639)\d{9}$',
  );

  @override
  void initState(BuildContext context) {}

  void updateInput(String raw) {
    final trimmed = raw.trim();
    errorMessage = null;

    if (_emailRegex.hasMatch(trimmed)) {
      inputMode = AuthInputMode.email;
      sanitizedPhone = '';
    } else {
      // Check phone number format
      final cleanDigits = trimmed.replaceAll(RegExp(r'[\s\-()]'), '');
      if (_phPhoneRegex.hasMatch(cleanDigits)) {
        inputMode = AuthInputMode.phone;
        if (cleanDigits.startsWith('09')) {
          sanitizedPhone = '+63${cleanDigits.substring(1)}';
        } else if (cleanDigits.startsWith('639')) {
          sanitizedPhone = '+$cleanDigits';
        } else {
          sanitizedPhone = cleanDigits;
        }
      } else {
        inputMode = AuthInputMode.none;
        sanitizedPhone = '';
      }
    }
  }

  bool get isValid => inputMode != AuthInputMode.none;

  @override
  void dispose() {
    inputFocusNode?.dispose();
    inputTextController?.dispose();
  }
}
