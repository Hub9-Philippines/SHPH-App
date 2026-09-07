import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/api/resources/providers_api.dart';
import '/services/provider_profile_service.dart';
import 'provider_reviews_widget.dart' show ProviderReviewsWidget;

const int _initialPageSize = 5;
const int _loadMorePageSize = 5;
const int _topListingsCap = 8;

/// Data + pure async helpers for the provider reviews page.
/// Pagination state lives in the widget so setState is safe; this model only
/// owns the fetched content and the pure chunk-fetch logic.
class ProviderReviewsModel extends FlutterFlowModel<ProviderReviewsWidget> {
  Map<String, dynamic>? provider;
  List<Map<String, dynamic>> topListings = [];
  List<Map<String, dynamic>> reviews = [];
  bool isLoading = true;
  bool providerError = false;
  bool hasMore = false;
  int nextPage = 1;

  /// Loads the provider profile + top listings, then returns the first chunk of
  /// merged reviews (highest-rated first across the selected top listings).
  /// The widget owns appending these to [reviews] via setState.
  Future<List<Map<String, dynamic>>> loadInitialChunk(String providerId) async {
    isLoading = true;
    providerError = false;
    reviews = [];
    topListings = [];
    nextPage = 1;
    hasMore = false;

    provider = await ProviderProfileService.instance.getProvider(providerId);
    topListings = _rankTopListings(
      await ProviderProfileService.instance.getProviderListings(providerId),
    );
    hasMore = topListings.isNotEmpty;
    isLoading = false;

    if (!hasMore) {
      return const [];
    }

    return _fetchChunk(_initialPageSize);
  }

  /// Appends the next chunk and returns it; the widget merges it into [reviews]
  /// via setState. Returns an empty list when there is nothing more to load.
  Future<List<Map<String, dynamic>>> loadNextChunk() async {
    if (!hasMore || topListings.isEmpty) {
      return const [];
    }

    final next = await _fetchChunk(_loadMorePageSize);
    if (next.isEmpty) {
      hasMore = false;
    }
    return next;
  }

  Future<List<Map<String, dynamic>>> _fetchChunk(int count) async {
    final chunk = <Map<String, dynamic>>[];
    for (final listing in topListings) {
      if (chunk.length >= count) {
        break;
      }
      final listingId = listing['id'] as int?;
      if (listingId == null || listingId <= 0) {
        continue;
      }
      try {
        final page = await ShphProvidersApi.instance.listProviderListingsReviews(
          listingId,
          page: nextPage,
        );
        for (final r in page.results) {
          if (chunk.length >= count) {
            break;
          }
          chunk.add(_reviewToMap(r, listing));
        }
      } catch (_) {
        // Public per-listing reviews are best-effort.
      }
    }

    nextPage += 1;
    hasMore = chunk.length >= count;
    return chunk;
  }

  /// Provider's listings ranked by review count descending; rating as tiebreak.
  /// Returns at most [_topListingsCap] listings so the N+1 reviews fetch stays bounded.
  static List<Map<String, dynamic>> _rankTopListings(
    List<Map<String, dynamic>> raw,
  ) {
    final ranked = raw.toList()
      ..sort((a, b) {
        final ra = _asInt(a['reviewCount']);
        final rb = _asInt(b['reviewCount']);
        if (ra != rb) {
          return rb.compareTo(ra);
        }
        final ar = _asDouble(a['rating']);
        final br = _asDouble(b['rating']);
        return br.compareTo(ar);
      });
    return ranked.take(_topListingsCap).toList();
  }

  /// Merge a single `ShphReview` into the flattened review map the widget renders.
  static Map<String, dynamic> _reviewToMap(
    dynamic review,
    Map<String, dynamic> listing,
  ) {
    return {
      'id': review.id.toString(),
      'rating': review.rating,
      'comment': review.comment?.toString(),
      'reviewerName': review.reviewerName?.toString(),
      'reviewerPhoto': review.reviewerPhoto?.toString(),
      'createdAt': review.createdAt?.toString(),
      'serviceTitle': listing['title']?.toString(),
      'serviceListingId': listing['id'],
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  @override
  void initState(BuildContext context) {
    // No-op: pure data + async helpers; the widget drives pagination/setState.
  }

  @override
  void dispose() {}
}
