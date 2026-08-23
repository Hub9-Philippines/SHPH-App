import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/models/service_listing.dart';
import '/services/categories_service.dart';
import '/services/service_listing_service.dart';
import 'explore_widget.dart' show ExploreWidget;

class ExploreModel extends FlutterFlowModel<ExploreWidget> {
  Future<List<CategoriesRow>>? _categoriesFuture;
  Future<List<ServiceListing>>? _topRatedFuture;
  Future<List<ServiceListing>>? _recommendedFuture;

  /// Section 1 shortcut tiles (capped for the horizontal row).
  Future<List<CategoriesRow>>? get categoriesFuture => _categoriesFuture;

  /// Section 3 "Top Rated Near You" carousel items.
  Future<List<ServiceListing>>? get topRatedFuture => _topRatedFuture;

  /// Section 4 "Recommended for You" feed items.
  Future<List<ServiceListing>>? get recommendedFuture => _recommendedFuture;

  @override
  void initState(BuildContext context) {
    loadAll();
  }

  /// (Re)loads every section future. Called on init and pull-to-refresh.
  void loadAll() {
    _categoriesFuture = CategoriesService.instance.getCategories();
    _loadTopRated();
    _recommendedFuture =
        ServiceListingService.instance.fetchRecommendedServices(limit: 8);
  }

  void _loadTopRated() {
    final appState = FFAppState();
    final lat = appState.selectedLatitude;
    final lng = appState.selectedLongitude;
    _topRatedFuture = ServiceListingService.instance
        .fetchTopRatedNear(latitude: lat, longitude: lng, limit: 10);
  }

  @override
  void dispose() {}
}
