## 1. Profile hub rebuild

- [x] 1.1 Replace the teal gradient hero with the white header block: 72px avatar in 2px royal-blue ring, bold name / phone / muted email column, blue-outlined pencil "Edit Profile" pill; keep avatar upload + edit routing
- [x] 1.2 Remove the Dark Mode toggle tile and `_model.switchValue` usage; delete hero footer (Account Status/Saved Places/Theme)
- [x] 1.3 Rebuild sections: ACCOUNT (My Bookings → Bookings tab, Payment & Invoices → payment methods, Language Preference → language settings), PREFERENCES & UTILITIES (Favorites, My Reviews, Referral Program → invite surface, Notification Settings → notifications settings entry, Help Center → help), SYSTEM ACCESS (provider switch row via Switch.adaptive, destructive Log out row) — all rows on the tinted-row component with #F8F9FA radius-16 containers and uppercase muted slate group headers
- [x] 1.4 Force strict light rendering on this screen (white canvas/card tints from fixed light values); grep-verify zero remaining dark-mode references on the screen

## 2. Notifications feed rework

- [x] 2.1 Replace ScreenHeader with bespoke white bar: back chevron (pop), centered bold "Notification", gear absolute-right opening the notification settings destination
- [x] 2.2 Add `NotificationFilter` enum {all, bookings, offers, system} to model with a `matchesType(AppNotification)` heuristic mapping `AppNotification.type` (book/confirm/remind→bookings; offer/promo→offers; else system) and chip state field
- [x] 2.3 Render capsule filter chip row below header (All active solid royal blue; inactive gray bg dark text) filtering the list
- [x] 2.4 Rebuild feed as ListView.separated with ultra-thin dividers: 44px circular badge (two-letter code from title initials or icon glyph), bold title + right-aligned muted relative timestamp (+ unread dot), clamped 2-line description; preserve mark-read/mark-all/tap-routing/polling methods verbatim

## 3. Verification

- [ ] 3.1 Profile pass: header anatomy correct; all section rows navigate to spec destinations; provider switch renders; Log out still confirms; zero dark-mode controls or gradient remnants
- [ ] 3.2 Notifications pass: chips filter correctly per type mapping and restyle on selection; badge codes/timestamps/descriptions render; tap still marks read + routes; gear opens settings
- [ ] 3.3 Strict-light check: both screens render identically regardless of app theme preference
- [x] 3.4 `flutter analyze` — 0 errors; `flutter test test/booking_funnel_test.dart` — no new failures
