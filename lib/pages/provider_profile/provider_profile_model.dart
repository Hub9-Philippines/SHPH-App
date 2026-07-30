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

  Future<void> loadProvider(dynamic providerId) async {
    isLoading = true;
    try {
      provider =
          await ProviderProfileService.instance.getProvider(providerId);
      listings =
          await ProviderProfileService.instance.getProviderListings(providerId);
      reviews =
          await ProviderProfileService.instance.getProviderReviews(providerId);
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {}
}
