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
| `--shph-primary` | `#63CBD6` (teal) | `AppTheme.of(context).primary` = `#368EFF` (blue) | ❌ Brand mismatch |
| `--shph-primary-dark` | `#49B8C4` | `AppTheme.of(context).primaryDark` = `#49B8C4` | ✅ Matches |
| `--shph-primary-light` | `#D4F0EF` | `AppTheme.of(context).primaryLight` = `#D4F0EF` | ✅ Matches |
| `--shph-primary-text` | `#0D6D78` | `AppTheme.of(context).primaryBrandText` = `#0D6D78` | ✅ Matches |
| `--shph-primary-deep` | `#0D6D78` | `primaryBrandText` = `#0D6D78` | ✅ Matches |
| `--shph-on-primary` | `#0F172A` | — | ❌ Missing |
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
| `--shph-info` | `#63CBD6` | `AppTheme.of(context).info` = `#FFFFFF` | ❌ Mismatch |
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

#### Phase 6 — Home Page Redesign (Complete)

| Task | Files Affected | Status |
|------|---------------|--------|
| 6.1 Hero section redesign | `home_widget.dart` | ✅ Brand "S" logo + "serbisyo" text, notification bell with badge, user avatar, location badge (tappable), greeting ("Good morning, Name!"), headline ("Find a trusted professional instantly"), search bar (tappable to `/search`), category chips row (All, Cleaning, Plumbing, etc.) matching web home layout |
| 6.2 Map preview card | `home_widget.dart` | ✅ Full-screen Google Map replaced with a compact 180px map preview card with location overlay |
| 6.3 Active booking banner | `home_widget.dart` | ✅ Inline banner showing current booking with status (Pending/Track) when active booking exists |
| 6.4 Book a Service CTA | `home_widget.dart` | ✅ Gradient button with "Book a Service" text and handyman icon, tapping opens `ServiceSelectionPanel` |
| 6.5 Explore Services category grid | `home_widget.dart` | ✅ 3-column grid of `_CategoryTileItem` widgets loading from `CategoriesService`, with `SectionHeader` ("Explore Services") and "See all" link to `/categories` |
| 6.6 Trending Near You carousel | `home_widget.dart` | ✅ Horizontal scrolling `_ServiceCardItem` cards loading from Supabase `service_listings`, showing image, title, provider, price, rating |
| 6.7 Pin location card | `home_widget.dart` | ✅ Tokenized card at bottom showing current address, tappable to open location sheet |
| 6.8 Removed old layout | `home_widget.dart` | ✅ Removed `_buildTopOverlay`, `_buildBottomCard`, `_buildCategoryChip`, `_LiveProgressShortcut` — replaced with scrollable `SingleChildScrollView` layout |
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

---

## 9. File Structure Migration Plan

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
- [x] Home page matches web layout: hero + categories + recommendations
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
- [ ] Payment integration works end-to-end (PayMongo + Maya)
- [ ] Zero lint errors; zero unused imports

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
| `CreateProfilePage` | ❌ **Missing** | Post-signup profile setup |
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
| `CallAcceptPermissionSheet` | ❌ **Missing** | Low | Call feature dependency |
| `ExploreMapView` | ❌ **Missing** | Low | Map-based explore |
| `IconChip` | ❌ **Missing** | Low | Chip with icon + label (CategoryPill exists) |
| `InAppNotification` | ❌ **Missing** | Low | Toast-style alerts |
| `IncomingJobModal` | ❌ **Missing** | Medium | Provider job notifications |
| `InvoiceLineItems` | ❌ **Missing** | Low | Invoice breakdown |
| `OnboardingOverlay` | ❌ **Missing** | Low | Tooltip-style tips |
| `PersonaSimulationBanner` | ❌ **Missing** | Low | Dev-only persona switcher |
| `PopoverMenu` | ❌ **Missing** | Low | Context menu |
| `ProviderMapView` | ❌ **Missing** | Low | Provider-side map |
| `SearchableSelect` | ✅ `SearchableSelect` | Done | **New component** |
| `StepUpPasswordModal` | ❌ **Missing** | Medium | Re-auth for sensitive actions |
| `TrustBadge` / `TrustBadgeRow` | ✅ `TrustBadge` | Done | **New component** |
| `RecommendationCard` | ✅ `RecommendationCard` | Done | **New component** |
| `ServiceRecommendations` | ✅ `ServiceRecommendations` | Done | **New component** |
| `WaitingForClientModal` | ❌ **Missing** | Low | Provider wait state |

## 14. Design Token Gaps

| Token | Web Value | Flutter | Priority |
|-------|-----------|---------|----------|
| `--shph-primary` | `#63CBD6` | Blue `#368EFF` — **brand mismatch** | **High** |
| `--shph-on-primary` | `#0F172A` | Missing | Medium |
| `--shph-bg-page` | `#F8FAFC` | Missing | Low |
| `--shph-radius-lg` | `16px` | Missing | Low |
| `--shph-radius-hero` | `24px` | Same as `radiusCard` | Low |
| `--shph-shadow-md` | `0 3px 16px rgba(17,38,74,0.07)` | Missing | Low |
| `--shph-shadow-lg` | `0 10px 26px -8px rgba(17,38,74,0.18)` | Missing | Low |
| `--shph-star` | `#FFC107` | Missing | Medium |
| `--shph-error` | `#DC2626` | `#FF5963` — different value | Medium |
| `--shph-info` | `#63CBD6` | `#FFFFFF` — wrong | Medium |
| `--shph-text-primary` | `#0F172A` | `#14181B` — close | Low |
| `--shph-text-secondary` | `#64748B` | `#57636C` — close | Low |
| `--shph-font-family` | `"Plus Jakarta Sans"` | `GoogleFonts.poppins()` | Low |
