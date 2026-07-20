# SHPH Mobile Port — Progress Log

> **Last updated:** 2026-07-20
> **Branch:** `feature/pol` (merged `origin/main`)

---

## Completed

### Phase 0 — Foundation
- ✅ Merged `origin/main` → `feature/pol` (9 commits, zero conflicts)
- ✅ Upgraded Flutter 3.19.5 → 3.44.6 (Dart 3.3.3 → 3.12.2)
- ✅ Enabled Windows Developer Mode (symlink support)
- ✅ Added `fl_chart: ^0.70.2` to `pubspec.yaml`
- ✅ `flutter pub get` successful

### Phase 1a — Provider Analytics Page
- ✅ Created `lib/services/provider_analytics_service.dart` — aggregates completed bookings, reviews, booking insights, 12-month revenue, performance metrics (repeat clients, avg job value, completion rate, avg rating)
- ✅ Created `lib/main/pro_dashboard/pro_analytics_widget.dart` — full analytics UI with:
  - Stat cards (total earnings, jobs done)
  - 12-month revenue bar chart (fl_chart)
  - Booking insights (completed/cancelled/pending + completion rate progress bar)
  - Performance metrics (repeat clients %, avg job value, rating)
  - Growth recommendations (dynamic tips based on metrics)
- ✅ Added "Analytics" tab to pro_dashboard bottom nav (6 tabs now)
- ✅ Registered in `index.dart` and `app_router.dart`

### Phase 1b — Provider Bids Page
- ✅ Created `lib/services/provider_bids_service.dart` — fetches provider's dispatch offers with job + client info, withdraw (reject) pending offers
- ✅ Created `lib/main/pro_dashboard/provider_bids_widget.dart` — bids list UI with:
  - Status badges (pending/accepted/withdrawn/timed out)
  - Service type, client name, offered time
  - Withdraw action for pending bids (with confirmation dialog)
  - Empty state
- ✅ Registered in `index.dart` and `app_router.dart`

### Phase 1c — Earnings Payout Requests
- ✅ Created `database/create_payouts_table.sql` — payouts table with status enum (pending/approved/completed/rejected), RLS policies for provider + admin
- ✅ Created `lib/services/payouts_service.dart` — request payout, list payouts, cancel payout
- ✅ Replaced stubbed cash-out in `pro_dashboard_widget.dart` `_handleCashOut()` with real payout request flow:
  - Validates earnings > 0
  - Checks for linked e-wallets, prompts to add if none
  - Bottom sheet with amount input, e-wallet selector, optional note
  - Submits to `payouts` table (status: pending)
  - Admin reviews via Phase 4 admin panel

### Phase 1d — Reviews Respond
- ✅ Created `database/add_provider_reply_to_reviews.sql` — adds `provider_reply` + `provider_reply_at` columns, RLS policy for provider update
- ✅ Added `respondToReview()` method to `lib/services/reviews_service.dart`
- ✅ Updated `reviews_ratings_widget.dart` — each review card now shows:
  - Existing provider reply (blue card) if present
  - "Respond" button if no reply yet
  - Reply dialog with text input
  - Refreshes list after posting

### Phase 2 — Wallet & Payments
- ✅ Created `database/create_wallet_tables.sql` — wallets + wallet_transactions tables, RLS, `top_up_wallet()` + `pay_from_wallet()` RPC functions
- ✅ Created `lib/services/wallet_service.dart` — get wallet balance + transactions, top-up, pay-from-wallet
- ✅ Created `lib/pages/wallet/wallet_widget.dart` — full wallet UI:
  - Gradient balance card
  - Quick actions (Top Up, History)
  - Top-up dialog with preset amounts (100/200/500/1000)
  - Transaction list with type icons, credits (green) / debits (red)
  - Empty state
- ✅ Registered in `index.dart` and `app_router.dart`

### Phase 3 — Client Gaps
- ✅ Created `database/create_disputes_and_notif_prefs.sql` — disputes + dispute_evidence + notification_preferences tables, RLS, admin policies
- ✅ Created `lib/services/disputes_service.dart` — DisputesService (list, create, upload evidence) + NotificationPreferencesService (get, update)
- ✅ Created `lib/pages/disputes/disputes_widget.dart` — disputes UI:
  - List disputes with status badges (open/under review/resolved/closed/rejected)
  - Create dispute dialog (reason + description)
  - Evidence file count display
  - FAB to file new dispute
  - Empty state
- ✅ Created `lib/pages/notification_preferences/notification_preferences_widget.dart` — preferences UI:
  - Channel toggles (push, email, SMS)
  - Category toggles (booking updates, payment updates, promo offers, provider alerts)
  - Instant save on toggle
- ✅ Registered all in `index.dart` and `app_router.dart`

---

## Pending

### Phase 1e — Post/My Services parity + gallery upload
- Verify `create_service_widget.dart` field parity with web `PostServicePage.vue`
- Add multi-image gallery upload (web added `ServiceListingImage` endpoints)

### Phase 4 — Admin surface
- Dashboard, KYC queue, Disputes mgmt, Payouts mgmt, Users mgmt, Audit logs

### Phase 5 — Deferred
- WebRTC video calls, Biometric login, Active sessions

---

## Detailed Changelog

### 1. Deletions / Removals

| File | What was removed | Why |
|------|-----------------|-----|
| `pubspec.yaml` | `config:` block under `flutter:` section (`enable-swift-package-manager: false`) | Invalid key that causes `flutter pub get` to fail. Not a valid pubspec key for Flutter 3.x. |
| `pubspec.yaml` | `pubspec.lock` was deleted and regenerated (multiple times during dependency troubleshooting) | Needed to resolve version conflicts after Flutter SDK upgrade. New lock file generated from upgraded SDK. |
| `lib/main/pro_dashboard/pro_analytics_widget.dart` | `import '/flutter_flow/flutter_flow_util.dart';` | **Unused import.** The widget does not use `safeSetState` or any other utility from `flutter_flow_util.dart`. Flagged by `flutter analyze` as `unused_import`. Removing it has zero functional impact. |
| `lib/main/pro_dashboard/provider_bids_widget.dart` | `import 'package:supabase_flutter/supabase_flutter.dart';` | **Unused import.** The widget delegates all Supabase calls to `ProviderBidsService` — it never calls `Supabase.instance.client` directly. Flagged by `flutter analyze` as `unused_import`. Removing it has zero functional impact. |
| `lib/pages/wallet/wallet_widget.dart` | `import '/flutter_flow/flutter_flow_util.dart';` | **Unused import.** Same reason — widget does not use any `flutter_flow_util` functions. Flagged by `flutter analyze` as `unused_import`. |

> **Note on import removals:** All removed imports were flagged by `flutter analyze` as `unused_import` warnings. No code in any of these files was actually referencing symbols from the removed packages. The removals are purely cleanup — they do not change any behavior, logic, or functionality. If future code additions need these imports, they should be re-added at that time.

### 2. Code Changes to Existing Files

| File | What was changed | Before → After |
|------|-----------------|----------------|
| `pubspec.yaml` | Added `fl_chart: ^0.70.2` dependency | No chart library → `fl_chart` added for bar charts in analytics |
| `pubspec.yaml` | Flutter SDK upgraded | Flutter 3.19.5 / Dart 3.3.3 → Flutter 3.44.6 / Dart 3.12.2 (via `flutter upgrade`) |
| `lib/index.dart` | Added 5 new exports | Added `ProAnalyticsWidget`, `ProviderBidsWidget`, `WalletWidget`, `DisputesWidget`, `NotificationPreferencesWidget` exports so they're accessible app-wide |
| `lib/router/app_router.dart` | Added 5 new `GoRoute` entries | Added routes for `/pro-analytics`, `/provider-bids`, `/wallet`, `/disputes`, `/notification-preferences` |
| `lib/main/pro_dashboard/pro_dashboard_widget.dart` | Added Analytics tab to bottom nav | 5 tabs → 6 tabs (added ProAnalyticsWidget as 6th tab with `Insights` icon) |
| `lib/main/pro_dashboard/pro_dashboard_widget.dart` | Replaced `_handleCashOut()` method | **Before:** Stubbed flow that showed a bottom sheet saying "Automated provider cash-out is not enabled yet" with only "Add/Manage Payout Wallet" and "Maybe Later" buttons. **After:** Real payout request flow that validates earnings, checks for e-wallets, shows amount input + e-wallet selector + optional note, submits to `payouts` table via `PayoutsService.instance.requestPayout()` |
| `lib/main/pro_dashboard/pro_dashboard_widget.dart` | Added `_showPayoutRequestSheet()` method | New method — builds the payout request bottom sheet with amount, wallet selector, and note fields |
| `lib/main/pro_dashboard/pro_dashboard_widget.dart` | Added `import '/services/payouts_service.dart';` | Required for the new payout request flow |
| `lib/services/reviews_service.dart` | Added `respondToReview()` method | New method that updates `provider_reply` and `provider_reply_at` columns on a review via Supabase |
| `lib/main/pro_dashboard/reviews_ratings_widget.dart` | Added `import '/services/reviews_service.dart';` | Required for the new reply functionality |
| `lib/main/pro_dashboard/reviews_ratings_widget.dart` | Added `_buildProviderReplySection()` method | New method that renders either the existing provider reply (blue card) or a "Respond" button |
| `lib/main/pro_dashboard/reviews_ratings_widget.dart` | Added `_showReplyDialog()` method | New method that shows a dialog with a text field for the provider to write a reply, then calls `ReviewsService.instance.respondToReview()` |
| `lib/main/pro_dashboard/reviews_ratings_widget.dart` | Modified `_buildReviewCard()` | Added `..._buildProviderReplySection(context, review)` at the end of the card's column children |

### 3. New Files Created (Additions)

#### Services

| File | Purpose |
|------|---------|
| `lib/services/provider_analytics_service.dart` | Fetches and computes provider analytics from Supabase: total earnings, monthly revenue (12 months), booking insights (completed/cancelled/pending counts + completion rate), performance metrics (repeat clients %, avg job value, avg rating), growth recommendations |
| `lib/services/provider_bids_service.dart` | Fetches provider's dispatch offers with joined job_requests + client profile data. `withdrawBid()` sets offer status to 'rejected'. |
| `lib/services/payouts_service.dart` | CRUD for payout requests: `requestPayout()` inserts to `payouts` table (status: pending), `getPayoutRequests()` lists provider's payouts, `cancelPayoutRequest()` cancels a pending payout |
| `lib/services/wallet_service.dart` | Wallet operations: `getWallet()` fetches balance + last 50 transactions, `topUp()` calls `top_up_wallet()` RPC, `payFromWallet()` calls `pay_from_wallet()` RPC |
| `lib/services/disputes_service.dart` | Contains two services: `DisputesService` (list disputes, create dispute, upload evidence) and `NotificationPreferencesService` (get/update notification preferences with auto-create defaults) |

#### UI Widgets

| File | Purpose |
|------|---------|
| `lib/main/pro_dashboard/pro_analytics_widget.dart` | Full analytics page: stat cards, 12-month revenue bar chart (fl_chart), booking insights with progress bar, performance metrics, growth tips. Route: `/pro-analytics` |
| `lib/main/pro_dashboard/provider_bids_widget.dart` | Bids list page: status badges, service type, client name, offered time, withdraw action with confirmation. Route: `/provider-bids` |
| `lib/pages/wallet/wallet_widget.dart` | Wallet page: gradient balance card, quick action buttons (Top Up, History), top-up dialog with preset amounts, transaction list with type icons + credit/debit colors. Route: `/wallet` |
| `lib/pages/disputes/disputes_widget.dart` | Disputes page: list with status badges, create dispute dialog, evidence count, FAB to file new dispute. Route: `/disputes` |
| `lib/pages/notification_preferences/notification_preferences_widget.dart` | Notification preferences page: channel toggles (push/email/SMS), category toggles (booking/payment/promo/provider alerts), instant save on toggle. Route: `/notification-preferences` |

#### SQL Migrations

| File | Purpose |
|------|---------|
| `database/create_payouts_table.sql` | Creates `payouts` table with `payout_status` enum (pending/approved/completed/rejected), RLS policies for provider + admin |
| `database/add_provider_reply_to_reviews.sql` | Adds `provider_reply TEXT` and `provider_reply_at TIMESTAMPTZ` columns to `reviews` table, RLS policy allowing providers to update replies on reviews for their own services |
| `database/create_wallet_tables.sql` | Creates `wallets` + `wallet_transactions` tables, `wallet_transaction_type` enum, RLS policies, `top_up_wallet()` and `pay_from_wallet()` RPC functions (atomic balance updates + transaction logging) |
| `database/create_disputes_and_notif_prefs.sql` | Creates `disputes` + `dispute_evidence` + `notification_preferences` tables, `dispute_status` enum, RLS policies for users + admin |

---

## Phase 1e: Post/My Services Parity + Gallery Upload (Jul 2026)

### Changes

#### Model Updates
- **`lib/models/service_listing.dart`**: Added `galleryUrls` field and `allImages` getter to support multi-image galleries. Parses `images` array from API responses.

#### Service Layer
- **`lib/services/service_listing_service.dart`**: Added `dart:io` and `package:supabase_flutter/supabase_flutter.dart` imports. New methods:
  - `fetchMyListings()` — fetches provider's own listings (API-first, Supabase fallback)
  - `updateListing()` — updates listing fields (title, category, description, price, availability)
  - `deleteListing()` — deletes a listing
  - `archiveListing()` / `unarchiveListing()` — toggles archive status
  - `uploadListingImage()` — uploads image to Supabase Storage `services` bucket, inserts record in `service_listing_images` table
  - `fetchListingImages()` — fetches gallery images for a listing
  - `deleteListingImage()` — deletes a gallery image

#### New Widgets
- **`lib/main/pro_dashboard/my_services_widget.dart`**: Full "My Services" page with:
  - Provider's listing list with status badges (Available/Unavailable/Archived)
  - Gallery thumbnail preview per listing
  - Availability toggle (optimistic update)
  - Edit, Archive/Restore, Delete actions
  - Add gallery image via image picker
  - Empty state with CTA
  - Pull-to-refresh

#### Updated Widgets
- **`lib/main/pro_dashboard/create_service_widget.dart`**: Added edit mode support:
  - Reads `edit` query param to load existing listing
  - Pre-fills form fields and shows existing gallery images
  - Dynamic title/button text ("Edit Service" / "Save Changes")
  - New images uploaded to `service_listing_images` table on save
  - `_buildExistingImagePreview()` for showing current gallery images
- **`lib/main/pro_dashboard/pro_dashboard_widget.dart`**: Added "My Services" outlined button above "Create a Service" button in provider profile tab

#### SQL Migrations
- **`database/create_service_listing_images.sql`**: Creates `service_listing_images` table with `listing_id`, `image_url`, `sort_order` fields. RLS policies: public read, provider insert/update/delete for own listings, admin full access.

#### Registration
- **`lib/index.dart`**: Added `MyServicesWidget` export
- **`lib/router/app_router.dart`**: Added GoRoute for `/pro/my-services`

---

## Phase 4: Admin Surface (Jul 2026)

### New Files

#### Service Layer
- **`lib/services/admin_service.dart`**: Complete admin service with:
  - `isAdmin` getter — checks `profiles.role == 'admin'`
  - `getDashboardStats()` — counts: users, providers, pending KYC, open disputes, pending payouts, active listings
  - `getKycSubmissions()` — fetches profiles with verification status, filterable
  - `updateKycStatus()` — approve/reject KYC, updates `is_verified` flag, logs audit action
  - `getAllDisputes()` — fetches all disputes, filterable by status
  - `updateDisputeStatus()` — resolve/close disputes with resolution text
  - `getAllPayouts()` — fetches all payout requests, filterable
  - `updatePayoutStatus()` — approve/reject/complete payouts
  - `getAllUsers()` — fetches all users with search and role filter
  - `updateUserRole()` — change user role (client/provider/admin)
  - `getAuditLogs()` — fetches recent admin actions
  - `_logAuditAction()` — internal method to insert audit log entries

#### Admin UI (6 tabs)
- **`lib/main/admin/admin_dashboard_widget.dart`**: Main admin shell with `NavigationBar` (6 tabs), admin access check with access denied screen
- **`lib/main/admin/admin_dashboard_tab.dart`**: Stats grid (users, providers, pending KYC, open disputes, pending payouts, active listings) with colored icon cards
- **`lib/main/admin/admin_kyc_tab.dart`**: KYC verification queue with filter chips (all/pending/verified/rejected), approve/reject buttons, document URL display
- **`lib/main/admin/admin_disputes_tab.dart`**: Disputes management with filter chips, resolve dialog (with resolution text), close action
- **`lib/main/admin/admin_payouts_tab.dart`**: Payouts management with filter chips, approve/reject/complete workflow, amount display
- **`lib/main/admin/admin_users_tab.dart`**: Users management with search bar, role filter chips, role change dialog (radio list), verification badge
- **`lib/main/admin/admin_audit_tab.dart`**: Audit logs list with action icons, timestamps, details preview

#### SQL Migrations
- **`database/create_audit_logs.sql`**: Creates `audit_logs` table with `admin_id`, `action`, `target_id`, `target_user_id`, `details` (JSONB). RLS: admin-only read/insert/delete.

#### Registration
- **`lib/index.dart`**: Added `AdminDashboardWidget` export
- **`lib/router/app_router.dart`**: Added GoRoute for `/admin`

---

## Phase 5: Deferred Features (Jul 2026)

### Biometric Authentication
- **`pubspec.yaml`**: Added `local_auth: ^2.3.0` dependency
- **`lib/services/biometric_service.dart`**: New service with:
  - `isAvailable()` — checks device biometric capability
  - `isEnabled()` / `setEnabled()` — persisted toggle via SharedPreferences
  - `authenticate()` — triggers biometric prompt
  - `getAvailableBiometrics()` — lists available biometric types

### Active Sessions
- **`lib/services/sessions_service.dart`**: New service with:
  - `recordSession()` — creates session record with device info (via `device_info_plus`)
  - `updateLastActive()` — updates session timestamp
  - `getActiveSessions()` — fetches user's active sessions
  - `revokeSession()` — deletes a session
  - `clearCurrentSession()` — clears local session ID
- **`database/create_user_sessions.sql`**: Creates `user_sessions` table with `user_id`, `device_name`, `platform`, `last_active`. RLS: users manage own sessions.

### WebRTC (Stub)
- **`lib/services/webrtc_service.dart`**: Stub service with documented implementation steps. Methods throw `UnimplementedError` with guidance for future implementation:
  - `initialize()`, `startCall()`, `endCall()`, `acceptCall()`, `declineCall()`
  - Documents need for `flutter_webrtc` package, Supabase Realtime signaling, and `video_calls` table

### Security Settings UI
- **`lib/pages/security/security_settings_widget.dart`**: New page with:
  - Biometric login toggle (with auth prompt on enable)
  - Active sessions list with device name, platform icon, last active time
  - "This device" badge for current session
  - Revoke session button for other devices
  - WebRTC "coming soon" info card

#### Registration
- **`lib/index.dart`**: Added `SecuritySettingsWidget` export
- **`lib/router/app_router.dart`**: Added GoRoute for `/settings/security`

## SQL Migrations to Run (Updated)

1. `database/create_payouts_table.sql` — creates payouts table
2. `database/add_provider_reply_to_reviews.sql` — adds provider_reply columns to reviews
3. `database/create_wallet_tables.sql` — creates wallets + wallet_transactions tables + RPC functions
4. `database/create_disputes_and_notif_prefs.sql` — creates disputes + dispute_evidence + notification_preferences tables
5. `database/create_service_listing_images.sql` — creates service_listing_images table for gallery
6. `database/create_audit_logs.sql` — creates audit_logs table for admin accountability
7. `database/create_user_sessions.sql` — creates user_sessions table for device session tracking

---

## Session 2026-07-20: Major Feature Ports

### 1. Push Notifications / FCM Integration

#### New Files
- **`lib/services/push_notification_service.dart`**: Full FCM integration service with:
  - Firebase Messaging initialization and permission requests
  - Local notification display via `flutter_local_notifications` (Android channels + iOS)
  - Device token registration/unregistration with backend (`POST /api/notifications/register/`, `POST /api/notifications/unregister/`)
  - Token refresh handling with automatic re-registration
  - Foreground message handling with local notification display
  - Notification tap routing via GoRouter (booking details, chat, etc.)
  - Background message handler

#### Updated Files
- **`pubspec.yaml`**: Added `firebase_core`, `firebase_messaging`, `flutter_local_notifications` dependencies
- **`lib/main.dart`**: Initialize `PushNotificationService` in `initState()`, pass navigator key, re-register token on login, unregister on logout
- **`lib/api/resources/notifications_api.dart`**: API resource for notification endpoints (register/unregister device tokens, list notifications, manage preferences)

---

### 2. Real-time Provider Location Tracking / ETA Sharing

#### New Files
- **`lib/services/eta_tracking_service.dart`**: ETA tracking service with two modes:
  - **Provider broadcast**: Uses `Geolocator` position stream (10m distance filter) with fallback to 10-second periodic polling. Pushes GPS coords to `PATCH /api/services/bookings/{id}/location/`
  - **Client polling**: Polls `GET /api/services/eta/{token}/` for public ETA tracking every 10 seconds
  - Distance calculation (Haversine) and ETA estimation helpers
- **`lib/pages/eta_tracking/eta_tracking_screen.dart`**: Client ETA tracking screen with:
  - Google Maps integration showing provider location marker
  - Provider info card (name, service, status badge)
  - Auto-refresh every 10 seconds
  - Error handling for expired/invalid tokens
  - Distance and estimated arrival time display

#### Updated Files
- **`lib/api/resources/bookings_api.dart`**:
  - Fixed `updateBookingLocation` field names (`lat`/`lng` matching backend `BookingLocationUpdateView`)
  - Fixed `shareEta` to return token from response
  - Added `getEtaPublic(token)` method for `GET /api/services/eta/{token}/`
- **`lib/pages/booking_details/booking_details_widget.dart`**:
  - Integrated `EtaTrackingService` for provider location broadcasting when status is `en_route`, `confirmed`, or `in_progress`
  - Replaced old share ETA dialog with new share token creation and clipboard copy of tracking link
  - Stop broadcasting on dispose
  - Removed unused `geolocator` import, added `flutter/services` for `Clipboard`
- **`lib/router/app_router.dart`**: Registered GoRoute for `/eta-tracking` with `token` query parameter
- **`lib/index.dart`**: Exported `EtaTrackingScreen`

#### Backend Endpoints Used
- `PATCH /api/services/bookings/{id}/location/` — provider updates GPS coordinates
- `POST /api/services/bookings/{id}/share-eta/` — client creates ETA share token
- `GET /api/services/eta/{token}/` — public ETA tracking (no auth required)

---

### 3. Wallet Reversal Support

Wallet reversal is server-side only — triggered automatically when a booking paid via wallet is cancelled. The backend `Wallet.reverse_booking()` method credits the client's wallet, debits provider earnings, and creates a `reversal` type `WalletTransaction`. No separate reversal API endpoint exists.

#### New Files
- **`lib/api/models/wallet_transaction.dart`**: Typed `WalletTransaction` model with:
  - `WalletTransactionType` enum (topup, payment, reversal, tip)
  - `fromString()` factory matching backend type strings
  - `isCredit` getter (topup/reversal/tip are credits)
  - `signedAmount` getter (+ for credits, - for payments)
  - `fromJson()` factory parsing API response

#### Updated Files
- **`lib/api/resources/wallet_api.dart`**:
  - Fixed `createTopUpIntent` — removed `currency` param (web only expects `amount`), changed type to `double`
  - Fixed `confirmTopUp` — field name `intent_id` (was `payment_intent_id`)
  - Added `listWalletTransactions()` — typed method returning `List<WalletTransaction>`
  - Added `wallet_transaction.dart` import
- **`lib/services/wallet_service.dart`**: Updated `topUp()` to use new API signatures (`amount` as double, `intent_id` field)
- **`lib/pages/wallet/wallet_widget.dart`**:
  - Fixed top-up flow to use `client_key` (was `client_secret`) and `intent_id` from API response
  - Fixed transaction type labels to match backend: `topup` (was `top_up`), added `tip` type
  - Removed non-existent types (`payout`, `refund`, `adjustment`) from label/color/icon maps
  - Added `tip` type with volunteer icon and green credit color
- **`lib/api/shph_api.dart`**: Added `wallet_transaction.dart` model export

---

### 4. Advanced Projects v2 — Verification

The Projects v2 feature was already fully implemented in the Flutter app. Verified all components match the web backend:

#### Already Present (Verified)
- **`lib/api/models/project.dart`**: `ShphProject`, `ShphProjectRoleLine`, `ShphProjectProspect` models with all fields matching web serializers
- **`lib/api/resources/projects_api.dart`**: All 7 endpoints matching web views:
  - `POST /api/projects/` — create project demand
  - `POST /api/projects/list/` — list user's projects
  - `POST /api/projects/{id}/` — retrieve project detail
  - `POST /api/projects/{id}/quote/` — generate AI quote with role lines
  - `POST /api/projects/{id}/match/` — find provider prospects for a role
  - `POST /api/projects/{id}/cancel/` — cancel project
  - `POST /api/projects/prospects/action/` — shortlist/invite/accept/decline prospect
- **`lib/services/projects_controller.dart`**: Full state management with `ProjectsState` enum, serialized mutations, error handling
- **`lib/pages/projects/project_list_page.dart`**: List with status filter chips, FAB to create, pull-to-refresh
- **`lib/pages/projects/project_detail_page.dart`**: Detail with status badge, budget/headcount, role line expansion tiles, prospect tiles with shortlist/invite/accept/decline actions, quote generation dialog, cancel confirmation
- **`lib/pages/projects/project_create_page.dart`**: Create form with title, description, category selector, B2B toggle
- Routes and `ProjectsController` provider registered in `app_router.dart` and `main.dart`

---

### Analyzer Status
All modified and new files pass `flutter analyze` with **zero errors**. Only style-level `info` warnings remain (control body formatting, expression function body preferences).
