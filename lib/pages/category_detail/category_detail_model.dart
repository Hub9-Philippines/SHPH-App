import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/service_listing_service.dart';
import 'category_detail_widget.dart' show CategoryDetailWidget;

class CategoryDetailModel extends FlutterFlowModel<CategoryDetailWidget> {
  List<Map<String, dynamic>> listings = [];
  String? categoryName;
  bool isLoading = true;

  @override
  void initState(BuildContext context) {}

  Future<void> loadCategory(dynamic categoryId, String name) async {
    categoryName = name;
    isLoading = true;
    try {
      final services =
          await ServiceListingService.instance.fetchServiceListings(
        pageSize: 50,
      );
      final normName = name.toLowerCase().replaceAll('&', 'and').replaceAll(RegExp(r'[^a-z0-9]'), '');
      listings = services
          .where((s) {
            final catName = (s.categoryName ?? '').toLowerCase().replaceAll('&', 'and').replaceAll(RegExp(r'[^a-z0-9]'), '');
            if (catName.isNotEmpty && (catName.contains(normName) || normName.contains(catName))) {
              return true;
            }
            return '${s.category}' == '$categoryId';
          })
          .map((s) => {
                'id': s.id,
                'title': s.title.isNotEmpty ? s.title : 'Service Listing',
                'thumbnail': s.thumbnail,
                'basePrice': s.basePrice,
                'priceUnit': s.priceUnit,
                'rating': s.rating,
                'reviewCount': s.reviewCount,
                'providerName': s.providerName ?? 'Serbisyo Verified Pro',
              })
          .toList();
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {}
}
