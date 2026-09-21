## Why

The home page's "Recommended for you" section renders no content when it appears. It is gated on the user having booking history, but its list is fed only by the nearby-recommendations endpoint (`/api/recommendations/nearby/`), which returns empty when no saved location is set — so users who already have bookings see a header with zero items. Given there is a booking, the section should show a populated list of recommended providers.

## What Changes

- Populate the home page "Recommended for you" section with a non-empty list of provider recommendations when the user has at least one booking.
- Recommendations are derived from the user's booking history (the categories/listings they booked), fetched from the personal user-recommendations endpoint (`/api/recommendations/user/`), falling back to the nearby endpoint and finally to top-rated listings when a source is empty or errors.
- Keep the section hidden when the user has no booking history (existing gating stays).
- Never render the section header with zero cards underneath — if all recommendation sources yield nothing, the section is not shown.

## Capabilities

### Modified Capabilities
- `home-screen-experience`: the "Recommended for you" section no longer renders an empty header; it is populated from booking history when the user has bookings.

## Impact

- `lib/main/home/home_redesign_widget.dart` — replace the sole `_loadNearbyRecommendations()` source for `_recommendedProviders` with a booking-derived recommendation load (personalized → nearby → top-rated fallback) and guard the section render against an empty list.
- `lib/api/resources/recommendations_api.dart` — add a client for `/api/recommendations/user/` returning `RecommendationItem`s (each with an embedded `RecommendationListing`).
- No backend, schema, or dependency changes.