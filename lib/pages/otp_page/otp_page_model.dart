import 'dart:async';

import 'package:flutter/material.dart';

import '/api/resources/auth_api.dart';
import '/flutter_flow/flutter_flow_util.dart';
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

  Future<void> sendCode() async {
    if (phone.trim().isEmpty) {
      error = 'Please enter a phone number';
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
      error = 'Failed to send code.';
    } finally {
      loading = false;
    }
  }

  Future<bool> verify() async {
    if (code.trim().length != 6) {
      error = 'Please enter the 6-digit code';
      return false;
    }
    loading = true;
    error = null;
    try {
      await ShphAuthApi.instance
          .verifyOtpPin(phoneNumber: phone.trim(), pin: code.trim());
      return true;
    } catch (e) {
      error = 'Invalid code.';
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
