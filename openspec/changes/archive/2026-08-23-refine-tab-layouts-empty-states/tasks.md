## 1. Spacing tokens & shared components

- [x] 1.1 Add spacing statics to `AppThemeData` (`spaceXs=4`, `spaceSm=8`, `spaceMd=12`, `spaceLg=16`, `spaceXl=24`) with doc comment tying them to the tab-screen grid
- [x] 1.2 Update `ScreenHeader`: default padding `EdgeInsets.fromLTRB(16, 12, 16, 0)`; remove custom padding overrides at Explore/Bookings/Messages call sites; following elements own a 16px top gap
- [x] 1.3 `HeroOfferBanner`: internal padding 18→16 (`spaceLg`), headline-block → Book Now gap 14→16, margins normalized to the block-separator pattern (no left/right margin owned by the banner)
- [x] 1.4 `ProviderProximityCard`: width 220→240, price style titleSmall overridden to fontSize 15, inter-card right margin expressed as `spaceMd`; verify no truncation at typical price/distance strings

## 2. Explore screen

- [x] 2.1 Convert all horizontal paddings from 20px to 16px grid (search+categories block, section wrappers) and add explicit `SizedBox(height: spaceXl)` separators between standalone blocks (search/categories ↔ banner ↔ sections)
- [x] 2.2 Category carousel: item separator exactly `spaceMd` (real + skeleton lists), icon→label gap exact 6px, tile width 76→96 with `FittedBox(fit: BoxFit.scaleDown)` label so "Aircon Repair" renders un-truncated
- [x] 2.3 Verify promo banner sits flush in the new rhythm and InviteEarnBanner trailing margin uses the constants

## 3. Bookings screen

- [x] 3.1 Normalize screen paddings to the 16px grid (top bar, chips row, list insets, card containers already radius-16)
- [x] 3.2 Add empty-state copy resolver on `BookingsModel` returning the four chip-specific heading/description pairs (All / Pending / Completed / Canceled per brief copy), search no-match variant taking precedence when a query is active
- [x] 3.3 Wire `_buildEmptyState` to the resolver inside the existing card container (16px radius profile preserved)

## 4. Messages screen

- [x] 4.1 Normalize search field + segment container to the 16px grid: horizontal padding 20→16 for both (segment tracks search width), corner radii 22/24 → 16
- [x] 4.2 Restyle empty-state illustration container to soft teal accent (`successTeal` @12% background, `successTeal` glyph): chat bubble for Chats, telephone handset (`call_end_rounded`) for Calls history; empty card radius 28→16
- [x] 4.3 Keep section heading + teal counter capsule ("N items", including "0 items") as-is; confirm both segments swap correctly and retain their specified heading/description pairs

## 5. Verification

- [x] 5.1 Grid audit across Explore/Bookings/Messages: all full-width elements at exactly 16px side margins; 24px between standalone blocks; header-to-content gap 16px on each tab
- [x] 5.2 Empty-state matrix: activate every Bookings chip and both Messages segments against empty data and compare heading/description/icon/capsule against the spec pairs
- [x] 5.3 Truncation spot-check: category labels incl. "Aircon Repair" and proximity-card prices render fully at default text scale; dark-mode pass over all touched surfaces
- [x] 5.4 `flutter analyze` — 0 errors; `flutter test test/booking_funnel_test.dart` — no new failures
