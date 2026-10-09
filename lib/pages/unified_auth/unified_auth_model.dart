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

    if (trimmed.contains('@') && trimmed.contains('.')) {
      inputMode = AuthInputMode.email;
      sanitizedPhone = '';
    } else {
      // Clean non-digits except initial '+'
      var cleanDigits = trimmed.replaceAll(RegExp(r'[^\d+]'), '');
      if (cleanDigits.startsWith('+63')) {
        cleanDigits = cleanDigits.substring(1); // '639...'
      }
      if (cleanDigits.startsWith('09') && cleanDigits.length == 11) {
        inputMode = AuthInputMode.phone;
        sanitizedPhone = '+63${cleanDigits.substring(1)}';
      } else if (cleanDigits.startsWith('639') && cleanDigits.length == 12) {
        inputMode = AuthInputMode.phone;
        sanitizedPhone = '+$cleanDigits';
      } else if (cleanDigits.startsWith('9') && cleanDigits.length == 10) {
        inputMode = AuthInputMode.phone;
        sanitizedPhone = '+63$cleanDigits';
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
