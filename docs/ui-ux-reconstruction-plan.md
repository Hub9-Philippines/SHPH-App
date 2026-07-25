# UI/UX Reconstruction Plan — SHPH Flutter App

**Branch:** `feat/ui-ux-reconstruction`
**Reference:** `C:\Users\Administrator\dev\shph-web` (Vue 3 + Ionic 8 web app)

---

## 1. Current Flutter App vs Web App — Overview

| Dimension | Flutter App | Web App (Reference) |
|-----------|-------------|---------------------|
| **Framework** | Flutter (Dart) | Vue 3 + Ionic 8 + Capacitor 8 |
| **State Mgmt** | FlutterFlow models + FFAppState | Pinia stores |
| **Styling** | `AppTheme` (custom `ThemeExtension`) | CSS custom properties + design tokens |
| **Routing** | GoRouter | vue-router 5 |
| **Pages** | ~25 widget pages | ~100+ page views |
| **Components** | ~15 shared components | ~40 shared components |
| **Chat** | Basic text + real-time Supabase | Full chat + voice messages + stickers + calls |
| **Payments** | Hardcoded methods (GCash/Card/CoD) | PayMongo integration |
| **Offline** | None | IndexedDB + Workbox service worker |
| **Maps** | Google Maps | Leaflet |
| **AI** | None | Gemini API integration |
| **KYC** | Basic | Full ID scan + liveness detection |
| **Calls** | None | WebRTC 1:1 + group (mediasoup) |

---

## 2. Design System Alignment

### 2.1 Colors

The web app uses CSS custom properties (`--shph-*`) defined in `src/theme/variables.css`.
The Flutter app uses `AppThemeData` in `lib/theme/app_theme.dart`.

**Key Color Tokens (Web → Flutter):**

| Token | Web Value | Flutter Equivalent | Status |
|-------|-----------|-------------------|--------|
| `--shph-primary` | `#0F8A6C` | `AppTheme.of(context).primary` | ✅ Exists |
| `--shph-primary-dark` | `#0B6B54` | — | ❌ Missing |
| `--shph-primary-light` | `#17B890` | — | ❌ Missing |
| `--shph-secondary` | `#F59E0B` | (provider mode amber) | ❌ Missing |
| `--shph-background` | `#F4F7FB` | `Color(0xFFF4F7FB)` | ✅ Partial |
| `--shph-surface` | `#FFFFFF` | `Colors.white` | ✅ |
| `--shph-text-primary` | `#14213D` | `Color(0xFF14213D)` | ✅ Partial |
| `--shph-text-secondary` | `#64748B` | `Color(0xFF64748B)` | ✅ Partial |
| `--shph-error` | `#EF4444` | `AppTheme.of(context).error` | ✅ |
| `--shph-success` | `#10B981` | — | ❌ Missing |
| `--shph-warning` | `#F59E0B` | — | ❌ Missing |
| `--shph-radius-sm` | `8px` | `8.0` | ✅ |
| `--shph-radius-md` | `16px` | `16.0` | ✅ |
| `--shph-radius-card` | `24px` | `24.0` | ✅ |
| `--shph-shadow-card` | `0 10px 18px rgba(0,0,0,0.07)` | `BoxShadow` | ❌ Not standardized |

### 2.2 Typography

**Web:** "Plus Jakarta Sans" via Google Fonts (currently commented out fallback to system sans-serif).
**Flutter:** Already uses `GoogleFonts.poppins()` throughout.

Consider aligning to "Plus Jakarta Sans" on Flutter side to match the brand.

### 2.3 Spacing Scale

The web app uses a utility-based spacing scale in `utilities.css`. The Flutter app uses ad-hoc `SizedBox` values.
Standardize on a 4px base unit scale: 4, 8, 12, 16, 20, 24, 32, 40, 48, 56, 64.

---

## 3. Component Library Gap Analysis

### 3.1 Shared Components (Flutter) — Status

| Component | Flutter | Web (Vue) | Action |
|-----------|---------|-----------|--------|
| `AppBar` / Header | Per-page custom headers | `ScreenHeader.vue` | Standardize with `ScreenHeader` |
| `SectionHeader` | Inline in pages | `SectionHeader.vue` | Create reusable component |
| `ServiceCard` | Inline in home/services | `ServiceCard.vue` | Extract to shared card component |
| `BookingCard` | Inline | `BookingCard.vue` | Extract to shared component |
| `StarRating` | Inline 5-star display | `StarRating.vue` | **Create reusable** |
| `StatusPill` | Hardcoded containers | `StatusPill.vue` | Create standardized pill |
| `EmptyState` | Ad-hoc checks | `EmptyState.vue` | Create reusable |
| `ErrorState` | ScaffoldMessenger | `ErrorState.vue` | Create reusable |
| `UserAvatar` | `CircleAvatar` | `UserAvatar.vue` | Standardize with fallback initials |
| `CategoryTile` | Inline grid in home | `CategoryTile.vue` | Extract to reusable |
| `SoftCard` | Inline containers | `SoftCard.vue` | Extract to reusable card |
| `ReviewCard` | Inline | `ReviewCard.vue` | Extract to shared |
| `Modal / BottomSheet` | `showModalBottomSheet` | `ion-modal` (bottom sheet) | Standardize |
| `Loading / Skeleton` | `SkeletonLoadingWidget` | Ionic `ion-skeleton-text` | Already has ✅ |
| `SearchField` | Per-page TextFormField | `SearchableSelect.vue` | Standardize search |

### 3.2 New Components to Create (port from Web)

| Component | Web Source | Priority | Notes |
|-----------|-----------|----------|-------|
| `ScreenHeader` | `src/components/ScreenHeader.vue` | High | Consistent page titles with back button |
| `SectionHeader` | `src/components/SectionHeader.vue` | High | Title + "See all" link |
| `ServiceCard` | `src/components/ServiceCard.vue` | High | Used across home, search, category pages |
| `BookingCard` | `src/components/BookingCard.vue` | High | Booking list items with status |
| `StarRating` | `src/components/StarRating.vue` | High | Reusable 5-star display/input |
| `StatusPill` | `src/components/StatusPill.vue` | Medium | Colored status badges |
| `EmptyState` | `src/components/EmptyState.vue` | Medium | Illustrated empty states |
| `ErrorState` | `src/components/ErrorState.vue` | Medium | Error display with retry |
| `UserAvatar` | `src/components/UserAvatar.vue` | Medium | Avatar with initials fallback |
| `CategoryTile` | `src/components/CategoryTile.vue` | Medium | Category grid tile |
| `SoftCard` | `src/components/SoftCard.vue` | Medium | Elevated card wrapper |
| `TrustBadge` | `src/components/TrustBadge.vue` | Low | Verified provider badge |
| `ReviewCard` | `src/components/ReviewCard.vue` | Medium | Standardized review display |
| `BookingStepIndicator` | `src/components/booking/BookingStepIndicator.vue` | High | Multi-step progress |
| `ContentContainer` | `src/components/layout/ContentContainer.vue` | Medium | Responsive max-width wrapper |

---

## 4. Page-by-Page Reconstruction Plan

### Phase 1 — Foundation & Navigation (Weeks 1-2)

| Task | Files Affected | Description |
|------|---------------|-------------|
| 1.1 Design tokens | `lib/theme/app_theme.dart` | Add missing tokens: success, warning, secondary, surface variants, standardized shadows |
| 1.2 ScreenHeader | `lib/components/screen_header.dart` | New component: consistent page title + back + action buttons |
| 1.3 SectionHeader | `lib/components/section_header.dart` | New component: title + subtitle + "See all" |
| 1.4 ContentContainer | `lib/components/content_container.dart` | New component: responsive max-width wrapper |
| 1.5 NavBar alignment | `lib/main.dart` | Match web 5-tab layout: Home, Explore, Bookings, Messages, Profile |
| 1.6 Explore tab | `lib/main/explore/` | New tab page combining map + search + categories |
| 1.7 Pull-to-refresh | All list pages | Standardize with `RefreshIndicator` (already used in messages) |

### Phase 2 — Core Components (Weeks 3-4)

| Task | Files Affected | Description |
|------|---------------|-------------|
| 2.1 ServiceCard | `lib/components/service_card.dart` | Unified card: image, title, rating, price, provider name |
| 2.2 BookingCard | `lib/components/booking_card.dart` | Booking card: status, date, service, provider, actions |
| 2.3 StarRating | `lib/components/star_rating.dart` | 1-5 star display + input mode |
| 2.4 StatusPill | `lib/components/status_pill.dart` | Colored status indicator (confirmed, active, completed, etc.) |
| 2.5 CategoryTile | `lib/components/category_tile.dart` | Icon + label grid tile |
| 2.6 SoftCard | `lib/components/soft_card.dart` | Elevated container with standardized shadow |
| 2.7 UserAvatar | `lib/components/user_avatar.dart` | Circle avatar with initials fallback |
| 2.8 EmptyState | `lib/components/empty_state.dart` | Empty state with illustration, message, CTA |
| 2.9 ErrorState | `lib/components/error_state.dart` | Error view with icon, message, retry button |

### Phase 3 — Home Page Redesign (Week 5)

| Task | Description |
|------|-------------|
| 3.1 Hero section | Search bar + quick category chips row (match web home) |
| 3.2 Service carousel | Horizontal scrolling service cards |
| 3.3 Category grid | 2xN grid of `CategoryTile` with icons |
| 3.4 Recommended section | Personalized recommendations row |
| 3.5 Trust badges | Provider verification badges on cards |
| 3.6 Notifications bell | Consistent badge with dynamic count (already partially done) |

### Phase 4 — Booking Funnel Redesign (Weeks 6-7)

| Task | Description |
|------|-------------|
| 4.1 BookingStepIndicator | Multi-step visual progress (service → schedule → payment → confirm) |
| 4.2 Service detail page | Full-screen: images, description, provider card, reviews, CTA |
| 4.3 Booking form | Date/time picker, address, notes — match web |
| 4.4 Payment screen | PayMongo integration (Stripe + Maya via PaymentController) |
| 4.5 Booking success | Confirmation with details + provider contact |
| 4.6 Booking detail | Full status view with timeline |

### Phase 5 — Chat & Messages Redesign (Week 8)

| Task | Description |
|------|-------------|
| 5.1 MessageThreadCard | Redesign card to match web: avatar, name, preview, time, badge |
| 5.2 Chat bubble design | Sent/received bubble styling (match web `chat.css`) |
| 5.3 Message status | Sent/delivered/read indicators (already partial) |
| 5.4 Image sharing | `ImageLightbox`-style full-screen viewer |
| 5.5 Call history tab | Redesign with call type icons, duration, status |
| 5.6 Voice messages | Record + playback support |

### Phase 6 — Profile & Settings Redesign (Week 9)

| Task | Description |
|------|-------------|
| 6.1 Profile header | Match web: cover gradient, avatar, name, stats |
| 6.2 Settings list | Grouped list with icons (matching `SettingsPage.vue`) |
| 6.3 Payment methods | Full CRUD UI matching `PaymentMethodsPage.vue` |
| 6.4 Address management | Consistent with `AddressesPage.vue` / `AddressFormPage.vue` |

### Phase 7 — Provider Dashboard (Week 10)

| Task | Description |
|------|-------------|
| 7.1 Provider mode toggle | Amber accent theme switch (matching web `body.provider-mode`) |
| 7.2 Dashboard cards | Earnings, bookings, reviews summary (matching `ProviderDashboardPage.vue`) |
| 7.3 Earnings chart | `EarningsChart` port using fl_chart |
| 7.4 Analytics | Booking metrics widget |

### Phase 8 — Advanced Features (Weeks 11-12)

| Task | Description |
|------|-------------|
| 8.1 Offline support | IndexedDB via `sqflite` + connectivity-aware caching |
| 8.2 Push notifications | Firebase Cloud Messaging integration |
| 8.3 KYC flow | ID scanning + liveness detection |
| 8.4 Voice/video calls | WebRTC integration |
| 8.5 AI booking | Gemini API integration via `AiBookingComposer` pattern |

---

## 5. State Management Alignment

| Web Store | Flutter Equivalent | Action |
|-----------|--------------------|--------|
| `auth.ts` | Supabase auth (current) | Migrate to dedicated `AuthService` |
| `chat.ts` | `ChatService` + `ChatPageModel` | Consolidate into `ChatService` + FFAppState sync |
| `services.ts` | `BookingsService` + `ServiceListingTable` | Already split across backend + services |
| `favorites.ts` | Inline in `HomeModel.favorites` | Create `FavoritesService` |
| `notifications.ts` | `FFAppState().notificationCount` | Expand to full notification model |
| `kyc.ts` | Basic KYC page | Full store for multi-step KYC |
| `recommendations.ts` | None | New store + AI service |

---

## 6. Quick Wins (Already Partially Done)

These items have been started in the current session and need completion:

| Item | Status | Remaining Work |
|------|--------|----------------|
| **PaymentController** | ✅ Created (`lib/services/payment_controller.dart`) | Wire into booking payment screen |
| **Messages filter icon** | ✅ Added to header | Verify navigation to notifications |
| **Dynamic notification badge** | ✅ FFAppState fields + home_widget + main.dart NavBar | Wire real data (notifications table) |
| **Chat unread sync** | ✅ messages_model syncs to FFAppState | Real-time updates when chat loads |

---

## 7. Design System Migration: AppTheme Alignment

### Missing Color Tokens to Add

```dart
// In lib/theme/app_theme.dart — AppThemeData class
final Color success;        // #10B981
final Color warning;        // #F59E0B
final Color primaryLight;   // #17B890
final Color primaryDark;    // #0B6B54
final Color surfaceAlt;     // #F8FAFC (card alternate background)
final Color border;         // #E2E8F0 (card borders)
final Color textTertiary;   // #94A3B8 (placeholder text)
```

### Standardized BoxShadows

```dart
static const List<BoxShadow> cardShadow = [
  BoxShadow(
    color: Color(0x12000000),
    blurRadius: 18,
    offset: Offset(0, 10),
  ),
];
static const List<BoxShadow> softShadow = [
  BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  ),
];
```

---

## 8. File Structure Migration Plan

### New Directory Layout

```
lib/
├── components/           # Shared components (new)
│   ├── screen_header.dart
│   ├── section_header.dart
│   ├── service_card.dart
│   ├── booking_card.dart
│   ├── star_rating.dart
│   ├── status_pill.dart
│   ├── category_tile.dart
│   ├── soft_card.dart
│   ├── user_avatar.dart
│   ├── empty_state.dart
│   ├── error_state.dart
│   ├── content_container.dart
│   └── booking_step_indicator.dart
├── theme/
│   └── app_theme.dart    # Expanded with new tokens
├── services/
│   ├── payment_controller.dart  ✅
│   ├── chat_service.dart
│   ├── bookings_service.dart
│   ├── favorites_service.dart   # New
│   └── notifications_service.dart # New
├── stores/               # New — Pinia-like service stores
│   ├── auth_store.dart
│   └── notification_store.dart
├── app_state.dart        # Keep + expand
├── main/
│   ├── home/
│   ├── explore/          # New tab
│   ├── bookings/
│   ├── messages/
│   └── profile/
└── pages/
    ├── booking_funnel/
    ├── chat_page/
    ├── my_notifications/
    └── settings/
```

---

## 9. Migration Strategy

### Approach: Incremental Replacement

Rather than a full rewrite, progressively replace and align:

1. **Build shared components first** — extract from existing inline code or create new
2. **Redesign one page at a time** — start with Home → Bookings → Messages → Profile
3. **Keep existing routes working** — each page replacement is a drop-in with same route name
4. **Phase out FlutterFlow patterns** — replace FFAppState with dedicated stores, FlutterFlow models with BLoC/Cubit

### Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Breaking existing pages | Keep old pages until new ones are verified |
| Design drift | Use web CSS custom properties as single source of truth |
| Performance | Profile after each phase; lazy-load heavy pages |
| Developer adoption | Document patterns in `/docs/patterns.md` |

---

## 10. Success Criteria

- [ ] All pages use consistent `ScreenHeader`, `SoftCard`, `SectionHeader`
- [ ] `StarRating`, `StatusPill`, `UserAvatar` used everywhere instead of inline widgets
- [ ] Home page matches web layout: hero + categories + recommendations
- [ ] Booking funnel uses `BookingStepIndicator`
- [ ] Chat matches web design: bubbles, status, avatars
- [ ] Payment integration works end-to-end (Stripe + Maya)
- [ ] All shared components have null-safe, typed APIs
- [ ] Dark mode works consistently (matching web `variables.css` dark overrides)
- [ ] Provider mode amber accent works
- [ ] Zero lint errors; zero unused imports
