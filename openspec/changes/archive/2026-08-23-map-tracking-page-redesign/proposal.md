## Why

The map tracking screen (`StatusPage`) buries its map under a solid top bar, shows a collapsible sheet with redundant double checkmarks, and offers no completion actions; the brief also calls for app-wide brand correction — the current light-blue `primary` (#368EFF) reads washed-out next to the royal blue (#1E3A8A) the Bookings redesign established — and pull-to-refresh behavior that differs between Profile and the other tabs.

## What Changes

- **Map Tracking Page** (`lib/pages/booking_funnel/status_page.dart`):
  - Google Map becomes the full-screen background layer behind all overlays.
  - New circular floating back button (left chevron, white surface, drop shadow) pinned top-left over the map.
  - The provider top bar becomes a floating card hovering near the top-center of the map: rounded corners, avatar, name, status chip, and instant Call/Message action icons.
  - Bottom sheet becomes a non-collapsible white card anchoring the lower 45% of the viewport with 24px top corner radius.
  - Timeline stepper cleanup: exactly one green checkmark per completed stage on the left track line; the secondary check-circle glyph beside completed titles is removed.
  - The booking-date detail container condenses into a compact polished horizontal badge.
  - When status is Completed: full-width deep-emerald "Write a Review" primary button with a "View Invoice" text link beneath it.
- **Pull-to-refresh parity**: Explore and Bookings adopt the Profile page's exact mechanism — `RefreshIndicator` tinted with theme primary wrapping scroll views that use bouncing scroll physics rooted in always-scrollable physics, present in every UI state (loading, error, empty, content).
- **Primary color swap**: `AppThemeData.primary` changes from #368EFF to the bookings royal blue #1E3A8A in both light and dark factories, replacing the light blue app-wide (buttons, links, tints, indicators).

## Capabilities

### New Capabilities
- `map-tracking-screen`: Layout and interaction contract for the full-bleed map tracking screen — floating overlays, fixed bottom sheet anatomy, stepper presentation, date badge, and completed-state actions.
- `pull-to-refresh-parity`: The canonical pull-to-refresh pattern shared by Profile, Explore, and Bookings.
- `app-primary-color`: The single primary brand color for the application across light and dark modes.

### Modified Capabilities

## Impact

- `lib/pages/booking_funnel/status_page.dart` — major rework (layout stack, sheet, stepper rows, actions)
- StatusPage call sites threaded with `bookingReference` where a real booking id exists: `lib/main/bookings/bookings_widget.dart`, `lib/pages/booking_details/booking_details_widget.dart`, `lib/main/home/home_widget.dart`
- `lib/components/refreshable_page.dart` (mixin alignment), `lib/main/explore/explore_widget.dart`, `lib/main/bookings/bookings_widget.dart`
- `lib/theme/app_theme.dart` — primary color constants only
- Depends on existing routes: WriteReviewWidget (booking id), ContactProviderWidget (call/message). Invoice has no Flutter surface yet — link ships with graceful inline feedback (documented fallback).
