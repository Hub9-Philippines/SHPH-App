import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/client_kyc_service.dart';
import 'kyc_document_widget.dart' show KycDocumentWidget;

/// State for the client KYC document screen — holds the three captured
/// files (ID front, ID back, selfie) until the user continues to liveness.
class KycDocumentModel extends FlutterFlowModel<KycDocumentWidget> {
  ClientKycFile? idFront;
  ClientKycFile? idBack;
  ClientKycFile? selfie;

  bool isSkipping = false;

  bool get complete =>
      idFront != null && idBack != null && selfie != null;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}