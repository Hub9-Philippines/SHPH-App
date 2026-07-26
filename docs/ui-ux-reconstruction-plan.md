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

## 4. Phase Implementation Log

### ✅ Phase 1 — Foundation & Navigation (Complete)

| Task | Files Affected | Status |
|------|---------------|--------|
| 1.1 Design tokens | `lib/theme/app_theme.dart` | ✅ Added: 8 new color tokens (`surfaceAlt`, `border`, `textTertiary`, `primaryLight`, `primaryDark`, `primaryBrandText`, `iconBackground`), shadows (`shadowSoft`, `shadowCard`, `shadowElevated`), radii, container widths, `statusColors()` helper |
| 1.2 ScreenHeader | `lib/components/screen_header.dart` | ✅ Created: title, subtitle, action, custom padding |
| 1.3 SectionHeader | `lib/components/section_header.dart` | ✅ Created: title, subtitle, optional "See all" link |
| 1.4 ContentContainer | `lib/components/content_container.dart` | ✅ Created: responsive max-width wrapper with narrow/readable/wide variants |
| 1.5 NavBar alignment | `lib/main.dart` | ✅ 5-tab layout, tab icons made outlined for consistency, "Category" renamed to "Explore" |
| 1.6 Explore tab | `lib/main/explore/` | ✅ New tab with `ExploreWidget` + `ExploreModel` |
| 1.7 Pull-to-refresh | `RefreshablePage` mixin | ✅ Applied to Explore + Bookings pages |
| 1.8 CategoryPill | `lib/components/category_pill.dart` | ✅ Created: chip component with icon + label |
| 1.9 Home header | `lib/main/home/home_widget.dart` | ✅ Aurora gradient redesign |

### ✅ Phase 2 — Provider Experience & Profile Hub (Complete)

| Task | Files Affected | Status |
|------|---------------|--------|
| 2.1 Role-aware bottom nav | `lib/main.dart` | ✅ Client ↔ provider tab swap via `FFAppState().isProvider` |
| 2.2 Profile page redesign | `lib/pages/profile/` | ✅ Teal hero gradient (`#0D6D78` → `#63CBD6`), ScreenHeader, ContentContainer, dark mode tokens |
| 2.3 Status pill colors | `AppThemeData.statusColors()` | ✅ Unified helper applied to `bookings_widget.dart` and `booking_details_widget.dart` |
| 2.4 Provider dashboard | `lib/main/pro_dashboard/` | ✅ Scaffold backgrounds fixed to theme tokens |

### ✅ Phase 3 — Messages, Settings & Dark Mode Audit (Complete)

| Task | Files Affected | Status |
|------|---------------|--------|
| 3.1 Messages page | `lib/main/messages/messages_widget.dart` | ✅ ScreenHeader, theme tokens, `AppThemeData.status*`, removed dead `_buildHeader()` |
| 3.2 Settings page | `lib/pages/settings/settings_widget.dart` | ✅ ScreenHeader, `primaryBackground`/`border`/`surfaceAlt`, `primaryText`/`secondaryText`/`textTertiary`, removed BackButtonWidget import |
| 3.3 Addresses page | `lib/pages/addresses/addresses_widget.dart` | ✅ ScreenHeader, tokenized containers/cards/text, `border`/`shadowCard`/`surfaceAlt` |
| 3.4 Payment methods page | `lib/main/payment_methods/payment_methods_widget.dart` | ✅ ScreenHeader, tokenized containers/sheets/text |
| 3.5 Notifications page | `lib/pages/my_notifications/my_notifications_widget.dart` | ✅ ScreenHeader, tokenized cards/text |
| 3.6 Search page | `lib/pages/search_page/search_page_widget.dart` | ✅ ScreenHeader with filter toggle, themed search bar/category chips/text |
| 3.7 Dark mode sweep | See sub-items | ✅ |
| &nbsp;&nbsp;3.7a My Reviews | `lib/pages/my_reviews/my_reviews_widget.dart` | ✅ 12 token replacements |
| &nbsp;&nbsp;3.7b Favorites | `lib/pages/favorites_page/favorites_widget.dart` | ✅ 10 token replacements |
| &nbsp;&nbsp;3.7c Chat page | `lib/pages/chat_page/chat_page_widget.dart` | ✅ 14 token replacements (bubbles, composer, header) |
| &nbsp;&nbsp;3.7d Security settings | `lib/pages/security_settings/security_settings_widget.dart` | ✅ 17 token replacements (dialog, session cards, fields) |
| &nbsp;&nbsp;3.7e Help, Create/Edit profile | Already fully themed | ✅ No changes needed |
| 3.8 ScreenHeader color cleanup | `lib/components/screen_header.dart` | ✅ `Colors.white` → `primaryBackground`, `Color(0xFF0F172A)` → `primaryText`, `Color(0xFF64748B)` → `secondaryText` |

### ✅ Phase 4 — Booking & Payment Flow (Complete)

| Task | Files Affected | Status |
|------|---------------|--------|
| 4.1 booking_flow_screen | `booking_flow_screen.dart` | ✅ Fixed BoxShadow → `AppThemeData.shadowCard` |
| 4.2 express_checkout_screen | `express_checkout_screen.dart` | ✅ Fixed hex icon color → `textTertiary` |
| 4.3 booking_success_screen | `booking_success_screen.dart` | ✅ Fixed 2x BoxShadow → `shadowCard` + `shadowElevated` |
| 4.4 checkout_screen | `checkout/checkout_screen.dart` | ✅ `Colors.white` on buttons kept (accessibility) |
| 4.5 booking_setup_screen | `setup/booking_setup_screen.dart` | ✅ `Colors.white` on buttons kept (accessibility) |
| 4.6 Widget files | 6 widget files | ✅ Verified: top shadows intentional (negative offset), button text intentional |
| 4.7 status_page theming | `status_page.dart` | ✅ Polyline → `primary`, default status badge → `secondaryText`, BoxShadow → `shadowCard`, en-route badge → `primary` |
| 4.8 live_matching theming | `live_matching_screen.dart` (2508 lines) | ✅ Route polyline → `primary`, 2x BoxShadow → `shadowCard` |
| 4.9 express_shimmer | `widgets/express_shimmer.dart` | ✅ Added app_theme import, Container bg → `primaryBackground` |
| 4.10 Old booking pages | 4 files (booking, booking_payment, booking_success, booking_details) | ✅ Scaffold bg → `secondaryBackground`, container bg → `primaryBackground`, text → `primaryText`/`secondaryText`/`textTertiary`, borders → `border`, surfaces → `surfaceAlt`, shadows → `shadowCard` |

### 📋 Proposed Future Phases

#### Phase 5 — Authentication & Onboarding

| Task | Files | Description |
|------|-------|-------------|
| 5.1 Splash screen | `pages/splash/splash_widget.dart` | Theme tokens, dark mode |
| 5.2 Onboarding | `pages/onboarding/onboarding_widget.dart` | Theme tokens, ScreenHeader |
| 5.3 Sign options | `pages/sign_options/sign_options_widget.dart` | Entry point theming |
| 5.4 Sign in | `pages/signin/signin_widget.dart` | Full redesign matching web |
| 5.5 Sign up | `pages/signup/signup_widget.dart` | Full redesign matching web |
| 5.6 Forgot/Set password | `pages/forgot_password/`, `pages/set_password/` | Theme tokens |
| 5.7 Phone verification | `pages/phone_verify_user/` | OTP screen theming |
| Total: **14 files** | | |

#### Phase 6 — Home Page Redesign

| Task | Description |
|------|-------------|
| 6.1 Hero section | Search bar + quick category chips row (match web home) |
| 6.2 Service carousel | Horizontal scrolling service cards |
| 6.3 Category grid | 2xN grid of `CategoryTile` with icons |
| 6.4 Recommended section | Personalized recommendations row |
| 6.5 Notifications bell | Consistent badge with dynamic count |

#### Phase 7 — Provider Verification & KYC

| Task | Files | Description |
|------|-------|-------------|
| 7.1 E-KYC begin | `pages/e_k_y_c_begin/` | KYC intro page |
| 7.2 ID verification | `pages/i_d_verify/` | ID upload + verification |
| 7.3 Document scan | `pages/pro_verification/document_scan_widget.dart` | Document scanning UI |
| 7.4 Face verification | `pages/pro_verification/face_verification_screen.dart` | Liveness detection |
| 7.5 Verification status | `pages/pro_verification/` (unverified + reviewing) | Status pages |
| Total: **11 files** | | |

#### Phase 8 — Provider Dashboard Sub-pages & TM Flow

| Task | Files | Description |
|------|-------|-------------|
| 8.1 Create service | `main/pro_dashboard/create_service_widget.dart` | Provider service listing form |
| 8.2 Service history | `main/pro_dashboard/service_history_widget.dart` | Provider booking history |
| 8.3 Reviews & ratings | `main/pro_dashboard/reviews_ratings_widget.dart` | Provider review management |
| 8.4 TM Flow (11 files) | `pages/tm_flow/` | Full task manager: sub-category, estimate, invoice, payment, rating, broadcast, active job |
| Total: **~15 files** | | |

#### Phase 9 — Advanced Features

| Task | Description |
|------|-------------|
| 9.1 Offline support | IndexedDB via `sqflite` + connectivity-aware caching |
| 9.2 Push notifications | Firebase Cloud Messaging integration |
| 9.3 Voice/video calls | WebRTC integration |
| 9.4 AI booking | Gemini API integration |

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

### Color Tokens — Implemented ✅

```dart
// In lib/theme/app_theme.dart — AppThemeData class (all implemented)
final Color primary;          // #368EFF (blue)
final Color secondary;        // #39D2C0 (teal)
final Color tertiary;         // #EE8B60 (orange)
final Color alternate;        // #E0E3E7
final Color primaryText;      // #14181B
final Color secondaryText;    // #57636C
final Color primaryBackground; // #FFFFFF
final Color secondaryBackground; // #F7F7F7
final Color accent1-4;        // Various
final Color success;          // #249689
final Color warning;          // #F9CF58
final Color error;            // #FF5963
final Color info;             // #FFFFFF
final Color iconBackground;   // #E6F0FF
final Color primaryLight;     // #D4F0EF
final Color primaryDark;      // #49B8C4
final Color primaryBrandText; // #0D6D78
final Color surfaceAlt;       // #F1F5F9 (card alternate background)
final Color border;           // #E2E8F0 (card borders)
final Color textTertiary;     // #94A3B8 (placeholder text)
```

### Standardized BoxShadows — Implemented ✅

```dart
static const List<BoxShadow> shadowSoft = [
  BoxShadow(color: Color(0x0F10264A), blurRadius: 6, offset: Offset(0, 1)),
];
static const List<BoxShadow> shadowCard = [
  BoxShadow(color: Color(0x140F1828), blurRadius: 24, offset: Offset(0, 8)),
];
static const List<BoxShadow> shadowElevated = [
  BoxShadow(color: Color(0x2E11264A), blurRadius: 26, offset: Offset(0, 10)),
];
```

### Status Pill Colors — Implemented ✅

```dart
static (Color text, Color bg) statusColors(String status) => switch (status) {
  'confirmed' => (Color(0xFF0D6D78), Color(0xFFD4F0EF)),
  'in_progress' => (Color(0xFF166534), Color(0xFFE7F6EC)),
  'completed' => (Color(0xFF475569), Color(0xFFEEF1F5)),
  'cancelled' => (Color(0xFFB91C1C), Color(0xFFFDE9E9)),
  'pending' => (Color(0xFF92400E), Color(0xFFFDF0DD)),
};
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

## 10. Success Criteria — Progress

- [x] Design tokens implemented: `AppThemeData` with 20+ color tokens, 3 shadow levels, radius/container constants
- [x] `ScreenHeader`, `SectionHeader`, `ContentContainer`, `CategoryPill` created and used across pages
- [x] Dark mode works consistently via `AppThemeData.dark()` + Flutter theme brightness
- [x] Status pill colors via `AppThemeData.statusColors()` helper
- [x] Role-aware bottom nav (client ↔ provider)
- [x] Profile page with teal hero gradient + theme tokens
- [x] Provider dashboard scaffold backgrounds tokenized
- [x] Messages page tokenized (ScreenHeader, status pills, theme tokens)
- [x] Settings, Addresses, Payment Methods, Notifications, Search — all tokenized
- [x] Favorites, Reviews, Chat, Security Settings — dark mode sweeps complete
- [ ] All pages use `ScreenHeader` consistently (remaining: auth, booking funnel parts, old booking pages)
- [ ] `StarRating`, `StatusPill`, `UserAvatar` extracted as reusable components
- [ ] ServiceCard, BookingCard extracted as shared components
- [ ] Home page matches web layout: hero + categories + recommendations
- [ ] Booking funnel uses `BookingStepIndicator`
- [ ] Chat matches web design fully: bubbles, status, avatars
- [ ] Payment integration works end-to-end (Stripe + Maya)
- [ ] Zero lint errors; zero unused imports
