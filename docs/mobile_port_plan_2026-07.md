# SHPH Mobile Port — Deep Plan (2026-07-12)

> **Status:** PLANNING ONLY — no code changes yet. Awaiting user signal before implementation.
> **Author run:** cross-repo audit of `SHPH_web_version` (Vue 3 + Django) vs `SerbisyoPH` (Flutter + Supabase).

This document answers the 5 tasks: (1) branch inventory of both repos, (2) what the web has that mobile still needs, (3) the state of the Flutter `main` branch (actively used by someone else), (4) verification of the "Missing in Flutter" screenshot + additional gaps found, and (5) the deep phased plan.

---

## 1. Branch Inventory (both repos)

### 1.1 Flutter repo — `SerbisyoPH`

| Branch | Role | Notes |
|--------|------|-------|
| `main` (`origin/main` = `dbb4931`) | **Actively used by another dev** | Ahead of `feature/pol` on app code. Do NOT diverge further without merging. |
| `feature/pol` (`origin/feature/pol` = `4d00242`) | My working branch | Ahead on docs/workflows, behind on app code. |

**The two branches have DIVERGED (not fast-forward).** Neither is a superset:

- **In `feature/pol` but NOT in `main`** (my commits): all `.devin/workflows/*`, `.devin/rules/cross-repo-context.md`, `docs/architecture_diagram.md`, `docs/web_app_gap_audit.md`, `docs/web_to_mobile_migration.md`, `android/key.properties.template` removal, misc.
- **In `main` but NOT in `feature/pol`** (other dev's commits — 9 commits `c8feb23..dbb4931`): full-screen map `StatusPage` rewrite, real-time provider movement + polyline route + waypoints, dynamic bottom sheet, intelligent chatbot (`lib/pages/help/chatbot_page.dart`), help page (`lib/pages/help/help_page.dart`), bell icon + auto-refresh bookings after cancel, Android release signing (`key.properties`, `build.gradle.kts`).

**Files touched on `main` since divergence** (potential merge-conflict hotspots):
`lib/pages/booking_funnel/status_page.dart` (major rewrite, ~818 lines), `lib/pages/booking_funnel/live_matching/live_matching_screen.dart`, `lib/pages/booking_funnel/widgets/booking_status_scaffold.dart`, `lib/pages/booking_details/booking_details_widget.dart`, `lib/main/bookings/bookings_widget.dart`, `lib/main/messages/messages_widget.dart`, `lib/main/profile/profile_widget.dart`, `lib/router/app_router.dart`, `lib/index.dart`, `android/*`.

> **ACTION (before coding):** merge/rebase `origin/main` into `feature/pol` first, so new feature work starts from the latest app code and we avoid conflicts on `status_page.dart`, `app_router.dart`, `index.dart`, `profile_widget.dart`.

### 1.2 Web repo — `SHPH_web_version` (meta-repo w/ submodules)

Root is a **git submodule parent**; branches: `main` (current), `SHPH-148-weight-calculation`, `papa2pher`.

Submodules (canonical on GitLab):

| Submodule | Path | Pinned commit | Branch | URL |
|-----------|------|---------------|--------|-----|
| `shph-api` | `shph-api/` | checked-out `0bb8cfe` → **remote `b549678`** | `main` | `git@gitlab.com:shph1/shph-api.git` |
| `shph-app` | `shph-app/` | checked-out `ef2cdac` → **remote `b7aaa5a`** | `main` | `git@gitlab.com:shph1/shph-app.git` |

> **Fetch note (2026-07-12, re-run):** `git fetch --all --prune` was run on both repos, and `git submodule foreach git fetch` on the web submodules. The submodule **working trees are still pinned** at `0bb8cfe`/`ef2cdac`, but **remote `main` has advanced** to `b549678` (shph-api, +17 commits) and `b7aaa5a` (shph-app, +21 commits). Most new commits are W6 UI reskins / a11y / refactors, but a few add real features — see §2.1a below.

### 2.1a New web commits since last audit (functionally relevant to porting)

- **Service listing gallery image upload** — `shph-api` `820fcc3`/`b549678` add `ServiceListingImage` upload endpoints; `shph-app` `b7aaa5a` wires gallery upload into `PostServicePage`. → folds into Phase 1e (Post/My Services parity): add multi-image gallery upload to `create_service_widget.dart`.
- **Report Problem / client Support** — `shph-app` `da8fae8` adds a report-problem page + support API, `8366da6` adds crash reporting + client help & support. → partial overlap with Flutter `main`'s new `help_page.dart`/`chatbot_page.dart`; verify parity and add a "report a problem" path if missing.
- Everything else (`W6-*` reskins, a11y contrast fixes, DRF/notification refactors) is internal polish — no new mobile gap.

Recent web work (context for what's "new" to port):
- **`shph-app`**: full UI reskin sweep (W3–W5) of KYC, Addresses, Booking detail; **new wallet UI** (`WalletPage.vue`, SHPH-150 prepaid wallet: top-up, pay-with-wallet, reversal); Time-&-Materials invoice pages (`TMInvoicePage`, `TMEstimatePage`, `InvoiceLineItems`).
- **`shph-api`**: KYC liveness backend (single-use nonce/challenge), chat `get_or_create_direct_thread`, wallet audit refactor, Wagtail AI authoring, security hardening.

---

## 2. What the Web Has that Mobile Still Needs

### 2.1 Web Vue pages (43 `.vue` views) vs Flutter pages

Legend: ✅ exists in Flutter · 🟡 partial · ❌ missing

| Web Vue View | Flutter equivalent | Status |
|--------------|--------------------|--------|
| `auth/*` (Login, Register, OTP, SetPassword, ForgotPassword, SignOptions, Splash, Onboarding, CreateProfile, PhoneVerify) | `signin`, `signup`, `set_password`, `forgot_password`, `sign_options`, `splash`, `onboarding`, `create_profile`, `phone_verify_user` | ✅ |
| `auth/BiometricSetupPage` | — | ❌ (biometric not ported) |
| `kyc/*` (Intro, Instructions, Review, Liveness, KycPage) | `e_k_y_c_begin`, `i_d_verify`, `pro_verification/*` | 🟡 (liveness/anti-spoof depth differs) |
| `profile/AddressesPage` + `AddressFormPage` | `addresses`, `address_form`, `pin_location`, `geographic_selection` | ✅ |
| `profile/SettingsPage`, `SessionsPage` | `settings`, `security_settings`, `language_settings` | 🟡 (no sessions/device mgmt page) |
| `profile/PaymentMethodsPage` | `lib/main/payment_methods/*` (add card, add e-wallet) | ✅ |
| `profile/WalletPage` | — | ❌ **wallet top-up / pay-with-wallet / balance / txns** |
| `profile/DisputesPage` | — | ❌ |
| `profile/NotificationsPage` | `my_notifications` | ✅ |
| `profile/NotificationPreferencesPage` | — | ❌ |
| `provider/ProviderDashboardPage` | `lib/main/pro_dashboard/pro_dashboard_widget.dart` (ProJobs/ProSchedule/ProEarnings/ProMessages/ProProfile) | 🟡 (exists, but no analytics segment) |
| `provider/ProviderAnalyticsPage` | — | ❌ **earnings chart, 12-mo revenue, perf metrics, feedback, growth tips** |
| `provider/EarningsPage` | `ProEarnings` tab in pro_dashboard (`getEarningsSummary`) | 🟡 (summary + weekly + txns exist; payout-request flow is stubbed — "cash-out not enabled yet") |
| `provider/ProviderAvailabilityPage` | `ProSchedule` + availability toggle in pro_dashboard | 🟡 (verify weekly slot editor parity) |
| `provider/ProviderBidsPage` | — | ❌ **on-demand bids list + withdraw** |
| `provider/PostServicePage` | `pro_dashboard/create_service_widget.dart` | 🟡 (verify field parity) |
| `provider/MyServicesPage` | `pro_dashboard/service_history_widget.dart` (?) | 🟡 (verify list/edit/deactivate) |
| `provider/ReviewsPage` (respond to reviews) | `pro_dashboard/reviews_ratings_widget.dart`, `my_reviews`, `reviews` | 🟡 (verify provider *respond* action) |
| `provider/ProviderProfilePage`, `ProviderHomePage` | `product_page`, home | 🟡 |
| `services/RecommendationsPage` | — | ❌ **AI recommendations** |
| `services/WriteReviewPage` | `reviews`, `my_reviews` | 🟡 |
| `services/ContactProviderPage` | `contact_provider` | ✅ |
| `chat/ChatPage`, `chat/CallDetailPage` | `chat_page`, `call_history_details_page` | 🟡 (video/WebRTC not ported) |
| `admin/AdminDashboardPage` | — | ❌ |
| `admin/KycQueuePage` + `KycDetailPage` | — | ❌ |
| `admin/AdminDisputesPage` | — | ❌ |
| `admin/AdminPayoutsPage` | — | ❌ |
| `admin/AdminUsersPage` | — | ❌ |
| `admin/AdminAuditLogsPage` | — | ❌ |
| (client on-demand jobs history) `ClientOnDemandJobsPage` | — | ❌ |

### 2.2 Backend/data implications

- The retired repository-local Node backend only covered **auth, chat, services,
  users** and has been removed. New mobile work must use the deployed SHPH API.
- Existing Supabase tables (`database/*.sql`): addresses, chat, notifications, payment_methods, service_listings, provider verification, **dispatch** (on-demand matching), spatial match.
- **No Supabase schema yet for:** disputes, earnings/payouts, wallet + wallet_transactions, provider availability slots, notification_preferences, recommendations, admin/audit logs, on-demand bids table (dispatch exists but bids-management may need its own).

> Each missing frontend feature that isn't already covered by Supabase needs a data decision: **(a)** add Supabase table + RLS, **(b)** add a Node/Express route, or **(c)** call the live SHPH Django API (`lib/api/` client exists but is disabled, `preferShphApi = false`). This must be decided per feature (see §5).

---

## 3. Flutter `main` Branch State (someone else is using it)

The other developer's `main` work is **booking-experience focused** and does not overlap with the provider/admin/wallet gaps I plan to port — EXCEPT for shared files:

- `lib/router/app_router.dart` — they removed 10 lines (help/chatbot routes added). New pages I add register here → **merge carefully**.
- `lib/index.dart` — barrel exports changed → **merge carefully**.
- `lib/main/profile/profile_widget.dart` — they trimmed 10 lines. New profile entries (Wallet, Disputes, Notification Prefs, Recommendations) go here → **merge carefully**.
- `lib/main/bookings/bookings_widget.dart`, `lib/main/messages/messages_widget.dart` — minor edits.

**Conclusion:** safe to build provider-analytics / wallet / disputes / admin as **new files**, but the wiring files (`app_router.dart`, `index.dart`, `profile_widget.dart`) must be edited on top of the latest `main`. Merge `main` → `feature/pol` first.

---

## 4. Screenshot Verification ("Missing in Flutter") + Additional Gaps

Each item from the shared screenshot, re-verified against the actual current Flutter code:

| # | Screenshot claim | Verified status | Evidence |
|---|------------------|-----------------|----------|
| 1 | Provider Dashboard — overview/analytics/ops segments, stat cards, revenue charts | 🟡 **Partial** | `pro_dashboard_widget.dart` exists (158 KB) with ProJobs/ProSchedule/ProEarnings/ProMessages/ProProfile + stat cards. **No analytics segment / revenue charts.** |
| 2 | Provider Analytics — earnings chart, 12-mo revenue, perf metrics, feedback, growth | ❌ **Missing** | No analytics page; no charting of 12-month revenue. |
| 3 | Provider Bids page — list + withdraw | ❌ **Missing** | Dispatch/on-demand matching exists (`services/dispatch/`), but no provider bids-management screen. |
| 4 | Provider Earnings page — summary, transactions, payout requests + method selection | 🟡 **Partial** | `ProEarnings` has summary/weekly/recent txns. **Payout request flow is a stub** ("automated cash-out not enabled yet"). |
| 5 | Provider Reviews page — list + respond | 🟡 **Partial** | `reviews_ratings_widget.dart` + `my_reviews`/`reviews` exist. **Verify provider "respond to review" action.** |
| 6 | Wallet page — balance, top-up via PayMongo, txn history, pay-from-wallet | ❌ **Missing** | Only `payment_methods` (cards/e-wallets). No wallet balance/top-up/pay-with-wallet. |
| 7 | Disputes page — create, upload evidence, list | ❌ **Missing** | No disputes UI or table. |
| 8 | Admin Dashboard — stats grid, quick actions | ❌ **Missing** | No admin surface at all. |
| 9 | Admin KYC Queue + Detail | ❌ **Missing** | — |
| 10 | Admin Disputes management | ❌ **Missing** | — |
| 11 | Admin Payouts management | ❌ **Missing** | — |
| 12 | Admin Users management | ❌ **Missing** | — |
| 13 | Admin Audit logs | ❌ **Missing** | — |
| 14 | Notification Preferences page | ❌ **Missing** | Only `my_notifications` list. |
| 15 | Recommendations page | ❌ **Missing** | No recommendations UI. |
| 16 | Client On-Demand Jobs list | ❌ **Missing** | No client on-demand history screen. |
| 17 | Post Service page — provider creates new listing | 🟡 **Partial** | `create_service_widget.dart` exists. **Verify field/category/pricing parity with `PostServicePage.vue`.** |

### 4.1 Additional gaps found (NOT in the screenshot)

- **Wallet / T&M invoices**: web added `TMInvoicePage`, `TMEstimatePage`, `InvoiceLineItems` (time-&-materials billing). Flutter `tm_flow/` exists — **verify invoice/estimate parity**.
- **Biometric login setup** (`BiometricSetupPage.vue`) — not ported.
- **Active Sessions / device management** (`SessionsPage.vue`) — not ported.
- **Video calls (WebRTC)** — `VideoCallOverlay.vue`, `IncomingCallNotification.vue`, `CallDetailPage.vue`; Flutter has `call_history_details_page` only (history, no live call).
- **KYC liveness anti-spoof** — web `shph-api` added single-use nonce + challenge plan; Flutter face-verification depth should be re-checked.
- **In-app notification toast** (`InAppNotification.vue`) + notification preferences backend.

---

## 5. Deep Phased Plan (implementation order)

> Do NOT start until user gives the signal. Each phase: decide data source (Supabase table / Node route / Django API) BEFORE UI.

### Phase 0 — Sync & foundation (blocking prerequisite)
1. Merge `origin/main` → `feature/pol`; resolve conflicts in `status_page.dart`, `app_router.dart`, `index.dart`, `profile_widget.dart`.
2. Confirm data-source strategy: **default to Supabase tables + RLS** for new features (matches existing app pattern); fall back to Django API only where parity/logic is heavy (payments, KYC liveness).
3. Add shared charting dep (e.g. `fl_chart`) to `pubspec.yaml` for analytics/earnings charts.

### Phase 1 — Provider completeness (highest ROI, provider retention)
- **1a. Provider Analytics page** — 12-month revenue, earnings chart, performance metrics, booking insights, customer feedback, growth recommendations. New file under `lib/main/pro_dashboard/` or `lib/pages/provider_analytics/`. Data: aggregate from `service_bookings` + `reviews` via Supabase RPC/view.
- **1b. Provider Bids page** — list provider's on-demand bids + withdraw. Data: dispatch/bids table (extend `dispatch_schema.sql`). Backend: Django `OnDemandBidWithdrawView` equivalent OR Supabase update.
- **1c. Earnings payout requests** — finish the stubbed cash-out: payout request + method selection + status. Needs `payouts` table + admin approval loop (ties to Phase 4).
- **1d. Reviews respond** — add provider reply action to `reviews_ratings_widget.dart`.
- **1e. Post/My Services parity** — verify `create_service_widget` fields vs `PostServicePage.vue`; add missing.

### Phase 2 — Wallet & payments (revenue-critical)
- Wallet page: balance, top-up via PayMongo, transaction history, pay-booking-from-wallet, reversal.
- Schema: `wallets`, `wallet_transactions` (Supabase) mirroring SHPH-150.
- PayMongo integration decision: reuse Django API `payments/` OR add Node route + PayMongo SDK. (PayMongo keys must be handled server-side — NEVER in Flutter.)

### Phase 3 — Client-facing gaps
- **Disputes page** — create dispute, upload evidence (Supabase Storage), list user disputes. Schema: `disputes`, `dispute_evidence`.
- **Notification Preferences page** — per-channel toggles. Schema: `notification_preferences`.
- **Recommendations page** — AI service recommendations. Data: Django `recommendations/` API or Supabase RPC.
- **Client On-Demand Jobs list** — client's on-demand job history (from dispatch tables).

### Phase 4 — Admin surface (internal ops)
- Admin Dashboard (stats grid + quick links), KYC Queue + Detail (approve/reject), Disputes mgmt (under-review/resolve/refund/close), Payouts mgmt (approve/complete/reject), Users mgmt (list/toggle active), Audit logs.
- Gate behind admin role (`app_state` role check). Data: Supabase with admin RLS policies OR Django admin API endpoints.

### Phase 5 — Deferred / heavy
- Video calls (WebRTC) — largest effort; separate initiative.
- Biometric login setup, Active sessions page, KYC liveness anti-spoof parity.

### Sequencing rationale
Provider tools (Phase 1) unblock the payout loop; Wallet (Phase 2) unblocks pay-with-wallet used by disputes/refunds (Phase 3); Admin (Phase 4) closes the payout/dispute/KYC loops end-to-end. Video (Phase 5) is isolated and largest, deferred last.

---

## 6. Open Decisions for User (need answers before coding)

1. **Data layer per feature:** Supabase-native (add tables/RLS) vs reuse the live Django SHPH API (`lib/api/`, currently disabled)? Recommendation: Supabase for CRUD, Django only for PayMongo + KYC liveness.
2. **Scope now:** all phases, or start with Phase 1 (provider) only?
3. **Admin in mobile:** do we really want the admin panel on mobile, or is web-only admin sufficient (skip Phase 4)?
4. **Branch strategy:** OK to merge `main` → `feature/pol` first (required to avoid conflicts)?
5. **PayMongo keys/secrets:** which server holds them (Django vs new Node route)?
