## Why

The Bookings and Messages tabs already show shimmer skeleton cards while their data loads, but the home page (`HomeRedesignWidget`) renders its data-driven sections empty until `_loadHomeData()` resolves — users see a blank flash of the trending/categories rails on every cold start. The Profile page already shows a skeleton header + menu items while loading (added in prior commits), so the remaining gap is the home page.

## What Changes

- Home page shows shimmer skeleton placeholders in place of its always-visible data-driven sections while the initial feed is loading, then swaps them for real content once loaded (mirroring the Bookings/Messages skeleton pattern).
- New reusable skeleton widgets for the home layout are added to the shared `lib/components/skeleton_loading/skeleton_loading_widget.dart` (trending-provider rail card + category tile), alongside the existing `BookingCardSkeleton`/`ServiceCardSkeleton`/`CategoryCardSkeleton`.
- Pull-to-refresh keeps showing the current content (the refresh spinner is the loading affordance); skeletons appear on initial load only.
- Profile page: no code change — it already renders `ProfileHeaderSkeleton` + `ProfileMenuItemSkeleton` while the profile future is pending. The change only verifies that behavior remains intact (regression check in tasks).

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `home-screen-experience`: adds a loading-state requirement — while the home feed is loading, the page SHALL render shimmer skeleton placeholders for its data-driven sections instead of empty rails, and replace them with content when loaded.

## Impact

- `lib/main/home/home_redesign_widget.dart` — add an `_isHomeLoading` flag and skeleton branch in the build.
- `lib/components/skeleton_loading/skeleton_loading_widget.dart` — add `TrendingProviderCardSkeleton` and `HomeCategoryTileSkeleton` widgets (reuse existing `SkeletonLoadingWidget` shimmer primitive; reuse `ServiceCardSkeleton` for the recommended list if shown during load).
- No API, dependency, or localization changes. Dark-mode safe: skeletons use `AppTheme` tokens (`alternate` / `primaryBackground`) like the existing ones.