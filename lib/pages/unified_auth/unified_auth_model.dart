import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'unified_auth_widget.dart' show UnifiedAuthWidget;

enum AuthInputMode { none, email, phone }

class UnifiedAuthModel extends FlutterFlowModel<UnifiedAuthWidget> {
  FocusNode? inputFocusNode;
  TextEditingController? inputTextController;

  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  bool showPasswordField = false;
  bool isPasswordVisible = false;

  AuthInputMode inputMode = AuthInputMode.none;
  String sanitizedPhone = '';
  String? errorMessage;
  bool isLoading = false;

  @override
  void initState(BuildContext context) {}

  void updateInput(String raw) {
    final trimmed = raw.trim();
    errorMessage = null;
    showPasswordField = false;

    if (trimmed.contains('@') && trimmed.contains('.')) {
      inputMode = AuthInputMode.email;
      sanitizedPhone = '';
    } else {
      var cleanDigits = trimmed.replaceAll(RegExp(r'[^\d+]'), '');
      if (cleanDigits.startsWith('+63')) {
        cleanDigits = cleanDigits.substring(1);
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

  bool get isValid {
    if (inputMode == AuthInputMode.none) return false;
    if (showPasswordField) {
      return (passwordTextController?.text ?? '').isNotEmpty;
    }
    return true;
  }

  @override
  void dispose() {
    inputFocusNode?.dispose();
    inputTextController?.dispose();
    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
  }
}
