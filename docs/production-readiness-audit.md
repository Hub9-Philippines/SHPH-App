# Serbisyo Mobile App — Production Readiness Audit & Gap Analysis

**Date:** October 3, 2026  
**Target:** Client Flutter App (`com.hub9.serbisyohubph`)  
**Reference Web App:** `C:\Users\Administrator\dev\shph-web` (Vue 3 + Ionic 8)  
**Backend:** SHPH REST API (`https://serbisyohubph.com`)  
**Branch:** `main` (Synchronized with upstream commit `4270445`)

---

## 1. Executive Summary

A comprehensive architectural and code-level audit was conducted across the Serbisyo Flutter client app. The app has achieved significant milestones: static analysis reports **0 errors** (with only acceptable warning and info lints), the Supabase backend was cleanly excised in favor of the SHPH REST API, core authentication, localization (en/fil), and profile management are in place, and upstream commit `4270445` resolved in-app WebRTC calling and chat sender ownership.

However, several **critical blockers, payment integration mismatches, orphaned screens, and navigation glitches** prevent the app from being release-ready for production:

1. **Broken Digital Payments:** Card and E-wallet checkouts hit non-existent endpoints (`/api/payments/stripe/*` and `/api/payments/maya/*`), crashing or faking success. The backend actually uses **PayMongo** (`/api/payments/create-intent/`, `/api/payments/confirm/`).
2. **Silent Data Loss in Payment Methods:** Adding a credit card or e-wallet writes to an unregistered in-memory store (`DataTableStore`), causing newly added payment methods to immediately vanish.
3. **Category Navigation Route Glitch:** The `/category` route resolves to `NavBarPage(initialPage: 'Category')`, but `NavBarPage._tabs` lacks `'Category'`, silently redirecting users to Home.
4. **Booking Funnel Divergence:** Two parallel booking funnels exist. Home uses the modern live-matching flow, while Service Detail pages push a legacy FlutterFlow checkout that bypasses live matching and hits broken payment endpoints.
5. **Missing 5th Tab:** The "Explore" tab was deleted from the main shell in a previous refactor; web parity requires a 5-tab navigation bar.
6. **Push Notifications Stub:** Background notifications lack native FCM/APNs device token registration, pointing to a legacy host.

---

## 2. Upstream Synchronization Status (Commit `4270445`)

The latest upstream commit `4270445` (`feat(calls): in-app WebRTC calling with websocket signaling, chat & booking parity fixes`) was merged cleanly. The following previous findings were validated and updated:

| Finding | Pre-Sync Status | Post-Sync Status (`4270445`) | Verification |
|---|---|---|---|
| **WebRTC Audio/Video Calling** | Simulated mock enum (`CallService`) | **DELIVERED:** Full WebRTC engine (`webrtc_call_service.dart`, `websocket_service.dart`, `audio_call_overlay.dart`, `video_call_overlay.dart`) | Code inspected, call session controller active |
| **Chat Sender Ownership** | Inverted (`senderId == 'client'`) | **RESOLVED:** Compared against `currentUser.uid` (`_isMine`) | Verified in `chat_page_model.dart` |
| **Live Matching Failure Flow** | Preview countdown only | **INTEGRATED:** Real retry card & booking details link | Verified via `test/booking_funnel_test.dart` (5/5 passed) |
| **Dependency Lock Resolution** | `intl: 0.20.3` conflict with SDK | **RESOLVED:** Pinned to `intl: 0.20.2` matching Flutter SDK | `flutter pub get` succeeded |

---

## 3. System Architecture & Funnel Reality

```
                         SERBISYO CLIENT ARCHITECTURE
                                      │
        ┌─────────────────────────────┼─────────────────────────────┐
        ▼                             ▼                             ▼
  ┌──────────────┐             ┌──────────────┐             ┌──────────────┐
  │  NAVIGATION  │             │ BOOKING FLOW │             │ DATA / APIS  │
  │   & SHELL    │             │  DIVERGENCE  │             │  (REST API)  │
  └──────┬───────┘             └──────┬───────┘             └──────┬───────┘
         │                            │                            │
         ├─ 4 tabs (Home, Bookings,   ├─ Path 1 (Home Modern):     ├─ Real DRF Endpoints:
         │  Messages, Profile)        │  HomeRedesignWidget        │  Auth, Users, Listings,
         │  vs 5 tabs on Web          │    ▼ ExpressCheckout       │  Bookings, KYC, WebRTC
         │                            │    ▼ LiveMatchingScreen    │
         ├─ /category route           │    ▼ StatusPage            ├─ Chat:
         │  silent redirect bug       │                            │  Active polling,
         │                            ├─ Path 2 (Product Page):    │  ownership fixed
         └─ ~15 Orphaned Routes:      │  ProductPageWidget         │
            TM Flow (7 screens),      │    ▼ BookingWidget (Legacy)├─ Payments:
            Rooms (4 screens),        │    ▼ BookingPaymentWidget  │  Stripe/Maya 404 stubs
            Projects (3 screens),     │    ▼ BookingConfirmation   │  (Backend uses PayMongo)
            Disputes, ETA,            │                            │
            Client On-Demand          └─ Path 3 (TaskMatch Flow):  └─ Remaining Mocks:
                                         7 Dead Screens               FCM background push,
                                                                      wallet mutations
```

---

## 4. Critical Functional Bugs (Must Fix for Production)

### 4.1 Payment Gateway Breakdown (PayMongo Mismatch)
* **Files:** `lib/services/payment_controller.dart` & `lib/pages/booking_payment/booking_payment_widget.dart`
* **Root Cause:**
  1. `_fetchStripeClientSecret()` posts to `$baseUrl/api/payments/stripe/create-intent`.
  2. `_fetchMayaCheckoutUrl()` posts to `$baseUrl/api/payments/maya/create-checkout`.
  3. Neither endpoint exists in `SHPH API.yaml`. The backend payment suite is built on **PayMongo** (`/api/payments/create-intent/`, `/api/payments/checkout-session/`, `/api/payments/confirm/`).
  4. In `processMayaPayment()`, the code receives the checkout URL and immediately returns `PaymentStatus.success` without ever launching the payment browser or waiting for webhook/callback confirmation.
* **Impact:** Card and E-wallet checkouts fail with 404 errors. Only Cash on Delivery (`pay_on_completion`) functions.
* **Fix Required:** Update `PaymentController` to use `ShphPaymentsApi` with PayMongo intent creation and in-app checkout redirection.

---

### 4.2 Silent Data Loss in `PaymentMethodsTable`
* **Files:** `lib/main/payment_methods/payment_methods_model.dart` & `lib/backend/supabase/database/table.dart`
* **Root Cause:**
  * When adding a credit card (`AddCardPaymentWidget`) or e-wallet (`AddEwalletPaymentWidget`), the code calls `PaymentMethodsTable().insert(...)` and `queryRows(...)`.
  * `PaymentMethodsTable` routes through `DataTableStore.instance`.
  * `DataTableStore` has **zero registered data sources** in the codebase. Queries return `[]`, and inserts return `null`.
* **Impact:** Any payment method added by a user is silently discarded. The payment methods list is permanently empty.
* **Fix Required:** Connect `PaymentMethodsModel` to persistent local storage (Hive/SecureStorage) or real user payment method endpoints.

---

### 4.3 Silent Fallback on `/category` Navigation
* **Files:** `lib/router/app_router.dart` (Line 211) & `lib/main.dart` (Lines 254–259)
* **Root Cause:**
  ```dart
  // app_router.dart:211
  return const NavBarPage(initialPage: 'Category');

  // main.dart:254
  Map<String, Widget> get _tabs => const {
    'Home': HomeRedesignWidget(),
    'Bookings': BookingsWidget(),
    'Messages': MessagesWidget(),
    'Profile': ProfileWidget(),
  };
  ```
  `NavBarPage._tabs` only contains 4 keys. When asked for `'Category'`, index lookup returns `-1`, defaulting to index `0` (`Home`).
* **Impact:** Any deep link or category tile link to `/category` fails silently and navigates to Home.
* **Fix Required:** Route `/category` to a dedicated category browser page or add Category to bottom navigation.

---

## 5. Navigation & Feature Parity Gaps (vs. Web Target)

### 5.1 Missing "Explore" Tab
* **Web App:** 5-tab shell: `[ Home ] [ Explore ] [ Bookings ] [ Messages ] [ Profile ]`.
* **Flutter App:** 4-tab shell. `lib/main/explore/explore_widget.dart` was removed in an earlier cleanup.
* **Impact:** Rich discovery components created for Explore (`HeroOfferBanner`, `ProviderProximityCard`, `InviteEarnBanner`, `explore_map_view.dart`) have no top-level shell home.
* **Recommendation:** Restore the 5-tab bottom navigation with a dedicated Explore screen matching web discovery features.

### 5.2 Push Notifications (FCM / APNs)
* **File:** `lib/services/push_notification_service.dart`
* **Status:**
  * `pubspec.yaml` lacks `firebase_messaging`.
  * The service initializes a boolean flag without obtaining device APNs/FCM tokens.
  * It points to `https://api.serbisyohub.ph/api/notifications/send/` (a decommissioned host with failing TLS).
* **Impact:** No background notifications when the app is minimized or terminated. Users miss urgent job broadcasts, status updates, and messages.

---

## 6. Booking Funnel Divergence

| Metric | Path 1: Home Funnel (Modern) | Path 2: Service Detail (Legacy) | Path 3: TaskMatch Flow (Dead) |
|---|---|---|---|
| **Entry Point** | Home Quick Actions / Emergency | Product Page ("Book Now") | None (Orphaned routes) |
| **Controller** | `BookingFlowController` | None (ad-hoc StatefulWidget state) | `TMActiveJobScreen` state |
| **Quoting** | Server quote via `ShphBookingsApi.estimateBooking` | Local string calculation | Fixed mock pricing |
| **Payment UI** | Bottom sheet choice chip | `BookingPaymentWidget` | `TMPaymentScreen` |
| **Matching** | `LiveMatchingScreen` with radar ripple & cancel dialog | None (goes directly to confirmation) | `TMBroadcastScreen` with 180s timer |
| **Tracking** | `StatusPage` with live status stepper & polling | Static text on detail page | `TMActiveJobScreen` |

**Recommendation:** Deprecate Path 2 & Path 3. Wire `ProductPageWidget` to open `ExpressCheckoutScreen` backed by `BookingFlowController`.

---

## 7. Orphaned Screens & Dead UI Audit

The following screens exist in `lib/pages/` and are registered in `app_router.dart`, but cannot be reached via standard user navigation:

| Screen Name | File Path | Route Path | Why It Is Orphaned |
|---|---|---|---|
| **Disputes** | `lib/pages/disputes/disputes_widget.dart` | `/disputes` | No link from Booking Details or Profile. |
| **Report Problem** | `lib/pages/report_problem/report_problem_widget.dart` | `/reportProblem` | No link from Help Center or Profile. |
| **Client On-Demand Jobs** | `lib/pages/client_ondemand_jobs/client_ondemand_jobs_widget.dart` | `/client-on-demand-jobs` | Route exists, no button points to it. |
| **Collaborative Rooms** | `lib/pages/room_list/` (4 files) | `/roomList`, `/roomDetail/:id` | No entry point in client app. |
| **Projects Hub** | `lib/pages/project_list/` (3 files) | `/projectList`, `/projectDetail/:id` | No entry point in client app. |
| **ETA Tracking** | `lib/pages/eta_tracking/eta_tracking_widget.dart` | `/eta/:token` | Never launched from bookings or status. |
| **On-Demand Booking** | `lib/pages/on_demand_booking/on_demand_booking_widget.dart` | `/onDemandBooking` | Replaced by Home emergency sheet. |
| **Wallet Quick Actions** | `lib/pages/wallet/wallet_widget.dart` | `/wallet` | Top-Up, Send, and Withdraw buttons are empty callbacks `() {}`. |

---

## 8. Data Layer, Security & UI Hygiene

1. **Dark Mode Violations:**
   * **210 hardcoded `Color(0x...)`** and **222 `Colors.*`** instances outside `AppTheme`.
   * `ProfileWidget` forces light theme via `Theme(data: AppTheme.lightTheme())` with `Colors.white` scaffold backgrounds.
2. **AI Chatbot Secret Management:**
   * `AIService` directly contacts OpenRouter with a compile-time `--dart-define=OPENROUTER_API_KEY`. The secret is extractable from client binaries. Production apps should proxy AI requests through backend endpoints.
3. **Hardcoded Google Maps Key:**
   * `android/app/src/main/AndroidManifest.xml` line 46 embeds a raw Google Maps API key (`AIzaSy...`). Ensure this key has SHA-1 and package name restrictions in Google Cloud Console.
4. **Stale Test Suite:**
   * `test/widget_test.dart` is boilerplate counter test code that fails the full suite.

---

## 9. Prioritized Production Roadmap

```
┌────────────────────────────────────────────────────────────────────────┐
│                     RECOMMENDED RESOLUTION PHASES                      │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│ PHASE 1: P0 Critical Functional Bugfixes                               │
│ ├── Replace Stripe/Maya calls with PayMongo endpoints                  │
│ ├── Replace DataTableStore stub with real backend payment methods API  │
│ ├── Fix /category route navigation fallback                            │
│ └── Clean up test/widget_test.dart boilerplate                         │
│                                                                        │
│ PHASE 2: P1 Funnel Consolidation & Payments                            │
│ ├── Route ProductPage "Book Now" into ExpressCheckout / Controller     │
│ ├── Implement PayMongo WebView / Intent checkout flow                  │
│ └── Wire Wallet quick actions or hide until backend top-up is live     │
│                                                                        │
│ PHASE 3: P2 Shell & Navigation Parity                                  │
│ ├── Restore 5-tab bottom bar (Reintroduce Explore tab)                 │
│ ├── Link Disputes and Report Problem from Booking Details & Help       │
│ └── Clean up orphaned TaskMatch, Room, and Project files               │
│                                                                        │
│ PHASE 4: P3 Production Release Hardening                               │
│ ├── Integrate native FCM background push notifications                 │
│ ├── Clean up 210+ hardcoded colors for true Dark Mode parity           │
│ └── Generate production Android release keystore & configure signing   │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```
