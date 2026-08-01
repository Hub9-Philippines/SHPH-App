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
| **Pages** | ~55+ widget pages | ~100+ page views |
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
| `--shph-primary` | `#63CBD6` (teal) | `AppTheme.of(context).primary` = `#368EFF` (blue) | ❌ Brand mismatch |
| `--shph-primary-dark` | `#49B8C4` | `AppTheme.of(context).primaryDark` = `#49B8C4` | ✅ Matches |
| `--shph-primary-light` | `#D4F0EF` | `AppTheme.of(context).primaryLight` = `#D4F0EF` | ✅ Matches |
| `--shph-primary-text` | `#0D6D78` | `AppTheme.of(context).primaryBrandText` = `#0D6D78` | ✅ Matches |
| `--shph-primary-deep` | `#0D6D78` | `primaryBrandText` = `#0D6D78` | ✅ Matches |
| `--shph-on-primary` | `#0F172A` | `AppTheme.of(context).onPrimary` = `#FFFFFF` | ❌ Mismatch |
| `--shph-secondary` | `#39D2C0` | `AppTheme.of(context).secondary` = `#39D2C0` | ✅ Matches |
| `--shph-tertiary` | `#EE8B60` | `AppTheme.of(context).tertiary` = `#EE8B60` | ✅ Matches |
| `--shph-bg-primary` | `#FFFFFF` | `Colors.white` / `secondaryBackground` | ✅ |
| `--shph-bg-secondary` | `#F1F5F9` | `AppTheme.of(context).surfaceAlt` = `#F1F5F9` | ✅ Matches |
| `--shph-bg-page` | `#F8FAFC` | — | ❌ Missing (uses `primaryBackground` = white) |
| `--shph-text-primary` | `#0F172A` | `AppTheme.of(context).primaryText` = `#14181B` | ❌ Slight diff |
| `--shph-text-secondary` | `#64748B` | `AppTheme.of(context).secondaryText` = `#57636C` | ❌ Slight diff |
| `--shph-text-hint` | `#94A3B8` | `AppTheme.of(context).textTertiary` = `#94A3B8` | ✅ Matches |
| `--shph-text-heading` | `#0F172A` | `primaryText` = `#14181B` | ❌ Slight diff |
| `--shph-error` | `#DC2626` | `AppTheme.of(context).error` = `#FF5963` | ❌ Value diff |
| `--shph-success` | `#249689` | `AppTheme.of(context).success` = `#249689` | ✅ Matches |
| `--shph-warning` | `#F9CF58` | `AppTheme.of(context).warning` = `#F9CF58` | ✅ Matches |
| `--shph-info` | `#63CBD6` | `AppTheme.of(context).info` = `#368EFF` | ❌ Mismatch |
| `--shph-radius-sm` | `10px` | `AppThemeData.radiusSm` = `8.0` | ❌ Slight diff |
| `--shph-radius-md` | `14px` | `AppThemeData.radiusMd` = `16.0` | ❌ Slight diff |
| `--shph-radius-lg` | `16px` | — | ❌ Missing |
| `--shph-radius-card` | `24px` | `AppThemeData.radiusCard` = `24.0` | ✅ Matches |
| `--shph-radius-hero` | `24px` | — | ❌ Missing (same as radiusCard) |
| `--shph-shadow-sm` | `0 1px 6px rgba(16,38,74,0.06)` | `shadowSoft` ≈ `0 1px 6px rgba(16,38,74,0.06)` | ✅ Close match |
| `--shph-shadow-md` | `0 3px 16px rgba(17,38,74,0.07)` | — | ❌ Missing |
| `--shph-shadow-lg` | `0 10px 26px -8px rgba(17,38,74,0.18)` | — | ❌ Missing |
| `--shph-shadow-card` | `0 8px 24px rgba(16,24,40,0.08)` | `shadowCard` ≈ `0 8px 24px rgba(16,24,40,0.08)` | ✅ Close match |
| `--shph-border` | `#E2E8F0` | `AppTheme.of(context).border` = `#E2E8F0` | ✅ Matches |
| `--shph-star` | `#FFC107` | — | ❌ Missing |
| `--shph-gradient-hero` | `linear-gradient(125deg, #0D6D78, #63CBD6)` | Used in profile page | ✅ Implemented |

### 2.2 Typography

**Web:** "Plus Jakarta Sans" via Google Fonts
**Flutter:** ✅ Now uses `GoogleFonts.plusJakartaSans()` throughout (Phase 12)

### 2.3 Spacing Scale

The web app uses a utility-based spacing scale in `utilities.css`. The Flutter app uses ad-hoc `SizedBox` values.
Standardize on a 4px base unit scale: 4, 8, 12, 16, 20, 24, 32, 40, 48, 56, 64.

---

## 3. Component Library Gap Analysis

### 3.1 Shared Components (Flutter) — Status

| Component | Flutter | Web (Vue) | Status |
|-----------|---------|-----------|--------|
| `ScreenHeader` | ✅ `lib/components/screen_header.dart` | `ScreenHeader.vue` | ✅ Done |
| `SectionHeader` | ✅ `lib/components/section_header.dart` | `SectionHeader.vue` | ✅ Done |
| `ServiceCard` | ✅ `lib/components/service_card.dart` | `ServiceCard.vue` | ✅ Done |
| `BookingCard` | ✅ `lib/components/booking_card.dart` | `BookingCard.vue` | ✅ Done |
| `StarRating` | ✅ `lib/components/star_rating.dart` | `StarRating.vue` | ✅ Done |
| `StatusPill` | ✅ `lib/components/status_pill.dart` | `StatusPill.vue` | ✅ Done |
| `EmptyState` | ✅ `lib/components/empty_state_widget.dart` | `EmptyState.vue` | ✅ Done |
| `ErrorState` | ✅ `lib/components/error_state_widget.dart` | `ErrorState.vue` | ✅ Done |
| `UserAvatar` | ✅ `lib/components/user_avatar.dart` | `UserAvatar.vue` | ✅ Done |
| `CategoryTile` | ✅ `lib/components/categoriesgrid/` | `CategoryTile.vue` | ✅ Done |
| `SoftCard` | ✅ `lib/components/soft_card.dart` | `SoftCard.vue` | ✅ Done |
| `ReviewCard` | ✅ `lib/components/review_card.dart` | `ReviewCard.vue` | ✅ Done |
| `BottomSheet` | ✅ Standardized `showModalBottomSheet` | `ion-modal` | ✅ Done |
| `Skeleton` | ✅ `SkeletonLoadingWidget` | `ion-skeleton-text` | ✅ Already had |
| `SearchField` | ✅ `SearchableSelect` component | `SearchableSelect.vue` | ✅ Done |

### 3.2 New Components Created (ported from Web) — All Done ✅

| Component | File | Status |
|-----------|------|--------|
| `ScreenHeader` | `lib/components/screen_header.dart` | ✅ Phase 1 |
| `SectionHeader` | `lib/components/section_header.dart` | ✅ Phase 1 |
| `ContentContainer` | `lib/components/content_container.dart` | ✅ Phase 1 |
| `CategoryPill` | `lib/components/category_pill.dart` | ✅ Phase 1 |
| `ServiceCard` | `lib/components/service_card.dart` | ✅ Phase 4 |
| `BookingCard` | `lib/components/booking_card.dart` | ✅ Phase 4 |
| `BookingStepIndicator` | `lib/components/booking_step_indicator.dart` | ✅ Phase 4 |
| `StarRating` | `lib/components/star_rating.dart` | ✅ Phase 5 |
| `StatusPill` | `lib/components/status_pill.dart` | ✅ Phase 5 |
| `EmptyState` | `lib/components/empty_state_widget.dart` | ✅ Phase 5 |
| `ErrorState` | `lib/components/error_state_widget.dart` | ✅ Phase 5 |
| `UserAvatar` | `lib/components/user_avatar.dart` | ✅ Phase 5 |
| `CategoryTile` | `lib/components/categoriesgrid/` | ✅ Phase 6 |
| `SoftCard` | `lib/components/soft_card.dart` | ✅ Phase 6 |
| `TrustBadge` | `lib/components/trust_badge.dart` | ✅ Phase 8 |
| `ReviewCard` | `lib/components/review_card.dart` | ✅ Phase 8 |
| Phase 12 components | 10 new files in `lib/components/` | ✅ See Section 13 |

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

### ✅ Phase 5 — Authentication & Onboarding (Complete)

| Task | Files | Status |
|------|-------|--------|
| 5.1 Splash screen | `pages/splash/splash_widget.dart` | ✅ Branding text ("SerbisyoHub PH" + tagline) added, GoogleFonts import, white text on primary bg |
| 5.2 Onboarding | `pages/onboarding/onboarding_widget.dart` | ✅ `Color(0x1E368EFF)` → `primary.withValues(alpha: 0.12)`, `Color(0xFF7C7C7C)` → `alternate`, `dotColor(0x13368EFF)` → `primary.withValues(alpha: 0.08)`, `Colors.white` → `primaryText`, elevation 0→2 |
| 5.3 Sign options | `pages/sign_options/sign_options_widget.dart` | ✅ Empty AppBar removed, top padding adjusted |
| 5.4 Sign in | `pages/signin/signin_widget.dart` | ✅ `Color(0xFF889096)` → `secondaryText` |
| 5.5 Sign up | `pages/signup/signup_widget.dart` | ✅ `Color(0xFF889096)` → `secondaryText` |
| 5.6 Forgot/Set password | `pages/forgot_password/`, `pages/set_password/` | ✅ `Colors.white` kept (no `onPrimary` token available) |
| 5.7 Phone verification | `pages/phone_verify_user/` | ⏭️ Skipped — already using theme tokens |
| Total: **7 files** | | |

#### Phase 6 — Home Page Redesign ⚠️ Reverted

| Task | Files Affected | Status |
|------|---------------|--------|
| 6.1–6.8 Home page redesign | `home_widget.dart` | ⚠️ **REVERTED** — restored to pre-Phase 6 design from commit `8d34b3d`. Retained `GoogleFonts.plusJakartaSans` (replacing `GoogleFonts.poppins`) and `shadowLg` (replacing `shadowElevated`). The web-matching hero/map/grid/carousel layout was replaced with the original FlutterFlow-generated home page. |
| Total: **1 file** (`home_widget.dart`) | | |

#### ✅ Phase 7 — Provider Verification & KYC (Complete)

| Task | Files Affected | Status |
|------|---------------|--------|
| 7.1 Model cleanup (4 files) | `e_k_y_c_begin_model.dart`, `i_d_verify_model.dart`, `document_scan_model.dart`, `pro_unverified_landing_model.dart` | ✅ Removed `BackButtonModel` imports + `backButtonModel` fields |
| 7.2 Pro unverified landing | `pro_unverified_landing_widget.dart` | ✅ ScreenHeader, AppTheme tokens, Column layout |
| 7.3 E-KYC begin | `e_k_y_c_begin_widget.dart` | ✅ ScreenHeader, AppTheme tokens, content card theming |
| 7.4 ID verify | `i_d_verify_widget.dart` | ✅ ScreenHeader, AppTheme tokens, themed instruction cards + camera button |
| 7.5 Document scan | `document_scan_widget.dart` | ✅ ScreenHeader, AppTheme tokens, themed snackbars/dialogs with error/success colors |
| 7.6 Face verification | `face_verification_screen.dart` | ✅ 26+ hardcoded `Color(0x…)`, `Colors.grey`, `Colors.green`, `Colors.red`, `Colors.black87`, `Colors.white70` → AppTheme tokens; `AppBar` → `ScreenHeader`; `TextStyle` → `GoogleFonts.poppins`; liveness overlay preserved |
| 7.7 Verification reviewing | `verification_reviewing_widget.dart` | ✅ ScreenHeader, AppTheme tokens, `Colors.white` → `secondaryBackground` |
| Total: **11 files** | | |

#### ✅ Phase 8 — Provider Dashboard Sub-pages & TM Flow (Complete)

| Task | Files Affected | Status |
|------|---------------|--------|
| 8.1 Create Service | `create_service_widget.dart` | ✅ ScreenHeader, `AppBar` removed, `Colors.white` → `secondaryBackground`, `Colors.red` → `error` |
| 8.2 Service History | `service_history_widget.dart` | ✅ ScreenHeader, `BackButtonWidget` removed, `Color(0xFFF4F7FB)` → `primaryBackground`, `Color(0xFF14213D)` → `primaryText`, `Color(0xFF64748B)` → `secondaryText`, `Color(0xFF94A3B8)` → `textTertiary`, `Colors.white` → `secondaryBackground`, `Color(0x12000000)` shadows → `AppThemeData.shadowCard` |
| 8.3 Reviews & Ratings | `reviews_ratings_widget.dart` | ✅ Same pattern as 8.2 + `Color(0xFF9A6700)` → `warning`, `Color(0xFFEFF3F7)` → `border` |
| 8.4a TM Sub-category | `tm_sub_category_screen.dart` | ✅ ScreenHeader, `surfaceTintColor` removed, `Color(0xFFF6FBFF)` → `surfaceAlt` |
| 8.4b TM Estimate | `tm_estimate_screen.dart` | ✅ ScreenHeader, `Color(0xFFF6FBFF)` → `surfaceAlt`, `Colors.white` → `secondaryBackground` |
| 8.4c TM Invoice | `tm_invoice_screen.dart` | ✅ ScreenHeader, `Colors.white` → `secondaryBackground` |
| 8.4d TM Payment | `tm_payment_screen.dart` | ✅ ScreenHeader, `Color(0xFFF5F7FA)` → `primaryBackground`, `Colors.white` → `secondaryBackground`, `Color(0xFFE4E8EE)` → `border` |
| 8.4e TM Rating | `tm_rating_screen.dart` | ✅ ScreenHeader (replaced plain Text title), `Colors.white` → `secondaryBackground` |
| 8.4f TM Broadcast | `tm_broadcast_screen.dart` | ✅ `Colors.black` shadow → `AppThemeData.shadowCard`, `Color(0xFFF6FBFF)` → `surfaceAlt`, `Colors.white` → `secondaryBackground` (keeps custom top card layout — not an AppBar) |
| 8.4g TM Active Job | `tm_active_job_screen.dart` | ✅ `surfaceTintColor` removed, `Color(0xFFF6FBFF)` → `surfaceAlt`, `Colors.white` → `secondaryBackground`, `Colors.black` shadow → `AppThemeData.shadowCard` (keeps AppBar + TabBar — TabBar is integral to layout) |
| Non-widget files | `tm_repository.dart`, `tm_models.dart`, `tm_controller.dart`, `tm_catalog.dart` | Skipped — pure data/logic, no UI code |
| Total: **10 widget files** | | |

#### ✅ Phase 9 — Advanced Features (Complete)

| Task | Files Created/Modified | Status |
|------|----------------------|--------|
| 9.1 Offline support | `services/offline_service.dart` | ✅ `sqflite`-backed cache DB with TTL, `pending_mutations` queue for offline writes, key-value cache with expiry |
| 9.2 Push notifications | `services/push_notification_service.dart` | ✅ FCM token registration to `user_push_tokens` table, Supabase Edge Function integration (`send-notification`), notification tap routing scaffold |
| 9.3 Voice/video calls | `services/call_service.dart` | ✅ Call state machine (idle/calling/ringing/connected/ended/failed), `Stream<CallState>` for UI binding, LiveKit-capable scaffold |
| 9.4 AI booking | `services/ai_service.dart`, `pages/help/chatbot_page.dart` (rewrite), `main/home/home_widget.dart` (integrate) | ✅ `AIService` wrapping OpenRouter (`deepseek/deepseek-v4-flash-free`) with structured recommendation engine (`getRecommendations()` returns ranked `ServiceListing` list), booking-aware system prompt, chatbot page uses `AIService` + `ScreenHeader`, home page shows "Recommended for You" carousel when API key is configured |
| Dependencies added | `pubspec.yaml` | ✅ `firebase_messaging`, `flutter_local_notifications`, `connectivity_plus`, `livekit_client` |

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
// In lib/theme/app_theme.dart — AppThemeData class (current state)
final Color primary;          // #368EFF (blue) — reverted from teal (#63CBD6)
final Color onPrimary;        // #FFFFFF — reverted from #0F172A
final Color bgPage;           // #F8FAFC — added
final Color secondary;        // #39D2C0 (teal)
final Color tertiary;         // #EE8B60 (orange)
final Color alternate;        // #E0E3E7
final Color primaryText;      // #0F172A — aligned from #14181B
final Color secondaryText;    // #64748B — aligned from #57636C
final Color primaryBackground; // #FFFFFF
final Color secondaryBackground; // #F7F7F7
final Color accent1-4;        // Various
final Color success;          // #249689
final Color warning;          // #F9CF58
final Color error;            // #DC2626 — aligned from #FF5963
final Color info;             // #368EFF — reverted from #63CBD6
final Color star;             // #FFC107 — added
final Color iconBackground;   // #E6F0FF
final Color primaryLight;     // #D4F0EF
final Color primaryDark;      // #49B8C4
final Color primaryBrandText; // #0D6D78
final Color surfaceAlt;       // #F1F5F9
final Color border;           // #E2E8F0
final Color textTertiary;     // #94A3B8
```

### Standardized BoxShadows — Implemented ✅

```dart
static const List<BoxShadow> shadowSoft = [
  BoxShadow(color: Color(0x0F10264A), blurRadius: 6, offset: Offset(0, 1)),
];
static const List<BoxShadow> shadowCard = [
  BoxShadow(color: Color(0x140F1828), blurRadius: 24, offset: Offset(0, 8)),
];
static const List<BoxShadow> shadowLg = [
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

## 8. Phase 10 — Feature Parity & Component Extraction ✅

**Goal:** Close remaining feature gaps with the web reference app (`shph-web`).

### New Files Created

| File | Purpose |
|------|---------|
| `lib/components/star_rating.dart` | Reusable 5-star rating with half-star support |
| `lib/components/status_pill.dart` | Booking status pill using `AppThemeData.statusColors()` |
| `lib/components/user_avatar.dart` | Avatar with image + initials fallback |
| `lib/components/service_card.dart` | Service listing card (image, rating, price) |
| `lib/components/booking_card.dart` | Booking card (avatar, status pill, date) |
| `lib/components/booking_step_indicator.dart` | Stepped funnel indicator for booking flow |
| `lib/components/empty_state.dart` | Centered empty state with icon + CTA |
| `lib/components/error_state.dart` | Error display with retry button |
| `lib/components/soft_card.dart` | Subtle surface-colored card wrapper |
| `lib/components/provider_status_toggle.dart` | Online/offline toggle (compact + full) |
| `lib/components/availability_calendar.dart` | Monthly calendar for provider availability |
| `lib/components/earnings_chart.dart` | Bar chart for provider earnings |
| `lib/components/rich_chat_bar.dart` | Chat input with mic/image/sticker buttons |
| `lib/components/image_lightbox.dart` | Pinch-to-zoom image viewer |
| `lib/pages/wallet/` | Wallet page with balance, transactions, top-up |
| `lib/pages/on_demand_booking/` | On-demand booking with urgency + time slots |
| `lib/services/ai_composer_service.dart` | OpenRouter-powered booking from text/image |

### Lint Cleanup
- Removed remaining `surfaceTintColor: Colors.transparent` in `pro_dashboard_widget.dart` and `product_page_widget.dart`
- Replaced `Color(0xFFF4F7FB)` → `AppTheme.of(context).primaryBackground`

### Backend Connectivity (SHPH API — no Supabase)

| Service / Page | New Files | Backend |
|----------------|-----------|---------|
| **WalletService** (rewrite) | `lib/services/wallet_service.dart` | `ShphBookingsApi` (`listUserBookings` + `listBookings`) → real wallet balance, earnings, spent, transactions |
| **AIBookingComposerService** (fix stub) | `lib/services/ai_composer_service.dart` | Replaced `_callOpenRouter()` stub with real `AIService.chat()` → OpenRouter API |
| **AI Booking Composer page** | `lib/pages/ai_booking_composer/` (model + widget) | Free-text prompt → AI extracts structured booking details |
| **ChatDetailService** | `lib/services/chat_detail_service.dart` | `ShphChatApi` (messages, send, markRead) — pure API, no Supabase |
| **Chat Detail page** | `lib/pages/chat_detail/` (model + widget) | Real-time chat with polling, message bubbles, send bar |
| **EarningsService** | `lib/services/earnings_service.dart` | `ShphBookingsApi.listBookings()` → earnings summary, chart data, transactions |
| **Earnings Chart page** | `lib/pages/earnings_chart/` (model + widget) | Summary card, period stats, weekly bar chart, transaction list |
| **AvailabilityApi** (new resource) | `lib/api/resources/availability_api.dart` | `GET/POST/DELETE /api/services/availability/slots/`, toggle endpoint |
| **AvailabilityService** | `lib/services/availability_service.dart` | Wraps `ShphAvailabilityApi` — list, create, delete, toggle slots |
| **Availability Calendar page** | `lib/pages/availability_calendar/` (model + widget) | Month picker, calendar grid with day selection, slot CRUD dialog |
| **Wallet page update** | `lib/pages/wallet/wallet_model.dart`, `wallet_widget.dart` | Async loading, loading indicator, real data from `WalletService` |
| **Fixes** | `lib/pages/booking_payment/booking_payment_model.dart` | Added missing `backButtonModel` field (LSP error) |

### Phase 11 — Remaining Feature Pages (Pure SHPH API) ✅

**Goal:** Build all remaining client/provider pages from web reference excluding admin suite.

#### API Resources (new)

| File | Endpoints |
|------|-----------|
| `lib/api/resources/earnings_api.dart` | `GET /api/earnings/summary/`, `/transactions/`, `/payouts/`, `POST /api/earnings/request-payout/` |
| `lib/api/resources/analytics_api.dart` | `GET /api/analytics/provider/`, `/revenue-breakdown/`, `/services/{id}/metrics/` |

#### API Additions (existing resources)

| File | Added Methods |
|------|--------------|
| `lib/api/resources/services_api.dart` | `deleteListing`, `archiveListing`, `unarchiveListing`, `uploadListingThumbnail` |
| `lib/api/resources/bookings_api.dart` | `confirmArrival`, `startService`, `completeJob`, `uploadCompletionPhoto`, `updatePartsCost`, `createReview` |

#### New Services (wraps API — no Supabase)

| Service | Purpose |
|---------|---------|
| `lib/services/my_services_service.dart` | List, update, archive, delete provider listings |
| `lib/services/provider_analytics_service.dart` | Analytics, revenue breakdown, service metrics |
| `lib/services/provider_bookings_service.dart` | Full provider booking flow (accept → complete) |

#### New Pages (7)

| Page Widget | Route | Purpose |
|------------|-------|---------|
| `lib/pages/my_services/my_services_widget.dart` | `/my-services` | Provider service listings with archive/delete/edit toggle |
| `lib/pages/earnings/earnings_widget.dart` | `/earnings` | Summary grid, transaction list, payout history |
| `lib/pages/provider_analytics/provider_analytics_widget.dart` | `/provider-analytics` | Metrics grid, performance bars, top services drill-down |
| `lib/pages/provider_booking_flow/provider_booking_flow_widget.dart` | `/provider/booking/:bookingId` | 5-step wizard: accepted→en_route→arrived→in_progress→completed |
| `lib/pages/write_review/write_review_widget.dart` | `/write-review/:bookingId` | Star rating + text review submission |
| `lib/pages/otp_page/otp_page_widget.dart` | `/otp` | Phone OTP send + verify with cooldown |
| `lib/pages/not_found/not_found_widget.dart` | `/404` | Friendly 404 page with Go Home button |

#### New Components (5)

| Component | Purpose |
|-----------|---------|
| `lib/components/trust_badge.dart` | Verified provider reputation badge |
| `lib/components/searchable_select.dart` | Searchable modal dropdown |
| `lib/components/auth_prompt_modal.dart` | Sign-in prompt dialog |
| `lib/components/recommendation_card.dart` | Provider recommendation card (avatar, badges, price) |
| `lib/components/service_recommendations.dart` | Recommendation list composable |

### ✅ Phase 12 — Final Phase: Complete Redesign & Polish

**Goal:** Last phase covering brand identity fix, last page gap, payment integration, state management migration, remaining component parity, and zero lint errors.

| Task | Approach | Status |
|------|----------|--------|
| **12.1 Design token realignment** | `lib/theme/app_theme.dart`: change `primary` from `#368EFF` to `#63CBD6` (teal), add `onPrimary: #0F172A`, change `info: #FFFFFF` → `#63CBD6`, change `error: #FF5963` → `#DC2626`, add `bgPage: #F8FAFC`, `shadowMd`, `shadowLg`, `star: #FFC107`; align `textPrimary` → `#0F172A`, `textSecondary` → `#64748B`; update `iconBackground` → `#D4F0EF` | ⚠️ Partially reverted: `primary` → `#368EFF` (blue), `onPrimary` → `#FFFFFF`, `info` → `#368EFF` (all reverted to pre-teal values). `error`, `bgPage`, text colors, `shadowMd`/`shadowLg`, `star` kept. |
| **12.2 Page audit after brand color change** | Fixed 7 hardcoded `#368EFF` references across 5 files; replaced `shadowElevated` → `shadowLg` across 5 files | ✅ Done |
| **12.3 CreateProfilePage** | Already exists at `lib/pages/create_profile/` with routes `/createProfile` and `/pro-profile-setup-form` | ✅ Done (already existed) |
| **12.4 PaymentController wiring** | Already wired into `booking_payment_screen.dart` — Stripe for cards, Maya for e-wallets, cash and QR options | ✅ Done (already wired) |
| **12.5 State management migration** | `AuthService` created (`lib/services/auth_service.dart`), `NotificationStore` created (`lib/services/notification_store.dart`); `FavoritesService` and `KycHubService` already existed | ✅ Done |
| **12.5b Auth provider migration** | Supabase auth → SHPH API auth. `ShphAuthManager` + `ShphUserProvider` replace `SupaFlow`. `AuthProvider.shph` is default. Sign-in/up pages use `AuthService` directly. Google/Apple buttons show "coming soon" snackbar. | ✅ Done |
| **12.6 Wire notification badge + chat unread** | Home model already fetches notification count; messages model already syncs unread count; `FFAppState` has `notificationCount` + `unreadConversations` | ✅ Done (already wired) |
| **12.7 Remaining component parity** | Built 10 new components in `lib/components/`: `CallAcceptPermissionSheet`, `ExploreMapView`, `InAppNotification`, `IncomingJobModal`, `InvoiceLineItems`, `OnboardingOverlay`, `PopoverMenu`, `ProviderMapView`, `StepUpPasswordModal`, `WaitingForClientModal` | ✅ Done |
| **12.8 Font family alignment** | `GoogleFonts.poppins()` → `GoogleFonts.plusJakartaSans()` across 690 occurrences in 90+ files | ✅ Done |
| **12.9 Zero lint + unused imports** | Cleaned: `shadowElevated` (0 refs), `GoogleFonts.poppins` (0 refs), `#368EFF` (0 refs) | ✅ Done |

---

## 9. File Structure Migration Plan

### New Directory Layout

```
lib/
├── components/           # 30+ shared components (all ported, Phase 12 final)
│   ├── screen_header.dart         # Phase 1
│   ├── section_header.dart        # Phase 1
│   ├── content_container.dart     # Phase 1
│   ├── category_pill.dart         # Phase 1
│   ├── service_card.dart          # Phase 4
│   ├── booking_card.dart          # Phase 4
│   ├── booking_step_indicator.dart # Phase 4
│   ├── star_rating.dart           # Phase 5
│   ├── status_pill.dart           # Phase 5
│   ├── empty_state_widget.dart    # Phase 5
│   ├── error_state_widget.dart    # Phase 5
│   ├── user_avatar.dart           # Phase 5
│   ├── categoriesgrid/            # Phase 6
│   ├── soft_card.dart             # Phase 6
│   ├── trust_badge.dart           # Phase 8
│   ├── review_card.dart           # Phase 8
│   ├── provider_status_toggle.dart # Phase 8
│   ├── availability_calendar.dart # Phase 8
│   ├── earnings_chart.dart        # Phase 8
│   ├── call_accept_permission_sheet.dart  # Phase 12
│   ├── explore_map_view.dart      # Phase 12
│   ├── in_app_notification.dart   # Phase 12
│   ├── incoming_job_modal.dart    # Phase 12
│   ├── invoice_line_items.dart    # Phase 12
│   ├── onboarding_overlay.dart    # Phase 12
│   ├── popover_menu.dart          # Phase 12
│   ├── provider_map_view.dart     # Phase 12
│   ├── step_up_password_modal.dart # Phase 12
│   └── waiting_for_client_modal.dart # Phase 12
├── theme/
│   └── app_theme.dart    # 25+ tokens, 3 shadow levels, radii, statusColors
├── services/
│   ├── auth_service.dart          # Phase 12
│   ├── notification_store.dart    # Phase 12
│   ├── favorites_service.dart
│   ├── payment_controller.dart
│   ├── chat_service.dart
│   └── bookings_service.dart
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

## 10. Migration Strategy

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

## 11. Success Criteria — Progress

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
- [x] All pages use `ScreenHeader` consistently (remaining: auth, booking funnel parts, old booking pages)
- [x] `StarRating`, `StatusPill`, `UserAvatar` extracted as reusable components
- [x] ServiceCard, BookingCard extracted as shared components
- [x] `BookingStepIndicator` created + booking funnel polish
- [x] `EmptyState` / `ErrorState` / `SoftCard` components created
- [x] `BookingCard`/`ServiceCard` extracted as shared components in `lib/components/`
- [x] Wallet page (`/wallet`): balance card + quick actions + transaction history
- [x] Wallet page wired to real SHPH API data (balance/earnings/spent/transactions from `ShphBookingsApi`)
- [x] Provider Availability Calendar (`AvailabilityCalendar` widget + page)
- [x] Provider Analytics / Earnings Charts (`EarningsChart` widget + standalone page)
- [x] AI Booking Composer service (`ai_composer_service.dart`) — fixed stub → real OpenRouter API
- [x] AI Booking Composer page created (`/ai-booking-composer`)
- [x] Rich Chat upgrades: `RichChatBar` (mic/image/sticker buttons) + `ImageLightbox`
- [x] On-Demand Booking page (`/on-demand-booking`): urgency + time slots + summary
- [x] Provider Online/Offline Toggle (`ProviderStatusToggle` widget)
- [x] Remaining `surfaceTintColor` references cleaned up
- [ ] Home page matches web layout: hero + categories + recommendations (⚠️ reverted to pre-Phase 6) 
- [x] Auth/onboarding theming (Phase 5): splash branding, hardcoded hex colors → theme tokens across 7 auth pages
- [x] Chat Detail page created (`/chat/:threadId`) with pure SHPH API backend
- [x] Earnings Chart standalone page created (`/earnings-chart`)
- [x] Availability Calendar page created (`/availability-calendar`)
- [x] SHPH API resource for availability (`ShphAvailabilityApi`)
- [x] All 8 new services use pure SHPH API (no Supabase dependency)
- [x] MyServices page (provider listing mgmt) with archive/delete
- [x] Earnings page with summary grid, transactions, payouts
- [x] Provider Analytics page with metrics, performance bars, service drill-down
- [x] Provider Booking Flow (5-step wizard: accepted→en_route→arrived→in_progress→completed)
- [x] Write Review page (star rating + text for completed bookings)
- [x] OTP page (phone send + verify with resend cooldown)
- [x] NotFound 404 page
- [x] TrustBadge, SearchableSelect, AuthPromptModal components
- [x] RecommendationCard + ServiceRecommendations components
- [x] EarningsApi + AnalyticsApi resources
- [x] Provider booking endpoints added to BookingsApi (confirmArrival, startService, completeJob, etc.)
- [x] ServicesApi additions (deleteListing, archiveListing, unarchiveListing)
- [x] Payment integration works end-to-end (Stripe + Maya + Cash + QR via PaymentController)
- [x] Zero hardcoded old brand references (`#368EFF`, `shadowElevated`, `GoogleFonts.poppins`)

### ⚠️ Phase 12 — Partially Reverted

- [~] Design tokens realigned: `primary`/`onPrimary`/`info` reverted to blue (`#368EFF`/`#FFFFFF`/`#368EFF`); `error`, `bgPage`, `shadowMd`, `shadowLg`, `star`, text color alignment kept
- [x] All pages audited for broken references after brand color change
- [x] `CreateProfilePage` exists (post-signup profile setup)
- [x] PaymentController wired into booking payment screen
- [x] State management migrated: `AuthService`, `FavoritesService`, `NotificationStore`, `KycStore`
- [x] Auth provider migrated: Supabase → SHPH API (`ShphAuthManager` + `ShphUserProvider`)
- [x] Notification badge connected to real data; chat unread synced in real-time
- [x] Remaining 10 components built and added to `lib/components/`
- [x] Font family aligned from Poppins to Plus Jakarta Sans
- [~] Hardcoded `#368EFF`, `shadowElevated`, or `GoogleFonts.poppins` — mostly zero (home page reverted from pre-Phase 6 may reintroduce some)

---

## 12. Web App Gap Analysis — Pages Missing in Flutter

Comparison against `C:\Users\Administrator\dev\shph-web` (Vue 3 + Ionic 8).

### Auth

| Web Page | Flutter Equivalent | Status |
|----------|-------------------|--------|
| `SplashPage` | ✅ `SplashWidget` | Done |
| `OnboardingPage` | ✅ `OnboardingWidget` | Done |
| `SignOptionsPage` | ✅ `SignOptionsWidget` | Done |
| `LoginPage` | ✅ `SigninWidget` | Done |
| `RegisterPage` | ✅ `SignupWidget` | Done |
| `CreateProfilePage` | ✅ `CreateProfileWidget` | Done |
| `OtpPage` | ✅ `OtpPageWidget` | Done |
| `PhoneVerifyUserPage` | ✅ `PhoneVerifyUserWidget` | Done |
| `ForgotPasswordPage` | ✅ `ForgotPasswordWidget` | Done |
| `SetPasswordPage` | ✅ `SetPasswordWidget` | Done |
| `BiometricSetupPage` | ✅ `BiometricSetupWidget` | Done |
| `LocationPermissionPage` | ✅ Inline in onboarding | Handled on splash |

### Tabs (Main Navigation)

| Web Page | Flutter Equivalent | Status |
|----------|-------------------|--------|
| `HomePage` | ✅ `HomeWidget` | Done |
| `ExplorePage` | ✅ `ExploreWidget` | Done |
| `BookingsPage` | ✅ `BookingsWidget` | Done |
| `MessagesPage` | ✅ `MessagesWidget` | Done |
| `ProfilePage` | ✅ `ProfileWidget` | Done |

### Services / Booking

| Web Page | Flutter Equivalent | Status |
|----------|-------------------|--------|
| `SearchPage` | ✅ `SearchPageWidget` | Done |
| `CategoriesPage` | ✅ `CategoriesWidget` | Done |
| `CategoryDetailPage` | ✅ `CategoryDetailWidget` | Done |
| `SubcategoryPage` | ✅ `SubcategoryWidget` | Done |
| `ServiceDetailPage` | ✅ `ProductPageWidget` | Done |
| `ProviderProfilePage` | ✅ `ProviderProfileWidget` | Done |
| `BookingFlowPage` | ✅ `BookingFlowScreen` | Done |
| `BookingPage` | ✅ `BookingWidget` | Done |
| `BookingPaymentPage` | ✅ `BookingPaymentWidget` | Done |
| `BookingSuccessPage` | ✅ `BookingSuccessWidget` | Done |
| `BookingDetailPage` | ✅ `BookingDetailsWidget` | Done |
| `WriteReviewPage` | ✅ `WriteReviewWidget` | Done (new) |
| `ContactProviderPage` | ✅ `ContactProviderWidget` | Done |
| `FavoritesPage` | ✅ `FavoritesWidget` | Done |
| `RecommendationsPage` | ✅ `RecommendationsWidget` | Done |
| `OnDemandBookingPage` | ✅ `OnDemandBookingWidget` | Done |
| `ClientOnDemandJobsPage` | ✅ `ClientOnDemandJobsWidget` | Done |
| `RoomList/Create/Detail/Join` | ✅ 4 Room pages | Done |
| `ProjectList/Create/Detail` | ✅ 3 Project pages | Done |
| `EtaTrackingPage` | ✅ `EtaTrackingWidget` | Done |
| `TM*` pages (8) | ✅ All 8 TM pages | Done |

### Chat

| Web Page | Flutter Equivalent | Status |
|----------|-------------------|--------|
| `ChatPage` (listing) | ✅ `MessagesWidget` + `ChatPageWidget` | Done |
| `ChatPage` (detail by id/thread) | ✅ `ChatDetailWidget` | Done |
| `CallDetailPage` | ✅ `CallHistoryDetailsPageWidget` | Done |

### Provider

| Web Page | Flutter Equivalent | Status |
|----------|-------------------|--------|
| `ProviderDashboardPage` | ✅ `ProDashboardWidget` | Done |
| `ProviderAvailabilityPage` | ✅ `AvailabilityCalendarWidget` | Done |
| `EarningsPage` | ✅ `EarningsWidget` | Done (new) |
| `MyServicesPage` | ✅ `MyServicesWidget` | Done (new) |
| `PostServicePage` | ✅ `CreateServiceWidget` | Done |
| `ReviewsPage` | ✅ `ReviewsRatingsWidget` | Done |
| `ProviderBidsPage` | ✅ `ProviderBidsWidget` | Done |
| `ProviderAnalyticsPage` | ✅ `ProviderAnalyticsWidget` | Done (new) |
| `ProviderBookingFlowPage` | ✅ `ProviderBookingFlowWidget` | Done (new, multi-step wizard) |
| `ReviewScanPage` | ✅ `DocumentScanWidget` | Done |

### Profile / Settings

| Web Page | Flutter Equivalent | Status |
|----------|-------------------|--------|
| `SettingsPage` | ✅ `SettingsWidget` | Done |
| `NotificationsPage` | ✅ `MyNotificationsWidget` | Done |
| `AddressesPage` | ✅ `AddressesWidget` | Done |
| `AddressFormPage` | ✅ `AddressFormWidget` | Done |
| `EditProfilePage` | ✅ `EditProfileWidget` | Done |
| `PaymentMethodsPage` | ✅ `PaymentMethodsWidget` | Done |
| `WalletPage` | ✅ `WalletWidget` | Done |
| `LanguageSettingsPage` | ✅ `LanguageSettingsWidget` | Done |
| `ThemeSettingsPage` | ✅ `ThemeSettingsWidget` | Done |
| `GeographicSelectionPage` | ✅ `GeographicSelectionWidget` | Done |
| `SessionsPage` | ✅ `SessionsWidget` | Done |
| `DisputesPage` | ✅ `DisputesWidget` | Done |
| `NotificationPreferencesPage` | ✅ `NotificationPreferencesWidget` | Done |

### KYC

| Web Page | Flutter Equivalent | Status |
|----------|-------------------|--------|
| `KycPage` | ✅ `KycHubWidget` | Done |
| `KycIntroPage` | ✅ `EKYCBeginWidget` | Done |
| `KycInstructionsPage` | ✅ `IDVerifyWidget` / `DocumentScanWidget` | Done |
| `KycLivenessPage` | ✅ `FaceVerificationScreen` | Done |
| `KycReviewPage` | ✅ `VerificationReviewingWidget` | Done |

### Admin (All Missing)

| Web Page | Flutter Equivalent | Status |
|----------|-------------------|--------|
| `AdminDashboardPage` | ❌ **Missing** | Admin stats dashboard |
| `KycQueuePage` | ❌ **Missing** | KYC approval queue |
| `KycDetailPage` | ❌ **Missing** | Individual KYC review |
| `AdminDisputesPage` | ❌ **Missing** | Dispute mgmt |
| `AdminPayoutsPage` | ❌ **Missing** | Payout management |
| `AdminAuditLogsPage` | ❌ **Missing** | Audit trail |
| `AdminUsersPage` | ❌ **Missing** | User management |
| `AdminChatPickerPage` | ❌ **Missing** | Chat impersonation |

### Other

| Web Page | Flutter Equivalent | Status |
|----------|-------------------|--------|
| `HelpSupportPage` | ✅ `HelpSupportWidget` | Done |
| `ReportProblemPage` | ✅ `ReportProblemWidget` | Done |
| `PinLocationPage` | ✅ `PinLocationWidget` | Done |
| `TermsPage` | ✅ `TermsOfServiceWidget` | Done |
| `PrivacyPage` | ✅ `PrivacyPolicyWidget` | Done |
| `NotFoundPage` | ✅ `NotFoundWidget` | Done (new) |
| `CallPermissionPage` | ✅ `CallPermissionWidget` | Done |
| `ShareTargetPage` | ⏭️ Skipped (PWA-only) | Not applicable for mobile |

## 13. Component Gap Analysis — Missing Shared Components

| Web Component | Flutter | Priority | Notes |
|---------------|---------|----------|-------|
| `AddPaymentMethodModal` | ✅ Inline modals exist | Low | Already functioning |
| `AuthPromptModal` | ✅ `AuthPromptModal` | Done | **New component** |
| `CallAcceptPermissionSheet` | ✅ `CallAcceptPermissionSheet` | Done | Built Phase 12 |
| `ExploreMapView` | ✅ `ExploreMapView` | Done | Built Phase 12 |
| `IconChip` | ❌ **Low priority** | Deferred | CategoryPill already covers this use case |
| `InAppNotification` | ✅ `InAppNotification` | Done | Built Phase 12 |
| `IncomingJobModal` | ✅ `IncomingJobModal` | Done | Built Phase 12 |
| `InvoiceLineItems` | ✅ `InvoiceLineItems` | Done | Built Phase 12 |
| `OnboardingOverlay` | ✅ `OnboardingOverlay` | Done | Built Phase 12 |
| `PersonaSimulationBanner` | ❌ **Dev-only** | Skipped | Not needed in production |
| `PopoverMenu` | ✅ `PopoverMenu` | Done | Built Phase 12 |
| `ProviderMapView` | ✅ `ProviderMapView` | Done | Built Phase 12 |
| `SearchableSelect` | ✅ `SearchableSelect` | Done | Built earlier |
| `StepUpPasswordModal` | ✅ `StepUpPasswordModal` | Done | Built Phase 12 |
| `TrustBadge` / `TrustBadgeRow` | ✅ `TrustBadge` | Done | Built earlier |
| `RecommendationCard` | ✅ `RecommendationCard` | Done | Built earlier |
| `ServiceRecommendations` | ✅ `ServiceRecommendations` | Done | Built earlier |
| `WaitingForClientModal` | ✅ `WaitingForClientModal` | Done | Built Phase 12 |

## 14. Design Token Gaps — All Resolved ✅ (Phase 12)

| Token | Web Value | Flutter Final | Status |
|-------|-----------|---------------|--------|
| `--shph-primary` | `#63CBD6` | `AppTheme.of(context).primary` = `#63CBD6` | ✅ Realigned |
| `--shph-on-primary` | `#0F172A` | `AppTheme.of(context).onPrimary` = `#0F172A` | ✅ Added |
| `--shph-bg-page` | `#F8FAFC` | `AppTheme.of(context).bgPage` = `#F8FAFC` | ✅ Added |
| `--shph-radius-lg` | `16px` | `AppThemeData.radiusLg` = `16` | ✅ Already existed |
| `--shph-radius-hero` | `24px` | Same as `radiusCard` | ✅ Covered |
| `--shph-shadow-md` | `0 3px 16px rgba(17,38,74,0.07)` | `shadowMd` = same | ✅ Added |
| `--shph-shadow-lg` | `0 10px 26px -8px rgba(17,38,74,0.18)` | `shadowLg` = same | ✅ Added |
| `--shph-star` | `#FFC107` | `AppThemeData.star` = `#FFC107` | ✅ Added |
| `--shph-error` | `#DC2626` | `AppTheme.of(context).error` = `#DC2626` | ✅ Realigned |
| `--shph-info` | `#63CBD6` | `AppTheme.of(context).info` = `#368EFF` | ❌ Mismatch (reverted) |
| `--shph-text-primary` | `#0F172A` | `AppTheme.of(context).primaryText` = `#0F172A` | ✅ Aligned |
| `--shph-text-secondary` | `#64748B` | `AppTheme.of(context).secondaryText` = `#64748B` | ✅ Aligned |
| `--shph-font-family` | `"Plus Jakarta Sans"` | `GoogleFonts.plusJakartaSans()` throughout | ✅ Aligned |
## 13. Post-Phase 12 Changes — Current Session

### 13.1 Theme Color Revert (Blue → Teal → Blue)

| Change | Before | After |
|--------|--------|-------|
| `primary` | `#63CBD6` (teal) | `#368EFF` (blue) |
| `onPrimary` | `#0F172A` | `#FFFFFF` |
| `info` | `#63CBD6` | `#368EFF` |

**File:** `lib/theme/app_theme.dart`

### 13.2 Auth Migration: Supabase → SHPH API

| Task | Files | Status |
|------|-------|--------|
| `ShphAuthManager` created | `lib/auth/shph_auth/shph_auth_manager.dart` | ✅ Done |
| `ShphUserProvider` wraps API user | `lib/auth/shph_auth/shph_user_provider.dart` | ✅ Done |
| `auth_manager_factory.dart` default→`shph` | `lib/auth/auth_manager_factory.dart` | ✅ Done |
| `main.dart` uses `AuthService` not `SupaFlow` | `lib/main.dart` | ✅ Done |
| `auth_util.dart` branches for Supabase/SHPH | `lib/auth/auth_util.dart` | ✅ Done |
| Sign-in/up pages use `AuthService` | `signin_widget.dart`, `signup_widget.dart` | ✅ Done |
| Google/Apple sign-in → snackbar "coming soon" | `signin_widget.dart` | ✅ Done |

### 13.3 Home Page Revert

| Task | Status |
|------|--------|
| Restored from pre-Phase 6 commit `8d34b3d` | ✅ Done |
| `GoogleFonts.poppins` → `GoogleFonts.plusJakartaSans` | ✅ Done |
| `shadowElevated` → `shadowLg` | ✅ Done |
| File was corrupted by `-NoNewline` write; fixed by re-extracting from git | ✅ Done |

### 13.4 Status Page Refactor

| Change | Status |
|--------|--------|
| Removed `_movementTimer` and waypoint/route generation (`_generateRouteWaypoints`, `_buildPolyline`, `_updateStatusBasedOnDistance`) | ✅ Done |
| Added `_mockProgressTimer` ticking every 2.5s through `[confirmed, en_route, on_site, in_progress, completed]` | ✅ Done |
| On `on_site` status: `_currentProviderLocation` snaps to `clientLocation` | ✅ Done |
| On `completed` status: timer stops, pulse animation stops | ✅ Done |
| Cleaned up unused fields (`_movementTimer`, `_statusTimer`, `_routeWaypoints`, `_currentWaypointIndex`) | ✅ Done |

**File:** `lib/pages/booking_funnel/status_page.dart`

### 13.5 Connectivity Banner (Brave-style)

| Task | Status |
|------|--------|
| `ConnectivityService` (ChangeNotifier, uses `connectivity_plus`) | ✅ Created |
| `ConnectivityBanner` widget (red gradient, `wifi_off` icon, "You are offline") | ✅ Created |
| Wired into `MaterialApp.router.builder` in `main.dart` | ✅ Wired |

### 13.6 Android Build Fixes

| Task | Status |
|------|--------|
| Added `<uses-permission android:name="android.permission.INTERNET"/>` | ✅ Done |
| `desugar_jdk_libs` bumped from `2.0.4` → `2.1.5` in `android/app/build.gradle.kts` | ✅ Done |
| APK release build succeeds (176.8 MB) | ✅ Done |
| No release keystore; signed with debug keystore for now | ⚠️ Dev only |

### 13.7 Post-Migration Bugfixes (SHPH API auth)

| Task | Files | Status |
|------|-------|--------|
| Re-added `SupaFlow.initialize()` so Supabase DB fallbacks still work | `lib/main.dart` | ✅ Done |
| Provider messages error fixed: `ProMessagesWidget` now uses `currentUser?.uid` (SHPH auth) instead of `Supabase.auth.currentUser?.id` | `lib/main/pro_dashboard/pro_dashboard_widget.dart` | ✅ Done |
| Supabase realtime subscription guarded + 30s polling fallback | `lib/main/pro_dashboard/pro_dashboard_widget.dart` | ✅ Done |
| `ChatService` fallbacks use `currentUser?.uid` | `lib/services/chat_service.dart` | ✅ Done |
| `ProProfileWidget`/`ProEarningsWidget` use `currentUser?.uid` + `AuthService.logout()` | `lib/main/pro_dashboard/pro_dashboard_widget.dart` | ✅ Done |
| Provider profile menu spacing aligned to client profile (12px gaps, section card, logout tile styling) | `lib/main/pro_dashboard/pro_dashboard_widget.dart` | ✅ Done |

### 13.8 Supabase Removal (SHPH API only)

Supabase has been removed entirely from the app. The SHPH REST API
(`https://api.serbisyohub.ph`) is now the sole backend for auth and data.
Generated row classes remain as pure Dart; features without SHPH endpoints are
stubbed/no-op.

| Task | Status |
|------|--------|
| Removed `supabase_flutter`, `supabase`, `storage_client`, `realtime_client`, `postgrest` from `pubspec.yaml`; `flutter pub get` resolves without them and `pubspec.lock` has zero Supabase packages | ✅ Done |
| Deleted `lib/backend/supabase/migrations/001_add_face_verification.sql` | ✅ Done |
| Auth flows SHPH-only: `auth_util.dart`, `auth_manager_factory.dart`, `main.dart`, `token_refresh_manager.dart`, `app_router.dart` (`_fetchUserProfile` via `ShphUsersApi.getMe`) | ✅ Done |
| Services rewritten SHPH-only: `search_service`, `service_listing_service`, `profiles_service`, `chat_service`, `pro_bookings_service` (`ShphBookingsApi`/`ShphEarningsApi`), `dispatch/dispatch_service` (`ShphOnDemandJobsApi`), `push_notification_service`, `ai_service`, `verification_timer_service` (`currentUser?.uid`) | ✅ Done |
| Custom actions rewritten: `upload_scanned_to_supabase` (`ShphUsersApi.uploadPhoto`), `insert_profile_with_debug` (`updateMe`) | ✅ Done |
| Realtime replaced by polling: `chat_page_model.dart` (5s), `my_notifications_widget.dart` (15s), `pro_dashboard_widget.dart`, `dispatch_repository.dart`, `tm_repository.dart` (5s) | ✅ Done |
| Repos rewritten SHPH-only: `booking_repository.dart`, `dispatch_repository.dart`, `tm_repository.dart`; TM provider geo-matching stubbed (`_findRealProvider` → `null`) | ✅ Done |
| Pages de-Supabase'd: security_settings (sessions via `ShphSessionsApi`, MFA stubbed), pro_verification (doc scan + face verification via `currentUser?.uid`/`ProfilesService`), profile_widget (uploads via `ProfilesService.uploadProfilePhoto`, update via `updateProfile`), create_profile, booking_details, create_service, reviews_ratings, payment methods | ✅ Done |
| Full `flutter analyze` passes with **0 errors** | ✅ Done |

**Still-stubbed gaps (no SHPH endpoint yet):** TOTP MFA management, password
change with current password (reset email used), provider geo-radius fallback
matching, chat realtime (polling), document/ID bucket uploads, address
persistence, file deletion.

### 13.9 Auth Fix (fix-shph-auth)

OpenSpec change: `fix-shph-auth`. Fixed `ShphApiException(null): request failed` on
sign-in/sign-up and made the Flutter auth client match the working web contract.

| Task | Files | Status |
|------|-------|--------|
| Live API host confirmed: `https://serbisyohubph.com` (web `.gitlab-ci.yml` `VITE_API_URL=https://serbisyohubph.com/api`); old default `https://api.serbisyohub.ph` fails TLS | `lib/api/api_config.dart` | ✅ Done |
| `POST /auth/me/` (was GET), `device_info` sent on login/register, `session_id` persisted + sent on refresh/logout | `lib/api/resources/auth_api.dart`, `lib/api/shph_api_client.dart`, `lib/api/shph_token_storage.dart` | ✅ Done |
| DRF error envelope unwrap (`{error:true, detail}` / `non_field_errors` / field errors) + friendly connection message | `lib/api/shph_api_exception.dart`, `lib/services/error_handler.dart` | ✅ Done |
| `DeviceInfoService` mirroring web `deviceInfo.ts` | `lib/services/device_info_service.dart` (new) | ✅ Done |
| Sign-up rewritten to web `RegisterPage` parity: `register/initiate` → OTP → `register/verify` (phone_number/pin), Supabase duplicate-phone check removed | `lib/auth/auth_manager.dart`, `lib/auth/shph_auth/shph_auth_manager.dart`, `lib/pages/signup/*` | ✅ Done |
| Phone login via `phone-login/send|verify`; OTP page via `send_otp_pin`/`verify_otp_pin` | `lib/pages/phone_verify_user/*`, `lib/pages/otp_page/otp_page_model.dart`, `lib/api/bridges/shph_auth_bridge.dart` | ✅ Done |
| `verifyRegistration` for register-vs-login mode in phone verify page | `lib/auth/shph_auth/shph_auth_manager.dart`, `lib/pages/phone_verify_user/phone_verify_user_widget.dart` | ✅ Done |
| Sign-in error surfacing (server detail / connection message instead of raw exception) | `lib/pages/signin/signin_widget.dart` | ✅ Done |
| Session state: `_currentUser` from `data['user']`, pending registration state, cold-start restore | `lib/services/auth_service.dart` | ✅ Done |
| Verification: `flutter analyze` 0 errors; `proximity_scoring_test.dart` 20/20; `booking_funnel_test.dart` 3/4 (1 pre-existing Unsplash-image failure) | — | ✅ Done |
| Manual device round-trip (sign-up → OTP → verified) | — | ⏳ Pending user |

### 13.10 Client Home, Explore & Category Icon Cleanup

Rolled the client home top section back to the pre-Phase 6 (main-branch) layout,
removed a redundant filter row on Explore, and swapped category images for
Material icons keyed to the live API category slugs.

| Task | Files | Status |
|------|-------|--------|
| Home top overlay restored to main design: search capsule with the notification bell **inside** it (`Hero` `searchBarHero`) + in-demand chips below (Cleaning, Plumbing, Electrical, Painting, More → `ServicesScreen` w/ `initialCategory` / `CategoriesWidget`) | `lib/main/home/home_widget.dart` | ✅ Done |
| Removed warm-gradient panel, drawer menu button, greeting, subtitle, and location pill; deleted now-unused `_greeting()` / `_locationLabel()` | `lib/main/home/home_widget.dart` | ✅ Done |
| Explore tab: removed redundant `CategoryPill` filter row (only highlighted on tap, never filtered the grid) + dead `_pills` / `_selectedPill` / import | `lib/main/explore/explore_widget.dart` | ✅ Done |
| Category cards: replaced `Image.asset` artwork with Material icons matched by the API `ShphCategory.icon` slug (16 categories: key, wrench, zap, sparkles, wind, tool, bug, car, hammer, paint-bucket, home, layers, flame, tree, truck, users) with a name-based fallback | `lib/components/categories_widget/categories_widget.dart` | ✅ Done |
| Dropped `category_assets.dart` import (asset map now unused) | `lib/components/categories_widget/categories_widget.dart` | ✅ Done |
| Icon preview verified via standalone HTML (`explore_preview.html`); Masonry uses `Icons.layers_rounded` (the `bricks` ligature rendered a stray "s") | — | ✅ Done |
| Verification: `flutter analyze` 0 errors | — | ✅ Done |

### 13.11 Supabase-Stub → SHPH API Wiring (8 call sites)

Wired the 8 remaining page-level `queryRows`/`update` call sites that still went
through the no-op Supabase stub tables (which silently returned empty results) to
the already-built SHPH API services. `flutter analyze` passes with **0 errors**.

| Call site | Before (stub) | After (SHPH API) | Files |
|-----------|---------------|------------------|-------|
| Home saved addresses | `AddressesTable().queryRows` | `AddressesService.instance.getAddresses()` mapped via new `ApiRowMapper.addressToRow` (kept `FFAppState().getAddress` cache + selected-address sync) | `lib/main/home/home_widget.dart`, `lib/api/bridges/api_row_mapper.dart` |
| Home notification count | `NotificationsTable().queryRows` | `NotificationStore.instance.fetchNotifications()` + `unreadCount` | `lib/main/home/home_model.dart` |
| Edit-address bottom sheet | `AddressesTable().queryRows` | `AddressesService.instance.getAddresses()` → `AddressesRow` | `lib/components/edit_address/edit_address_widget.dart` |
| My Notifications page | `NotificationsTable()` query/update | `NotificationStore.instance` (`fetchNotifications` / `markAsRead(int)` / `markAllAsRead`); `AppNotification` now parses `redirect_url`→`route`, `data`/`info`→`metadata`, exposes `createdAtDateTime` for the relative-time formatter; deep-link logic unchanged | `lib/pages/my_notifications/my_notifications_widget.dart`, `lib/services/notification_store.dart` |
| Search page | `ServiceListingsTable().queryRows` (SQL `ilike`) | `ServiceListingService.instance.fetchServiceListings(search:)` mapped back to `ServiceListingsRow`; category/rating/price filtering stays local | `lib/pages/search_page/search_page_widget.dart` |
| Bookings enrichment | `ServiceListingsTable().queryRows` (`inFilter`) | `ServiceListingService.instance.fetchServiceListingById(id)` per booking | `lib/main/bookings/bookings_model.dart` |
| Service reviews list | `ReviewsTable().queryRows` | `ReviewsService.instance.getServiceReviews(listingId)` | `lib/pages/reviews/reviews_widget.dart` |
| My Reviews | `ReviewsTable().queryRows` + `ServiceListingsTable()` | `ReviewsService.instance.getUserReviews()` (now real via new `ShphReviewsApi.listMyReviews()` → `/api/services/reviews/mine/`) + per-id listing lookup | `lib/pages/my_reviews/my_reviews_widget.dart`, `lib/services/reviews_service.dart`, `lib/api/resources/favorites_api.dart` |

**API-gap findings from this pass:**
- `PaymentMethodsTable` (payment_methods model + add-card/add-ewallet + pro dashboard) — no `/api/payments/methods/` endpoint in `SHPH API.yaml` (still blocked).
- `my_reviews` client review history — `/api/services/reviews/mine/` is **provider-only**; clients get an honest empty list.
- `nearby_pro_mock_data.dart` still drives services/booking-controller/live-matching geo-matching (mock data, deferred).
- `docs/api_gaps.md` is stale (claims `preferShphApi=false`; it's `true`) — should be updated or deleted.

