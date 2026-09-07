import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/provider_profile_service.dart';
import 'provider_profile_widget.dart' show ProviderProfileWidget;

class ProviderProfileModel extends FlutterFlowModel<ProviderProfileWidget> {
  Map<String, dynamic>? provider;
  List<Map<String, dynamic>> listings = [];
  List<Map<String, dynamic>> reviews = [];
  bool isLoading = true;

  @override
  void initState(BuildContext context) {}

  /// Provider profile loads [provider] and [listings] in place; reviews are no
  /// longer loaded on the profile screen. The broken provider-reviews endpoint
  /// (`/api/services/listings/provider/{id}/reviews/`) doesn't exist in the
  /// deployed backend (it 404s), so the profile now links out to the dedicated
  /// reviews page instead.
  Future<void> loadProvider(dynamic providerId) async {
    isLoading = true;
    try {
      provider =
          await ProviderProfileService.instance.getProvider(providerId);
      listings =
          await ProviderProfileService.instance.getProviderListings(providerId);
      // Kept as empty so downstream consumers that still reference `_model.reviews`
      // (stat pills, `_avgRating` fallback) keep compiling during the transition.
      reviews = const [];
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {}
}
