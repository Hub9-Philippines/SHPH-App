## 1. Shared map/sheet host

- [x] 1.1 Add `lib/pages/booking_funnel/widgets/booking_map_sheet_host.dart` with a `Stack` that paints the map child `Positioned.fill` and layers the sheet on top, so full-bleed coverage is structural and the map's bottom edge can no longer be bounded.
- [x] 1.2 Add sheet-content-height capture to the host (callback shape matching the existing `_handleSheetContentHeightChanged`), so the host learns the real height of whichever panel is rendered.
- [x] 1.3 Derive the map's camera padding from the measured sheet height inside the host, replacing any fixed pixel approximation; keep `MediaQuery.padding.bottom` for nav-bar/gesture clearance.
- [x] 1.4 Add a viewport-derived fallback padding used until the first measurement lands, then re-frame once the real height arrives; no error state and no layout break on the first frame.
- [x] 1.5 Pass the map child through unmodified (no extra `Consumer`/`AnimatedBuilder` wrapper) so the radar ripple's per-tick `ValueListenableBuilder` isolation and the "no full-map rebuild" guarantee are preserved.
- [x] 1.6 Support an optional resizable extent (min/initial/max fractions) so a draggable sheet's live extent feeds the padding, while still capping the sheet and scrolling its content when it exceeds the permitted extent.

## 2. Migrate BookingFlowScreen

- [x] 2.1 Replace `final sheetOverlap = 300.0` in `lib/pages/booking_funnel/booking_flow_screen.dart` with the host's measured value; delete the constant.
- [x] 2.2 Move the `GoogleMap`, gradient scrim, and `_FlowTopCard` layers into the shared host without changing their order, and keep the `showMap`-style guards and `onCameraIdle` → `BookingFlowController.setCoordinates` wiring intact.
- [x] 2.3 Confirm the pin stays framed in the band above the sheet for both `LocationConfirmationPanel` and `TimeSelectionPanel`, and that the camera re-frames when the step swaps.
- [x] 2.4 Leave the panels' own padding, corner radii, grab handle, and `SafeArea(top: false)` usage unchanged — only the map's framing is in scope.

## 3. Migrate BookingStatusScaffold

- [x] 3.1 Replace the non-draggable `Positioned(top:0, left:0, right:0, bottom: sheetMaxHeight)` map bound with full-bleed coverage, which is the change that removes the background band between the map and the sheet.
- [x] 3.2 Replace the draggable-mode `EdgeInsets.only(bottom: 48 + bottomInset)` offset with the host's extent-derived padding so the map tracks the sheet while it is dragged.
- [x] 3.3 Keep `_RadarMapLayer`, the `radarScan` controller passthrough, the gradient background layer, `center`, and `topCard` layering and ordering unchanged.
- [x] 3.4 Preserve the `showMap: false` short-circuit so no map widget is constructed on the map-free path, per `map-less-booking-tracking`.
- [x] 3.5 Verify `checkout_screen.dart` and `express_checkout_screen.dart` need no signature changes and that the radar/scan-radius specs' scenarios still hold.

## 4. Migrate LiveMatchingScreen onto the shared host

- [x] 4.1 Replace the screen-private `_sheetContentHeight`, `_dynamicMaxSheetExtent`, and `_bottomSheetExtent` plumbing with the shared host's equivalent, keeping `_handleSheetNotification` behavior.
- [x] 4.2 Preserve the existing extent clamps (`_collapsedSheetExtent` → `_expandedSheetExtent`), the `NotificationListener<DraggableScrollableNotification>` wiring, and the assign/route methods (`_openStatusPage`, `_openBookingsPage`).
- [x] 4.3 Confirm no behavior change on this screen: same zoom, same client/provider markers and hues, same matching/timeout sheets, and no new per-tick rebuilds.

## 5. Tests

- [x] 5.1 Add a widget test asserting the map renders full-bleed and the camera padding equals the measured sheet height for a tall panel and a short panel.
- [x] 5.2 Add a widget test asserting padding increases/decreases when the displayed step swaps to a taller/shorter panel.
- [x] 5.3 Add a widget test asserting a short sheet leaves no background gap between the map and the sheet's top edge.
- [x] 5.4 Add a widget test for a resizable sheet: padding tracks the extent during drag and matches the resting extent after release.
- [x] 5.5 Add a regression test that a screen with the map disabled builds no map widget.
- [x] 5.6 Add a regression test that a radar-scan tick rebuilds the circle layer only, not the map or sheet subtree.
- [x] 5.7 Run `flutter analyze` (must stay at 0 errors) and the booking/call test subset; the full suite is expected to fail only on the known-stale `test/widget_test.dart`.

## 6. Documentation

- [x] 6.1 Add a `## 5. Page anatomy` section to `docs/app-map.md` covering every important page (shell, the 4 tab pages, core discovery, both booking funnels, chat, settings/KYC/auth): build-outermost widget, ordered direct children, private widget classes, shared components, and key state fields.
- [x] 6.1a While writing it, correct the stale claims that section surfaced: the legacy `BookingWidget` renders **4** step cards (not 3); the `/home` path constant belongs to `HomeWidget` while the builder returns `HomeRedesignWidget`; add the missing `setup/booking_setup_screen.dart`, `BookingSuccessScreen`, and the `widgets/` panel-to-class table; note that `StatusPage` has no map by design and that `BookingStepIndicator` is unused by the funnel.
- [x] 6.2 Document the new shared host in `docs/app-map.md` §5.4 once it exists, and record that `BookingFlowScreen`, `BookingStatusScaffold`, and `LiveMatchingScreen` all derive map framing from it.
- [x] 6.3 Re-verify the §3 page-inventory route tables. The anatomy section was source-verified, but the ~85-row inventory in §3 was not re-checked row by row.

## 7. Verification

- [ ] 7.1 Manually walk the setup steps (location confirm → time selection), checkout, express checkout, and live matching; confirm the map is full-bleed with no white gap in any of them.
- [ ] 7.2 Repeat on a small phone and a tall device, in `en` and `fil`, at text scale 1.0 and 2.0.
- [ ] 7.3 Open the address-edit and date/time pickers to confirm the layout holds while the keyboard is up.
- [ ] 7.4 Confirm the radar ripple stays pinned through zoom and rotation and re-frames as the scan radius widens.
- [ ] 7.5 Confirm the map-free tracking screen still builds no map and uses the freed canvas for its timeline content.
