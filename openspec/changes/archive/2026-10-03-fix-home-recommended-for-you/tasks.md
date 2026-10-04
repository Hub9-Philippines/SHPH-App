## 1. API client: user recommendations

- [x] 1.1 Add a `RecommendationItem` model (`lib/api/models/recommendation_item.dart`) with `serviceId`, embedded `listing` (parsed via `ShphServiceListing.fromJson`), `score`, `reason`; parse `serviceId`/`score`/`reason` from JSON with null-safety.
- [x] 1.2 Add `Future<List<RecommendationItem>> user({int limit = 10})` to `ShphRecommendationsApi` (`lib/api/resources/recommendations_api.dart`) that POSTs `/api/recommendations/user/` with `{limit}` and maps the `recommendations` array to `RecommendationItem`s (reusing the existing `.where((item) => item.listing.id != 0)` guard).

## 2. Home page: booking-derived recommendations loader

- [x] 2.1 Add `_loadUserRecommendations()` in `home_redesign_widget.dart` that calls `ShphRecommendationsApi.instance.user(limit: 10)` and maps results to `_TrendingProviderData`, filtering out entries with empty provider name or id (mirror `_loadNearbyRecommendations`).
- [x] 2.2 Add `_loadRecommendedProviders()` implementing the fallback chain: try user recommendations → `_loadNearbyRecommendations()` → reuse top-rated providers already fetched by `_loadProviders()`; each step wrapped in its own try/catch so a failure/emptiness falls through to the next source.
- [x] 2.3 Replace `_loadNearbyRecommendations()` with `_loadRecommendedProviders()` in the `_loadHomeData()` `Future.wait` batch (index 3).

## 3. Render guard

- [x] 3.1 Gate the "Recommended for you" render on both booking history and a non-empty list: `if (_hasBookingHistory && _recommendedProviders.isNotEmpty) ...[` around the `_HomeSectionHeader` + card mapping.

## 4. Verification

- [x] 4.1 Run `flutter analyze` and confirm 0 errors (no new lint noise beyond accepted info lints).
- [ ] 4.2 Manual check on a device/emulator: with a booking present, "Recommended for you" renders a non-empty list (or gracefully falls back); without bookings the section stays hidden; pull-to-refresh keeps the content populated.