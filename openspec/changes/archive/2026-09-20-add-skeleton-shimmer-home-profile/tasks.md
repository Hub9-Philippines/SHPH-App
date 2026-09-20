## 1. Shared skeleton widgets

- [x] 1.1 Add `TrendingProviderCardSkeleton` to `lib/components/skeleton_loading/skeleton_loading_widget.dart` mirroring `TrendingProviderCard` (196-wide rounded card, 38×38 avatar block, name/category lines, small pill block) using `SkeletonLoadingWidget` + theme tokens, with a comment pointing at the mirrored card
- [x] 1.2 Add `HomeCategoryTileSkeleton` to the same file mirroring `CategoryTileItem` (132-wide tile, 32×32 icon block, name line, short subtitle line)

## 2. Home page wiring

- [x] 2.1 In `lib/main/home/home_redesign_widget.dart`, add `bool _isHomeLoading = true;` and clear it to `false` inside the `setState` in `_loadHomeData()` (leave it alone in `onRefresh` so pull-to-refresh never flashes skeletons)
- [x] 2.2 Import `/components/skeleton_loading/skeleton_loading_widget.dart` and render 3 `TrendingProviderCardSkeleton` in the "Trending near you" rail while `_isHomeLoading` (same 154-height horizontal `ListView.separated`)
- [x] 2.3 Render 4 `HomeCategoryTileSkeleton` in the "EXPLORE SERVICES" rail while `_isHomeLoading` (same 104-height horizontal rail); keep static sections (headers, emergency, seasonal offer, referral banner) rendering normally

## 3. Verification

- [x] 3.1 Run `flutter analyze` — confirm 0 new errors
- [x] 3.2 Run `flutter test test/booking_funnel_test.dart` — confirm passing
- [ ] 3.3 Manual check on device: profile page no longer throws on the reviews endpoint; tapping "See all reviews" opens the routed reviews page with top-5 highest-rated reviews; "Load more reviews" fetches the next chunk; collector cards show reviewer, star, comment, service title, relative time; no console errors on the profile screen anymore.

---

## 4. Provider-reviews 404 fix (scoped to this session)

- [x] 4.1 Remove broken `getProviderReviews()` usage from `ProviderProfileModel.loadProvider` — the endpoint `/api/services/listings/provider/{id}/reviews/` doesn't exist (404 from gunicorn); profile now links to a dedicated reviews page instead.
- [x] 4.2 Replace the reviews stat pill with `total_completed_bookings` on the provider profile screen (`ppfCompletedBookings`).
- [x] 4.3 Add a "See all reviews" tap target on the provider profile that routes to `/provider/:providerId/reviews`.
- [x] 4.4 Add routed `ProviderReviewsWidget` page + `ProviderReviewsModel` with N+1 top-listings reviews fetch (listings ranked by review count desc, rating tiebreak; at most 8 top listings), initial 5 highest-rated reviews, scroll/page-driven "Load more reviews".
- [x] 4.5 Add `ShphProvidersApi.listProviderListingsReviews(listingId, page)` wrapping the spec'd `/api/services/listings/{id}/reviews/` endpoint; remove the non-existent `listProviderReviews(providerId)` usage.
- [x] 4.6 Add l10n keys: `ppfCompletedBookings`, `ppfCompletedBookingsSub`, `ppfSeeAllReviews`, `ppfLoadMoreReviews`, `ppfReviewsTitle` (en + fil).
- [x] 4.7 `flutter analyze` — 0 new errors.
- [x] 4.8 `flutter test test/booking_funnel_test.dart` — still passes.
- [ ] 4.9 Manual check on device: provider profile no longer crashes on reviews; tapping "See all reviews" opens the routed reviews page with the top-5 highest-rated reviews; scrolling down / tapping "Load more" fetches the next chunk; review cards show reviewer, star rating, comment, service title, relative time; no console errors on the profile screen anymore.