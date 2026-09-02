import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/client_kyc_service.dart';
import 'kyc_face_liveness_widget.dart' show KycFaceLivenessWidget;

/// State for the client face-liveness screen: holds the requested server
/// challenge (nonce + plan), the camera controller, the captured selfie,
/// and the submission flags.
class KycFaceLivenessModel extends FlutterFlowModel<KycFaceLivenessWidget> {
  CameraController? cameraController;
  bool isCameraReady = false;
  bool isFallbackMode = false;

  /// Server challenges are best-effort: on failure we run the local fallback
  /// plan and submit without a nonce (spec: liveness fallback).
  String? challengeNonce;
  List<String> challengePlan = const [];
  bool challengeFailed = false;

  ClientKycFile? selfie;
  bool isSubmitting = false;
  bool isSkipping = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    cameraController?.dispose();
  }
}