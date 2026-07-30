import 'dart:math';

import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/service_listing_service.dart';
import 'recommendations_widget.dart' show RecommendationsWidget;

class RecommendationsModel extends FlutterFlowModel<RecommendationsWidget> {
  List<Map<String, dynamic>> trending = [];
  List<Map<String, dynamic>> nearYou = [];
  List<Map<String, dynamic>> categoryPicks = [];
  bool isLoading = true;

  @override
  void initState(BuildContext context) {}

  Future<void> loadRecommendations() async {
    isLoading = true;
    try {
      final all =
          await ServiceListingService.instance.fetchServiceListings(
        pageSize: 50,
      );

      final shuffled = List.of(all)..shuffle(Random());

      trending = shuffled
          .take(12)
          .map(_listingToMap)
          .toList();

      nearYou = shuffled
          .take(10)
          .map(_listingToMap)
          .toList();

      final cats = <String>[];
      categoryPicks = [];
      for (final s in shuffled) {
        if (s.categoryName != null && !cats.contains(s.categoryName)) {
          cats.add(s.categoryName!);
          categoryPicks.add(_listingToMap(s));
          if (categoryPicks.length >= 6) break;
        }
      }

      if (trending.isEmpty && nearYou.isEmpty) {
        final fromApi = all.take(10).map(_listingToMap).toList();
        trending = fromApi;
        nearYou = fromApi;
      }
    } finally {
      isLoading = false;
    }
  }

  Map<String, dynamic> _listingToMap(dynamic listing) => {
        'id': listing.id,
        'title': listing.title,
        'thumbnail': listing.thumbnail,
        'basePrice': listing.basePrice,
        'priceUnit': listing.priceUnit,
        'rating': listing.rating,
        'reviewCount': listing.reviewCount,
        'providerName': listing.providerName,
        'categoryName': listing.categoryName,
      };

  @override
  void dispose() {}
}
