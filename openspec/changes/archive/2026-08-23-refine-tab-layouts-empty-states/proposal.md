## Why

The three main navigation tabs drifted apart during rapid feature work: horizontal margins vary between 16/20px depending on which screen or component renders them, block-to-block spacing is ad hoc, the Explore category carousel clips long labels ("Aircon Repair"), proximity cards truncate their price field ("Starting P..."), and both Bookings and Messages show generic empty boxes that ignore which filter or segment the user has active. This change locks all tab screens to one layout grid and makes every empty state context-aware.

## What Changes

- **Global grid** — normalize ScreenHeader geometry (16px bottom gap to following content, 16px horizontal margins) across Explore, Bookings, Messages; enforce 16px horizontal margins on all cards, segmented controls, banners, and inputs; add an explicit 24px vertical margin between standalone page blocks.
- **Spacing tokens** — introduce named spacing constants (4/8/12/16/24) on `AppThemeData` so the grid is enforced by construction rather than by scattered literals.
- **Explore category carousel** — exact 12px item gaps, exact 6px icon-to-label gap, and no label truncation for long names like "Aircon Repair" (wider tile + scale-down fallback).
- **Explore promo banner** — 16px internal padding, 16px between headline block and the Book Now action.
- **Explore proximity cards** — wider bounding box plus a 1px-smaller price style so "Starting Price" never ellipsizes; keep the crisp 12px column separation.
- **Bookings empty states** — replace the static placeholder with per-filter copy: All → "No bookings found" / Pending → "No pending jobs" / Completed → "No completed visits yet" / Canceled → "No canceled bookings", each with its specified description.
- **Messages segmented area & empty states** — align the Chats/Calls history segment container to the same grid and 16px radius profile as the search bar above it; per-segment empty states with teal-accented illustration containers (chat bubble vs telephone handset), section heading, and right-aligned teal counter capsule showing "N items".
- Typography family (Plus Jakarta Sans), 16px corner-radius profiles, white canvas backdrop, and the royal-blue / light-teal / deep-purple brand palette remain unchanged.

## Capabilities

### New Capabilities
- `tab-screen-layouts`: Shared layout-grid rules for the main tab screens (header geometry, 16px horizontal grid, 24px block separation) and the context-aware empty-state contracts for the Bookings filter chips and the Messages segment toggle.

### Modified Capabilities

## Impact

- `lib/theme/app_theme.dart` — additive spacing constants only
- `lib/components/screen_header.dart`, `hero_offer_banner.dart`, `provider_proximity_card.dart`
- `lib/main/explore/explore_widget.dart` (carousel tiles, block spacing)
- `lib/main/bookings/bookings_widget.dart` (+ model) — filter-driven empty-state resolver
- `lib/main/messages/messages_widget.dart` — segmented container alignment, radius normalization, teal empty-state illustrations
- No backend/API changes; no route changes; no dependency changes.
