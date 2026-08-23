import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/biometric_service.dart';
import 'biometric_setup_widget.dart' show BiometricSetupWidget;

class BiometricSetupModel extends FlutterFlowModel<BiometricSetupWidget> {
  List<Map<String, dynamic>> credentials = [];
  bool isLoading = true;
  bool isRegistering = false;

  @override
  void initState(BuildContext context) {}

  Future<void> loadCredentials() async {
    isLoading = true;
    try {
      credentials = await BiometricService.instance.listCredentials();
    } finally {
      isLoading = false;
    }
  }

  Future<bool> registerDevice(String deviceName) async {
    isRegistering = true;
    try {
      final options = await BiometricService.instance.getRegisterOptions();
      if (options == null) return false;
      return await BiometricService.instance.verifyRegistration({
        'device_name': deviceName,
        ...options,
      });
    } finally {
      isRegistering = false;
    }
  }

  Future<bool> deleteCredential(int pk) async {
    final ok = await BiometricService.instance.deleteCredential(pk);
    if (ok) {
      credentials.removeWhere((c) => c['id'] == pk);
    }
    return ok;
  }

  @override
  void dispose() {}
}
