## 1. Emergency foundations

- [x] 1.1 Create `lib/utils/emergency_categories.dart`: `coreEmergencyCategories` set (Electrical, Locksmith, Plumbing, Pest Control) + `isEmergencyCategory(String)` case-insensitive matcher
- [x] 1.2 Create `lib/components/instant_dispatch_section.dart`: inline card with 15-min / 15–30-min window chips, guarantee copy, and an onDispatch callback
- [x] 1.3 Create `lib/components/quick_book_bar.dart`: persistent safe-area bar with urgency micro-copy + filled royal-blue "Urgent Assistance" button (bolt glyph)

## 2. Discovery surfaces (Explore + Categories)

- [x] 2.1 Explore: render `QuickBookBar` as the screen's base scaffold area; add attention border + lightning badge to emergency tiles in the category rail via the shared matcher
- [x] 2.2 Explore: when a selected category is emergency, reveal `InstantDispatchSection` beneath the rail; dispatch chips launch BookingFlowScreen with rightNow urgency + category preset
- [x] 2.3 Categories page: add root pull-to-refresh (canonical pattern), normalize scaffold color to theme tokens, flag emergency categories in the grid, and mount the same QuickBookBar
- [x] 2.4 Services category rail: apply emergency flags; selecting an emergency category reveals the Instant Dispatch section inline

## 3. Search results (`/services`)

- [x] 3.1 Header: add micro-location selector pill (active location label → location selection route) beside the search input; keep back chevron; restyle sort row into compact filter chips row
- [x] 3.2 Rebuild result cards: oversized square image showcase, provider name + conditional verified badge, "X.X km away" sub-text, star-rating badge, clamped multi-line description, "Starting Fee" tag, solid royal-blue Book Now button routing to the funnel
- [x] 3.3 Emergency mode: when entered via Urgent Assistance, limit rail + results to the four domains and preset urgency on any launched booking

## 4. Confirm booking checkout

- [x] 4.1 Introduce controller-held step index with progress line tracker header (reuse `_SetupProgress` visual language) and functional per-step back that preserves state
- [x] 4.2 Step: specialist summary row (avatar, verified badge, name, ratings summary, proximity marker) from listing/provider data
- [x] 4.3 Step: service selection matrix — checkbox rows with exact pricing tags, FASTEST container on urgent rows, selection set driving the total
- [x] 4.4 Step: location context widget — address line bound to draft, CHANGE trigger reusing `_pickAddress`, optional landmarks input persisted into booking notes
- [x] 4.5 Step: "Require Arrival Code" isolated row with info hint bottom-sheet and right-aligned switch persisted into draft notes metadata
- [x] 4.6 Payment matrix: Tier 1 Cash/Digital segmented control; Digital reveals horizontal carousel of GCash/Maya/Card/QR Ph glyph cards; single-active-method enforcement across tiers
- [x] 4.7 Sticky footer: "Total Price Due:" amount + full-width royal-blue CTA labeled "Book {Category} Now →"; submission routes through active method (GCash/QR Ph via e-wallet path, documented debt)

## 5. Verification

- [ ] 5.1 Discovery pass: all four emergency tiles flagged on every surface; QuickBookBar reachable on Explore + Categories; urgent entry presets urgency and limits domains; dispatch windows launch pre-set funnels
- [ ] 5.2 Results pass: card anatomy complete against spec incl. Book Now binding; header pill opens location flow; filters still sort correctly
- [ ] 5.3 Checkout pass: step navigation preserves entries; matrix drives total; landmarks + arrival-code persist into created booking notes; payment tiers enforce single active method; CTA label adapts per category
- [x] 5.4 Color audit: workflow renders royal-blue primaries only — no teal introduced anywhere in the three screens
- [x] 5.5 `flutter analyze` — 0 errors; `flutter test test/booking_funnel_test.dart` — no new failures
