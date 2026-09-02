import 'dart:async';

import 'package:flutter/material.dart';

import '/api/resources/auth_api.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import 'otp_page_widget.dart' show OtpPageWidget;

class OtpPageModel extends FlutterFlowModel<OtpPageWidget> {
  String phone = '';
  String code = '';
  bool codeSent = false;
  bool loading = false;
  String? error;
  int cooldown = 0;
  Timer? cooldownTimer;

  @override
  void initState(BuildContext context) {}

  Future<void> sendCode(AppLocalizations l10n) async {
    if (phone.trim().isEmpty) {
      error = l10n.otpErrEnterPhone;
      return;
    }
    loading = true;
    error = null;
    try {
      await ShphAuthApi.instance
          .sendOtpPin(phoneNumber: phone.trim());
      codeSent = true;
      _startCooldown();
    } catch (e) {
      error = l10n.otpErrSendFailed;
    } finally {
      loading = false;
    }
  }

  Future<bool> verify(AppLocalizations l10n) async {
    if (code.trim().length != 6) {
      error = l10n.otpErrEnterCode;
      return false;
    }
    loading = true;
    error = null;
    try {
      await ShphAuthApi.instance
          .verifyOtpPin(phoneNumber: phone.trim(), pin: code.trim());
      return true;
    } catch (e) {
      error = l10n.otpErrInvalidCode;
      return false;
    } finally {
      loading = false;
    }
  }

  void _startCooldown() {
    cooldown = 60;
    cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (cooldown <= 0) {
        cooldownTimer?.cancel();
      } else {
        cooldown--;
      }
    });
  }

  @override
  void dispose() {
    cooldownTimer?.cancel();
  }
}
