## 1. Home Page Section Behavior

- [x] 1.1 Inspect the home-page booking, trending, and help section composition and identify the existing booking collection and trending visibility condition.
- [x] 1.2 Gate the "Your bookings" section on the presence of at least one displayable booking, removing its heading and empty-state content when the collection is empty.
- [x] 1.3 Remove the conditional gate that hides "Trending near you" and place the section immediately before "Need help right now" while preserving its existing content and state handling.

## 2. Profile Bottom Sheet

- [x] 2.1 Replace the home-page profile button's current modal callback with `showModalBottomSheet` while preserving the existing profile actions and destinations.
- [x] 2.2 Preserve theme, safe-area, barrier-dismiss, back-dismiss, and action-dismiss behavior for the profile bottom sheet.

## 3. Verification

- [x] 3.1 Add or update focused home-page tests covering users with bookings, users without bookings, trending placement/visibility, and profile bottom-sheet opening and dismissal.
- [x] 3.2 Run the focused home-page tests and `flutter analyze`, confirming no new errors and no regressions in the affected layout or interaction behavior.
