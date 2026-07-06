# Web-to-Mobile Migration Guide

> **Date:** 2026-07-06  
> **Purpose:** Document the relationship between the original web app and the Flutter mobile app, and serve as a reference for porting features.

---

## 1. Repository Overview

| Property | Web App (Original) | Mobile App (Current) |
|----------|-------------------|---------------------|
| **Repo** | `SHPH_web_version` | `SerbisyoPH` (this repo) |
| **Path** | `C:\Users\Pol\Desktop\DEV\StartUp\SHPH_web_version` | `C:\Users\Pol\Desktop\DEV\StartUp\SerbisyoPH` |
| **Frontend** | Vue 3 + Ionic 8 + Capacitor 8 | Flutter 3.x (Dart) |
| **Backend** | Django 6 + DRF + Wagtail (Python) | Node.js + Express + TypeORM (TypeScript) |
| **Database** | PostgreSQL (default) + MongoDB via Djongo (chat) | PostgreSQL via Supabase |
| **Realtime** | Django Channels + Redis + WebSocket | Supabase Realtime |
| **Auth** | JWT + Firebase Admin + WebAuthn/Biometric | Supabase Auth (Google, Apple, email/password) |
| **State Mgmt** | Pinia (Vue stores) | Provider (ChangeNotifier + SharedPreferences) |
| **Routing** | Vue Router 4 | GoRouter |
| **HTTP** | Axios | Dio |
| **Maps** | Leaflet | Google Maps / Google Places |
| **Mobile Bridge** | Capacitor (JS ↔ Native) | Flutter (compiled to native) |
| **Payments** | PayMongo (cards) + Cash | Not yet implemented |
| **Push Notifs** | Firebase FCM | Firebase FCM |
| **Video Calls** | WebRTC (native RTCPeerConnection) | Not yet implemented |
| **Face Detection** | TensorFlow.js + face-api.js | Google ML Kit |
| **PWA/Offline** | Service Worker + IndexedDB | Not yet implemented |
| **CI/CD** | GitLab CI | GitHub Actions |

---

## 2. Architecture Comparison

### Web App (SHPH_web_version)

```
shph-api/ (Django backend)
  ├── src/shph/
  │   ├── auth_api/         — Auth, OTP, Biometric, Sessions
  │   ├── users/            — User profiles, roles
  │   ├── profiles/         — Provider profiles, addresses
  │   ├── services/         — Listings, bookings, availability, reviews
  │   ├── payments/         — PayMongo, payment methods
  │   ├── disputes/         — Booking dispute flow
  │   ├── earnings/         — Provider earnings, payouts
  │   ├── notifications/    — Push + in-app notifications
  │   ├── favorites/        — Saved services
  │   ├── kyc/              — KYC identity verification
  │   ├── chat/             — Chat (MongoDB), WebSocket consumers
  │   ├── analytics/        — Platform analytics
  │   ├── recommendations/  — AI service recommendations
  │   ├── locations/        — PSGC provinces/cities/barangays
  │   └── pages/            — Wagtail CMS pages

shph-app/ (Vue 3 + Ionic frontend)
  ├── src/
  │   ├── views/            — Pages (auth, services, provider, admin, chat, kyc)
  │   ├── stores/           — Pinia stores (auth, chat, services, etc.)
  │   ├── services/         — API, WebSocket, WebRTC, Firebase, PWA
  │   ├── components/       — Shared UI components
  │   ├── composables/      — Vue composables (useFocusBlur, useAuthPrompt, etc.)
  │   ├── router/           — Vue Router with guards
  │   └── utils/            — Formatters, constants
```

### Mobile App (SerbisyoPH — this repo)

```
lib/ (Flutter frontend)
  ├── main.dart             — App entry point
  ├── app_state.dart        — Global state (FFAppState)
  ├── router/               — GoRouter configuration
  ├── api/                  — REST API client (Dio) — currently disabled
  ├── auth/                 — Supabase auth providers
  ├── backend/supabase/     — Supabase integration (primary data layer)
  ├── pages/                — Screen implementations (103 items)
  ├── services/             — Business logic (18 items)
  ├── components/           — Shared widgets
  └── theme/                — App theme

backend/ (Node.js Express)
  ├── src/
  │   ├── routes/           — API routes (auth, users, chat, services)
  │   ├── middleware/       — Auth, error handling
  │   └── db/               — TypeORM data source & entities
  └── aws/                  — ECS Fargate deployment

supabase/                   — Supabase config & edge functions
firebase/                   — Firebase Cloud Functions & FCM
```

---

## 3. Feature Mapping: Web → Mobile

### Features Already Ported to Flutter

| Feature | Web App Location | Mobile App Location | Status |
|---------|-----------------|---------------------|--------|
| **Auth (Email/Password)** | `views/auth/LoginPage.vue` | `lib/pages/sign_in/` | ✅ Done |
| **Google Sign-In** | `stores/auth.ts` | `lib/auth/supabase_auth/` | ✅ Done |
| **Onboarding** | `views/auth/OnboardingPage.vue` | `lib/pages/onboarding/` | ✅ Done |
| **Profile Creation** | `views/auth/CreateProfilePage.vue` | `lib/pages/create_profile/` | ✅ Done |
| **Home/Explore** | `views/services/HomePage.vue` | `lib/main/home/` | ✅ Done |
| **Categories** | `views/services/CategoriesPage.vue` | `lib/main/category/` | ✅ Done |
| **Service Detail** | `views/services/ServiceDetailPage.vue` | `lib/pages/service_details/` | ✅ Done |
| **Search** | `views/services/SearchPage.vue` | `lib/services/search_service.dart` | ✅ Done |
| **Booking Flow** | `views/services/BookingDetailPage.vue` | `lib/pages/booking_funnel/` | ✅ Done |
| **Chat** | `views/chat/ChatPage.vue` + `stores/chat.ts` | `lib/services/chat_service.dart` | ✅ Done |
| **Reviews** | `components/ReviewCard.vue` + `ReviewForm.vue` | `lib/services/reviews_service.dart` | ✅ Done |
| **Favorites** | `views/services/FavoritesPage.vue` | `lib/services/favorites_service.dart` | ✅ Done |
| **Pro Dashboard** | `views/provider/ProviderDashboardPage.vue` | `lib/main/pro_dashboard/` | ✅ Done |
| **EKYC/Verification** | `views/kyc/` | `lib/pages/pro_verification/` | ✅ Done |
| **On-Demand/Dispatch** | `views/services/OnDemandBookingPage.vue` | `lib/pages/dispatch/` | ✅ Done |
| **TM Flow (Time & Material)** | N/A (web-only feature) | `lib/pages/tm_flow/` | ✅ Done |
| **Notifications** | `stores/notifications.ts` | Hardcoded count (`home_model.dart:34`) | ⚠️ Partial |

### Features NOT Yet Ported (Web has, Mobile doesn't)

| Feature | Web App Location | Priority | Notes |
|---------|-----------------|----------|-------|
| **Payments (PayMongo)** | `shph-api/payments/`, `views/profile/PaymentMethodsPage.vue` | High | No payment integration in mobile at all |
| **Disputes** | `shph-api/disputes/`, `views/profile/DisputesPage.vue` | Medium | No dispute flow in mobile |
| **Earnings/Payouts** | `shph-api/earnings/`, `views/provider/EarningsPage.vue` | High | Pro dashboard shows hardcoded data |
| **Video Calls (WebRTC)** | `services/webrtcService.ts`, `stores/webrtc.ts` | Medium | No video call support in mobile |
| **AI Recommendations** | `services/recommendations.ts`, `stores/recommendations.ts` | Medium | No recommendation engine in mobile |
| **Analytics Dashboard** | `views/provider/ProviderAnalyticsPage.vue`, `components/analytics/` | Medium | No analytics in mobile |
| **Provider Availability** | `views/provider/ProviderAvailabilityPage.vue` | Medium | No availability scheduling in mobile |
| **Addresses CRUD** | `views/profile/AddressesPage.vue`, `AddressFormPage.vue` | Medium | Only 1 direct Supabase query, no full CRUD |
| **Notification Preferences** | `views/profile/NotificationPreferencesPage.vue` | Low | No notification settings in mobile |
| **Session Management** | `views/profile/SessionsPage.vue` | Low | No session management UI in mobile |
| **Admin Dashboard** | `views/admin/` | Low | No admin panel in mobile |
| **CMS Pages** | `shph-api/pages/` | Low | No CMS in mobile |
| **Audit Logs** | `shph-api/` | Low | No audit trail in mobile |
| **PWA/Offline Support** | `services/pwa/offlineManager.ts` | Low | Flutter has inherent offline capability |
| **Biometric Auth (WebAuthn)** | `views/auth/BiometricSetupPage.vue` | Medium | ML Kit face detection exists but no WebAuthn |
| **Dark Mode** | Web app supports it | Low | Flutter theme supports it but not toggled |
| **Guest Browsing** | Web app allows public routes | Low | Mobile requires auth first |

---

## 4. Backend Architecture Differences

### Web App Backend (Django)

| Aspect | Details |
|--------|---------|
| **Framework** | Django 6 + DRF + Wagtail 7 |
| **Database** | PostgreSQL (default) + MongoDB via Djongo (nosql) |
| **Database Router** | `shph.dbrouter.NoSqlRouter` — routes chat models to MongoDB |
| **Realtime** | Django Channels + Redis + WebSocket |
| **Auth** | JWT + Firebase Admin SDK + WebAuthn |
| **Payments** | PayMongo integration (cards, 3D Secure) |
| **API Spec** | Full OpenAPI spec (~200 endpoints) |
| **Admin** | Wagtail CMS + Django admin |
| **Testing** | Django test runner + Pyright |
| **Linting** | Ruff |

### Mobile App Backend (Node.js + Supabase)

| Aspect | Details |
|--------|---------|
| **Framework** | Express.js + TypeORM |
| **Database** | PostgreSQL via Supabase |
| **Realtime** | Supabase Realtime (Postgres changes) |
| **Auth** | Supabase Auth (Google, Apple, email/password) |
| **API** | ~22 backend routes implemented (vs ~200 in web spec) |
| **Primary Data** | 62+ direct Supabase queries from Flutter (bypasses API) |
| **API Status** | `ApiConfig.preferShphApi = false` — entire API layer is dead code |
| **Storage** | Supabase Storage (profile photos, documents) |
| **Cache** | Redis (ioredis) |
| **Deployment** | AWS ECS Fargate (Docker → ECR → ECS) |

### Key Backend Difference

The web app has a **complete Django backend** with ~200 API endpoints covering all features. The mobile app has a **Node.js Express backend with only ~22 routes** implemented, and the Flutter app primarily talks to **Supabase directly** (62+ direct queries). The SHPH REST API layer exists in the Flutter app but is disabled.

---

## 5. Data Model Comparison

### Shared Tables (Both repos use these)

| Table | Web (Django Model) | Mobile (Supabase Table) | Differences |
|-------|-------------------|------------------------|-------------|
| `users` / `profiles` | `User` model with `is_provider`, `is_client` | `profiles` table with `role`, `verification_status` | Web uses boolean role flags; mobile uses string role |
| `service_listings` | `ServiceListing` model | `service_listings` table | Web has `images`, `latitude`, `longitude`, `city`, `province` — mobile misses these |
| `bookings` | `ServiceBooking` (string ID, ObjectId) | `bookings` (UUID) | Web uses string booking IDs; mobile uses UUID |
| `reviews` | `Review` model with `provider_reply` | `reviews` table | Web has provider reply fields — mobile doesn't |
| `categories` | `Category` with `slug`, `icon`, `image`, `description` | `categories` table | Web has richer category metadata |
| `chat` | MongoDB (ChatThread, ChatMessage, VideoCall) | Supabase (`chat_rooms`, `chat_messages`) | Web uses MongoDB; mobile uses Postgres |
| `favorites` | `Favorite` model | `favorites` table | Similar |
| `notifications` | `Notification` model (21 endpoints) | `notifications` table (hardcoded count) | Web has full notification system |
| `payments` | `Payment` model (PayMongo) | Not implemented | Mobile has no payments |
| `disputes` | `Dispute` model | Not implemented | Mobile has no disputes |
| `earnings` | `EarningsTransaction`, `PayoutRequest` | Not implemented | Mobile has no earnings |
| `kyc` | `KycSubmission` model | `profiles.verification_status` | Mobile uses profile fields instead of separate table |
| `addresses` | `Address` model | `addresses` table | Mobile has minimal address support |

### Web-Only Tables (No mobile equivalent)

| Table | Purpose |
|-------|---------|
| `ProviderAvailability` | Provider work schedule / time slots |
| `VideoCall` | Video call records |
| `ApiRequestLog` | API request logging (MongoDB) |
| `NotificationPreferences` | Per-user notification settings |
| `PaymentMethod` | Stored payment methods |
| Wagtail CMS pages | Static content management |

---

## 6. State Management Mapping

| Concern | Web (Pinia Store) | Mobile (Flutter) |
|---------|-------------------|------------------|
| **Auth/Session** | `stores/auth.ts` | `lib/app_state.dart` (FFAppState) + `lib/auth/` |
| **Chat** | `stores/chat.ts` (messages, threads, WS state) | `lib/services/chat_service.dart` (direct Supabase) |
| **Services/Bookings** | `stores/services.ts` | `lib/services/bookings_service.dart` + `pro_bookings_service.dart` |
| **Favorites** | `stores/favorites.ts` | `lib/services/favorites_service.dart` |
| **Notifications** | `stores/notifications.ts` | Hardcoded in `home_model.dart` |
| **Recommendations** | `stores/recommendations.ts` | Not implemented |
| **WebRTC/Video** | `stores/webrtc.ts` | Not implemented |
| **KYC** | `stores/kyc.ts` | `lib/pages/pro_verification/` (page-level state) |

---

## 7. Porting Strategy

### When porting a feature from web to mobile:

1. **Identify the web feature source** — Check `PROJECT_INDEX.md` in the web repo for file locations
2. **Map the data model** — Compare Django models to Supabase tables, note missing fields
3. **Map the API endpoints** — Check `SHPH API.yaml` for the OpenAPI spec, then check `docs/api_gaps.md` for what's missing in the mobile backend
4. **Implement in Flutter** — Follow patterns in `AI_DEVELOPMENT_PROMPT.md`:
   - Create page widget in `lib/pages/`
   - Add `routeName` and `routePath`
   - Register route in `app_router.dart`
   - Export in `index.dart`
   - Add service in `lib/services/` if needed
   - Add Supabase queries or API calls
5. **Test both flows** — Client and provider perspectives

### Key Considerations

- **Direct Supabase vs API**: The mobile app currently bypasses the Express API and talks to Supabase directly. When porting, decide whether to add API endpoints or continue with direct Supabase queries.
- **Booking ID type**: Web uses string IDs (ObjectId); mobile uses UUID. Ensure type consistency.
- **Role model**: Web uses `is_provider`/`is_client` booleans; mobile uses `role` string field. Map appropriately.
- **Chat backend**: Web uses MongoDB via Djongo; mobile uses Supabase Postgres. Different query patterns.
- **Payments**: Web has full PayMongo integration; mobile needs this built from scratch.
- **Realtime**: Web uses Django Channels + WebSocket; mobile uses Supabase Realtime. Different subscription patterns.

---

## 8. Quick Reference: Web Repo File Locations

When looking for a feature in the web app:

| What You Need | Where to Look |
|---------------|--------------|
| Backend API endpoint | `shph-api/src/shph/<app>/views.py` |
| Backend data model | `shph-api/src/shph/<app>/models.py` |
| Backend serializer | `shph-api/src/shph/<app>/serializers.py` |
| Frontend page | `shph-app/src/views/<section>/<Name>Page.vue` |
| Frontend state | `shph-app/src/stores/<domain>.ts` |
| Frontend service | `shph-app/src/services/<name>.ts` |
| Frontend component | `shph-app/src/components/<Name>.vue` |
| Frontend composable | `shph-app/src/composables/use<Name>.ts` |
| API spec | `SHPH API.yaml` (in mobile repo root) |
| Feature flowcharts | `FLOWCHARTS.md` (in web repo root) |
| Full file index | `PROJECT_INDEX.md` (in web repo root) |
| Agent quick ref | `AGENTS.md` (in web repo root) |
| Cursor rules | `.cursorrules` (in web repo root) |

---

## 9. Skill Workflows (Deep-Dive Porting Guides)

Detailed skill workflows have been created in `.devin/workflows/` for each feature that needs to be ported. Each workflow contains: the web app's implementation details (models, views, UI), what the mobile app needs (SQL migrations, Flutter services, UI pages), and key differences between the two platforms.

| Feature | Workflow File | Priority | Dependencies |
|---------|--------------|----------|-------------|
| **Payments (PayMongo)** | `.devin/workflows/payments-port.md` | High | None (foundational) |
| **Earnings & Payouts** | `.devin/workflows/earnings-payouts-port.md` | High | Payments (earnings credited on payment confirm) |
| **Disputes** | `.devin/workflows/disputes-port.md` | High | Bookings (disputes linked to bookings) |
| **Notifications** | `.devin/workflows/notifications-port.md` | High | Firebase FCM (already configured) |
| **Video Calls (WebRTC)** | `.devin/workflows/video-calls-port.md` | High | Chat (calls initiated from chat) |
| **AI Recommendations** | `.devin/workflows/recommendations-port.md` | Medium | Service listings, user interactions |
| **Provider Analytics** | `.devin/workflows/analytics-port.md` | Medium | Bookings, earnings, reviews |
| **Provider Availability** | `.devin/workflows/availability-port.md` | Medium | None (standalone CRUD) |
| **Addresses CRUD** | `.devin/workflows/addresses-port.md` | Medium | Google Maps (already integrated) |
| **Wallet** | `.devin/workflows/wallet-port.md` | Medium | Payments (shares PayMongo integration) |

### Recommended Implementation Order

1. **Payments** — foundational, needed by earnings & wallet
2. **Notifications** — replaces hardcoded count, needed by all features
3. **Earnings & Payouts** — depends on payments
4. **Disputes** — standalone, linked to bookings
5. **Addresses** — standalone, improves booking flow
6. **Provider Availability** — standalone CRUD
7. **Provider Analytics** — depends on earnings + bookings data
8. **AI Recommendations** — depends on user interaction tracking
9. **Video Calls** — complex, depends on chat + WebRTC
10. **Wallet** — depends on payments, lowest priority

---

## 10. Open Questions / Decisions Needed

1. **API Strategy**: Should the mobile app continue with direct Supabase queries, or should we build out the Express API to match the Django backend's ~200 endpoints?
2. **Payment Gateway**: Should the mobile app use PayMongo (like web) or a different gateway (GCash, Maya)?
3. **Chat Backend**: Should the mobile app keep using Supabase Postgres for chat, or migrate to MongoDB to match the web app?
4. **Video Calls**: Should we use WebRTC directly in Flutter, or use a Flutter package like `flutter_webrtc`?
5. **Recommendations**: Should the AI recommendation engine be ported as-is (TypeScript ML), or reimplemented in Dart?
6. **Admin Panel**: Should the mobile app have an admin panel, or should admins use the web app?
