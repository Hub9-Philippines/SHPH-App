import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'kyc_onboarding_widget.dart' show KycOnboardingWidget;

/// State for the client KYC intro screen. Lightweight: the intro has no
/// form inputs — actions handle skip/submit directly on the widget.
class KycOnboardingModel extends FlutterFlowModel<KycOnboardingWidget> {
  bool isSkipping = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}