## Context

The home page (`lib/main/home/home_redesign_widget.dart`) feeds "Recommended for you" exclusively from `_loadNearbyRecommendations()` (`GET/POST /api/recommendations/nearby/`). That endpoint returns nothing when the user has no saved location (null lat/lng), yet the section is gated on `_hasBookingHistory` — so users with bookings see a header with zero cards. The SHPH API also exposes `/api/recommendations/user/` (booking-history-personalized recommendations, `UserRecommendations` → `RecommendationItem[]`, each embedding a `RecommendationListing` with `provider_name`/`provider_photo`/`review_count`/`category_name`). The Dart client currently only implements `nearby()` in `lib/api/resources/recommendations_api.dart`.

## Goals / Non-Goals

**Goals:**
- Populate "Recommended for you" whenever the user has bookings.
- Prefer booking-history-personalized content, then nearby, then top-rated.
- Never render the section header without cards.

**Non-Goals:**
- Rebuilding the recommendation ranking or ML behavior (server-side).
- Changing the Explore tab's "Recommended for You" feed or other consumers of `nearby()`.
- Altering the `0 errors` `flutter analyze` bar via new lint noise.

## Decisions

1. **Add a `user()` client method for `/api/recommendations/user/`** (`ShphRecommendationsApi`).
   - Returns a new lightweight `RecommendationItem` model (`serviceId`, `listing` embedded as `ShphServiceListing`, `score`, `reason`). Reuses the existing `NearbyRecommendation`-style parsing and the existing `ShphServiceListing.fromJson` so provider/rating/photo/category fields just work.
   - Rationale: this is the endpoint the API designates as booking-history-personalized (HomePage.vue consumer) and it returns the same `RecommendationListing` projection already handled by the client.
   - Alternative considered: deriving categories from `page.results` and filtering `listListings(category=...)` — rejected, it duplicates server-side ranking and is more code.

2. **New loader `_loadRecommendedProviders()` with a fallback chain** in the home widget:
   - Try `ShphRecommendationsApi.instance.user(limit: 10)` → map to `_TrendingProviderData` (drop items with empty provider name/id).
   - If result is empty, call the existing `_loadNearbyRecommendations()`.
   - If still empty, reuse the already-fetched top-rated `_providers` list (from `_loadProviders()`).
   - Wrap each call in its own try/catch so one failure falls to the next source instead of aborting.
   - Rationale: matches spec fallback ladder; top-rated is already loaded so no extra request in the common fallback case.
   - Alternative considered: single `Future.wait` fan-out — rejected, defeats the intentional ordering (personalized preferred, not merged).

3. **Render guard** — only emit the section when `_hasBookingHistory && _recommendedProviders.isNotEmpty`:
   `if (_hasBookingHistory && _recommendedProviders.isNotEmpty) ...[` around the existing header + card mapping.
   This directly satisfies the "no bare header" scenario and is a minimal change to the build method.

4. **Keep the section hidden without booking history** — the existing `_hasBookingHistory` gate stays; recommendations loading still runs in parallel for latency, but rendering stays gated.

## Risks / Trade-offs

- `/api/recommendations/user/` may return an empty list or 400 for users with no trained model → mitigation: the fallback chain (nearby → top-rated) guarantees a populated section; the whole loader is best-effort since empty results just hide the section.
- The user endpoint may be slower than nearby (server-side personalization) → mitigation: it runs inside the existing `Future.wait` parallel batch, so it does not add serial latency to the feed; a timeout/error simply falls to nearby.
- Reusing `_providers` as final fallback can duplicate the "Trending near you" rail visually → mitigation: acceptable duplicate; it only occurs when both personalized and nearby are empty, and the recommended cards use a distinct vertical-card layout.

## Migration Plan

- No backend changes; deploy the app as usual.
- Rollback: revert the loader wiring and render guard in `home_redesign_widget.dart`; `nearby()` remains untouched for other consumers.