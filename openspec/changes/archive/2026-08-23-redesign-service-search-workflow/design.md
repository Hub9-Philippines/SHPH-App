## Context

Current surfaces:

- **Explore** (`lib/main/explore_widget.dart`): search + category rail + banner + carousels + invite banner inside `wrapWithRefresh`; no quick-book area, no emergency concepts.
- **Categories** (`/categories` → `categories_widget.dart`): static grid via `components/categories_widget`, back button, hardcoded `0xFFF4F7FB` scaffold; no refresh, no flags.
- **Services results** (`/services` → `services_widget.dart`, 868 lines): back+title top bar, search bar, hero summary, category rail, sort chips (`_filterLabels`: recommended/topRated/lowestPrice/nearest), RefreshIndicator already present, results rendered further down (cards to be rebuilt). No location pill, no verified/distance/rating card anatomy.
- **Funnel**: setup screen has "Step N of 3" pills + `_SetupProgress` pattern to reuse; express checkout has payment pills (Cash/COD/Card) and `_TotalCard`; checkout screen has address picking via `EditAddressWidget` bottom sheet feeding `controller.setAddress`. Booking draft (`BookingDraft`) holds address/urgency/paymentMethod; controller exposes `setAddress/setPaymentMethod`. No arrival-code field, no service-selection matrix in checkout, no nested digital options, no dynamic CTA label.
- Theme: `primary` = #1E3A8A (royal blue, just swapped app-wide); `actionPrimary` alias exists; spacing constants `spaceXs…spaceXl` exist. Teal tokens exist for other flows — this workflow simply doesn't use them.

## Goals / Non-Goals

**Goals:**
- Emergency prioritization visible at every discovery surface, with one-tap urgent entry.
- Results that answer trust questions (verified? how far? how good? price?) in one glance.
- A checkout spine with all decision inputs (services, location detail, arrival security, payment) on one adaptive flow ending in an unmissable CTA.

**Non-Goals:**
- New payment provider integrations — GCash/QR Ph ride the existing e-wallet/card processing path until dedicated providers ship (documented follow-up).
- Real dispatch/ETA guarantees — Instant Dispatch windows are booking-time urgency presets; matching behavior unchanged.
- Provider verification data plumbing — badge renders from whatever verification signal exists per listing/provider; absence hides the badge rather than faking it.

## Decisions

1. **Emergency domain source of truth**: new `lib/utils/emergency_categories.dart` exporting `coreEmergencyCategories = {'Electrical','Locksmith','Plumbing','Pest Control'}` + `bool isEmergencyCategory(String name)` (case-insensitive contains-match against category names/slugs). All three surfaces consume it — single definition prevents drift.
2. **Attention flag styling**: emergency tiles get a 1.5px royal-blue-to-transparent attention border plus a small "24/7" lightning badge chip; standard tiles unchanged. Blue (not red) keeps alarm fatigue low while staying on-brand; brief says "subtle border or status indicator" — we do both cheaply.
3. **Quick Book scaffold**: implemented as `Scaffold.bottomNavigationBar`-positioned safe container on Explore + Categories (persistent, not scroll-dismissable): left side explanatory micro-copy ("Emergencies can't wait"), right side filled royal-blue "Urgent Assistance" button (bolt icon). Action routes into ServicesScreen with `initialFilter: 'emergency'`-style flag → new `emergencyMode` on ServicesModel limiting the rail/results to the four domains with urgency preset rightNow in any launched funnel. Reused on both screens via one component `components/quick_book_bar.dart`.
4. **Instant Dispatch section**: inline card directly beneath the category rail / selected-category header when `isEmergencyCategory(selected)`; two window chips ("Within 15 min", "15–30 min") + copy guaranteeing arrival windows; selecting launches the funnel (`BookingFlowScreen`) with draft urgency rightNow + chosen category preset. Component: `components/instant_dispatch_section.dart`.
5. **Results header additions**: location pill reads `FFAppState().selectedLocationLabel` (or nearest-city fallback), tap pushes the existing geographic-selection route used elsewhere; filter row keeps existing four sorts restyled as compact segmented chips.
6. **Result cards**: rebuild on ServiceListing fields — thumbnail (square, ~96px oversized showcase left), title + verified badge (shown when `listing.providerVerified` if mapped, else hidden — add mapping only if API exposes it; otherwise badge derives from rating threshold ≥4.8 & reviewCount ≥ 20 as "Top Pro"? NO — fabricating verification is wrong; hide when unknown), distance line from `distanceKm` (hidden when null), star badge via `ratingValue`, description `listing.description` clamped 2 lines, price tag `formattedPrice` prefixed "Starting Fee", Book Now → funnel. Card tap opens product detail as today.
7. **Checkout spine**: extend express checkout's existing single-page into a 3-step stepper reusing the `_SetupProgress` visual language: Step 1 Services & Location, Step 2 Security & Payment, Step 3 Review & Confirm — progress line tracker across tops of each step page; back button pops step state (controller-held step index) so entries persist.
8. **Service matrix**: rows generated from the listing's service breakdown where available (cleaning rooms matrix analog) or single default row ("{Service title} — {price}"); checkbox rows, FASTEST tag when `isEmergencyCategory(listing.categoryName)` or urgency rightNow. Selection set lives on the controller; total = Σ selected exact prices (+ urgency fee).
9. **Location widget**: address line binds `draft.address`; CHANGE reuses `_pickAddress` bottom sheet; landmark input writes `controller.setLandmarks()` → appended into notes at creation ('Landmarks: …'), keeping create-contract untouched (notes-only channel).
10. **Arrival code toggle**: `requireArrivalCode` bool on controller/draft (default true to match server PIN flow); info icon shows tooltip/bottom-sheet explaining the start-PIN handshake. Persisted into notes metadata like other client-side flags until backend field exists (documented).
11. **Payment matrix**: Tier 1 segmented Cash/Digital replacing current pills; Tier 2 horizontal carousel of four glyph cards (GCash, Maya, Card, QR Ph) — Maya binds existing Maya processing, Card binds Stripe, GCash/QR Ph initially process through the e-wallet path with method label carried in paymentStatus/notes (documented limitation, backend follow-up flagged in tasks).
12. **Sticky footer CTA**: replaces `_TotalCard` positioning — fixed bottom bar "Total Price Due:" + amount left, full-width royal-blue FilledButton right/below with label `"Book ${categoryLabel} Now →"` (arrow glyph), category from selected listing/category rail choice; falls back to "Book Now →".
13. **Color discipline**: workflow uses `theme.primary`/`actionPrimary`, neutral grays, white surfaces; successTeal/destructiveSoft untouched outside this scope. No token changes required.

## Risks / Trade-offs

- [GCash/QR Ph without native SDKs may mislead] → Method labels carry intent; payment executes through existing rails; follow-up task records the integration debt explicitly.
- [Verified-badge absence could look inconsistent] → Hiding unknown-state badges is honest; spec wording requires badge "when verification is known".
- [Three-step checkout adds taps vs single page] → Progress spine + persistent state keeps cost low; matches brief's explicit multi-step requirement.
- [Emergency matching by name contains may catch near-duplicates] → Acceptable over-matching beats missing an electrical emergency; constants file centralizes tuning.

## Migration Plan

Four slices, each analyze-green: (1) emergency constants + flags + instant dispatch on discovery screens; (2) quick-book bar on both landings; (3) services header/cards rework; (4) checkout rework + threading. Rollback per slice.

## Open Questions

None blocking. Payment-provider depth and verification-data sourcing are documented follow-ups.
