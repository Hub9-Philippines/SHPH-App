## Context

See proposal.md — Why. The routed home page is `HomeRedesignWidget` (`lib/main/home/home_redesign_widget.dart`); it imperatively loads four datasets in `_loadHomeData()` via `Future.wait` (bookings, categories, trending providers, nearby recommendations) and stores them in plain lists. There is no loading flag, so the always-visible rails ("Trending near you", "EXPLORE SERVICES") render empty until the futures resolve — a blank flash on cold start.

The shared shimmer primitive already exists: `SkeletonLoadingWidget` (`lib/components/skeleton_loading/skeleton_loading_widget.dart`) plus page-shaped cards (`BookingCardSkeleton`, `MessageCardSkeleton`, `ServiceCardSkeleton`, `ProfileHeaderSkeleton`, …). Bookings renders `BookingCardSkeleton` ×3 in a sliver list while `_model.isLoading`; Messages renders `MessageCardSkeleton` ×4 per tab. The Profile page already shows `ProfileHeaderSkeleton` + `ProfileMenuItemSkeleton` while its profile future is pending — no profile work needed.

## Goals / Non-Goals

**Goals:**
- Replace the empty-rail flash on the home page with shimmer skeletons that map 1:1 onto the final layout (skeleton shape ≈ real card shape), matching the Bookings/Messages pattern.
- Reuse `SkeletonLoadingWidget` and the existing shared skeleton file; keep the change additive.

**Non-Goals:**
- No skeleton redesign of the Profile page (already implemented — tasks include only a regression check).
- No per-section FutureBuilder refactor of the home data flow.
- No skeleton on pull-to-refresh (refresh keeps content; the `RefreshIndicator` spinner is the affordance, matching spec scenario 3).

## Decisions

### D1: Plain `_isHomeLoading` bool instead of per-section FutureBuilders
Add `bool _isHomeLoading = true;` (field initializer, so no `setState`-before-first-build issue since `_loadHomeData()` runs from `initState`), and clear it to `false` inside the existing `setState` that assigns the loaded lists. `onRefresh` (`_loadHomeData`) leaves the flag alone so pull-to-refresh never flashes skeletons.
- *Alternative considered:* per-section `FutureBuilder`s gated on `ConnectionState.waiting` (Profile's pattern). Rejected: it rewrites the existing imperative load flow for little gain — a single flag is a smaller, safer diff and the sections render from the same lists.

### D2: New skeleton cards live in the shared skeleton file
Add to `lib/components/skeleton_loading/skeleton_loading_widget.dart`:
- `TrendingProviderCardSkeleton` — width 196, rounded card with border, 38×38 rounded avatar block, name/category lines, and a small "Online"-pill-sized block, mirroring `TrendingProviderCard` (`lib/components/prototype_components.dart`).
- `HomeCategoryTileSkeleton` — width 132, 32×32 rounded icon block plus a name line and short subtitle line, mirroring `CategoryTileItem`.
- Reuse existing `ServiceCardSkeleton` if the "Recommended for you" list is ever shown during load.
Skeleton surfaces use `AppTheme` tokens (`primaryBackground`/`alternate`) so dark mode matches the existing skeletons. *Alternative considered:* inline skeleton widgets in the home widget file — rejected, the project convention is shared skeleton components in the skeleton file (Bookings/Messages/Profile all import it).

### D3: Skeleton scope during initial load
While `_isHomeLoading`:
- "Trending near you" rail → 3 `TrendingProviderCardSkeleton` in the existing horizontal `ListView.separated` (same height 154).
- "EXPLORE SERVICES" rail → 4 `HomeCategoryTileSkeleton` in the existing rail (same height 104).
- Section headers, `EmergencyHelpCard`, `SeasonalOfferCard`, `ReferralBannerCard` render as normal (static content, zero data dependency).
- "Your bookings" and "Recommended for you" are conditional on loaded data (booking history), so they simply appear once data arrives — no skeleton for them.
*Alternative considered:* skeletons for every possible section including bookings/recommended. Rejected: their visibility depends on data that hasn't loaded yet, so a faithful skeleton is impossible without guessing.

## Risks / Trade-offs

- [Skeleton briefly visible when data resolves fast] → Skeleton load is already cheap (no network waits); the flash is a single frame at most, same as Bookings/Messages.
- [Pull-to-refresh leaves stale content while re-fetching] → Acceptable and already the case; the refresh indicator communicates the in-flight state (spec scenario 3).
- [New skeleton cards drift from card designs over time] → They mirror current `prototype_components.dart` dimensions; a comment in each skeleton class pointing at the card it mirrors keeps them in sync.

## Migration Plan

Single commit-sized change: no data/API migration. Rollback = revert the widget + skeleton-file edits. CI (`flutter analyze`, `flutter test test/booking_funnel_test.dart`) guards the change.

## Open Questions

None.