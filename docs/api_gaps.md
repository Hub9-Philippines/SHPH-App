# SHPH API — Complete Gap Analysis

> **Date:** 2026-06-29  
> **Scope:** `SHPH API.yaml` (OpenAPI spec) vs Flutter app (`lib/`) vs Backend (`backend/`)

---

## 1. Critical Structural Issues

### 1.1 API Layer Is Dead Code

**`lib/api/api_config.dart:29`** — `preferShphApi` is hardcoded to `false`. Every service has an "SHPH API try / fallback to Supabase" pattern but the first branch is **never executed**. The entire `lib/api/` directory (~15 Dart files) is dead code.

### 1.2 Massive Endpoint Coverage Gap

| Layer | Auth | Services | Chat | Users | Bookings | Favorites | KYC | Other | **Total** |
|-------|------|----------|------|-------|----------|-----------|-----|-------|-----------|
| **YAML spec endpoints** | ~30 | ~36 | ~20 | ~17 | ~15 | ~4 | ~6 | ~72 | **~200** |
| **Dart client methods** | 10 | 6 | 7 | 4 | 7 | 3 | 2 | 0 | **~39** |
| **Backend routes** | 6 | 6 | 6 | 4 | 0 | 0 | 0 | 0 | **~22** |

- **~180 of ~200 YAML endpoints** have no Dart API resource implementation
- **~180 of ~200 YAML endpoints** have no backend route implementation
- **62+ direct Supabase queries** in the Flutter app bypass the API entirely

### 1.3 Schema Model Coverage

- **8 of 44 YAML schemas** have Dart model classes (18%)
- The other 36 schemas use raw `Map<String, dynamic>` everywhere

---

## 2. Dart Model Field Gaps (YAML has fields, Dart models don't)

### `ShphServiceListing` — `lib/api/models/service_listing.dart`

| Missing Field | YAML Source | Type |
|---------------|-------------|------|
| `images` | `ServiceListing.images` (:5046-5048) | `string` (readOnly) |
| `latitude` | `ServiceListing.latitude` (:5052-5062) | `double?` (writable) |
| `longitude` | `ServiceListing.longitude` (:5063-5070) | `double?` (writable) |
| `_is_available_write` | `ServiceListing._is_available_write` (:5031-5038) | `boolean` (writeOnly) |

### `ShphBooking` — `lib/api/models/booking.dart`

| Missing Field | YAML Source | Type |
|---------------|-------------|------|
| `client` | `Booking.client` (:3929-3931) | `int` (readOnly) |
| `provider_lat` | `Booking.provider_lat` (:3970-3977) | `double?` |
| `provider_lng` | `Booking.provider_lng` (:3979-3985) | `double?` |
| `has_review` | `Booking.has_review` (:3986-3988) | `string` (readOnly) |
| `payment_confirmed` | `Booking.payment_confirmed` (:3989-3991) | `string` (readOnly) |

### `ShphReview` — `lib/api/models/review.dart`

| Missing Field | YAML Source | Type |
|---------------|-------------|------|
| `booking` | `Review.booking` (:4955-4957) | `string` (readOnly) |
| `provider_reply` | `Review.provider_reply` (:4974-4976) | `string` |
| `provider_reply_at` | `Review.provider_reply_at` (:4977-4980) | `date-time?` |

---

## 3. ApiRowMapper Field Gaps (`lib/api/bridges/api_row_mapper.dart`)

### `bookingToRow()` (:33-62)

| Not Mapped | API Field | Supabase Row Field |
|------------|-----------|--------------------|
| `agreed_price` | `booking.agreedPrice` | N/A |
| `provider_lat` | `booking.providerLat` | N/A |
| `provider_lng` | `booking.providerLng` | N/A |
| `has_review` | `booking.hasReview` | N/A |
| `payment_confirmed` | `booking.paymentConfirmed` | N/A |
| `scheduled_at` | `booking.scheduledAt` | N/A |

### `serviceListingToRow()` (:64-83)

| Not Mapped | API Field | Supabase Row Field |
|------------|-----------|--------------------|
| `images` | `listing.images` | N/A |
| `latitude` | `listing.latitude` | N/A |
| `longitude` | `listing.longitude` | N/A |
| `city` | `listing.city` | N/A |
| `province` | `listing.province` | N/A |

### `categoryToRow()` (:86-97)

| Not Mapped | API Field | Supabase Row Field |
|------------|-----------|--------------------|
| `slug` | `category.slug` | N/A |

### `reviewToRow()` (:99-116)

| Not Mapped | API Field | Supabase Row Field |
|------------|-----------|--------------------|
| `booking` | `review.booking` | N/A |
| `provider_reply` | `review.providerReply` | N/A |
| `provider_reply_at` | `review.providerReplyAt` | N/A |

### `profileToRow()` (:118-136)

Maps basic profile fields. Does **NOT** map `latitude`, `longitude`, or `skill_profession` — even though `ProfilesRow` (`lib/backend/supabase/database/tables/profiles.dart`) has those fields.

---

## 4. Missing API Resource Endpoints (YAML exists, Dart client missing)

### Auth (`lib/api/resources/auth_api.dart`) — 10 of ~30 implemented

| Missing Endpoint | YAML Line |
|------------------|-----------|
| `POST /api/auth/register/` | :546-557 |
| `POST /api/auth/register/resend/` | :573-585 |
| `POST /api/auth/otp/send/` (non-pin) | :465-475 |
| `POST /api/auth/otp/verify/` (non-pin) | :492-502 |
| Biometric endpoints (8 endpoints) | :231-390 |
| Session management (4 endpoints) | :599-654 |
| Social auth (Google) | :655-668 |

### Services (`lib/api/resources/services_api.dart`) — 6 of ~36 implemented

| Missing Endpoint | YAML Line |
|------------------|-----------|
| `PUT /api/services/listings/{id}/` | :3243-3274 |
| `DELETE /api/services/listings/{id}/` | :3306-3321 |
| `POST /api/services/listings/{id}/thumbnail/` | :3352-3370 |
| Availability CRUD + slots (7 endpoints) | :2617-2804 |
| `POST /api/services/bookings/estimate/` | :3063-3078 |
| `POST /api/services/bookings/{id}/reschedule/` | :3002-3029 |
| `POST /api/services/bookings/{id}/review/` | :3030-3062 |
| `PATCH /api/services/bookings/{id}/location/` | :2960-2980 |
| On-demand endpoints (4 endpoints) | :3427-3494 |
| `POST /api/services/reviews/{id}/reply/` | :3495-3515 |

### Users (`lib/api/resources/users_api.dart`) — 4 of ~17 implemented

| Missing Endpoint | YAML Line |
|------------------|-----------|
| `POST /api/users/apply-provider/` | :3516-3528 |
| `POST /api/users/enable-client/` | :3529-3541 |
| Notification preferences (3 endpoints) | :3602-3651 |
| Payment methods (5 endpoints) | :3665-3739 |
| User create/update variants | :3554-3564 |

### Bookings (`lib/api/resources/bookings_api.dart`) — 7 of ~15 implemented

| Missing Endpoint | YAML Line |
|------------------|-----------|
| `PUT /api/services/bookings/{id}/` | :2874-2905 |
| `POST /api/services/bookings/list/` (POST variant) | :3103-3130 |

### Chat (`lib/api/resources/chat_api.dart`) — 7 of ~20 implemented

| Missing Endpoint | YAML Line |
|------------------|-----------|
| Thread CRUD (3 endpoints) | :822-903 |
| Message edit/delete/typing/upload (4 endpoints) | :967-1093 |
| Video calls (6 endpoints) | :681-786 |

### KYC (`lib/api/resources/kyc_api.dart`) — 2 of ~6 implemented

| Missing Endpoint | YAML Line |
|------------------|-----------|
| Admin KYC CRUD + actions (4 endpoints) | :1594-1666 |

### Entire API Categories With Zero Dart Implementation

| Category | Endpoints | YAML Lines |
|----------|-----------|------------|
| **Analytics** | 5 | :124-230 |
| **Disputes** | 10 | :1128-1353 |
| **Earnings / Payouts** | 8 | :1420-1530 |
| **Locations** (provinces/cities/barangays) | 3 | :1700-1760 |
| **Notifications** | 21 | :1761-2250 |
| **Payments** | 5 | :2251-2328 |
| **Profiles / Addresses** | 9 | :3640-3740 |
| **Providers** (public profile, incentives) | 6 | :2334-2430 |
| **Recommendations** | 13 | :2431-2620 |
| **Admin** | 10 | :1-123 |
| **CMS Pages** | 1 | :1690-1700 |
| **Audit** | 1 | :421-430 |
| **Logs** | 1 | :431-440 |

---

## 5. Direct Supabase Queries Bypassing the API

### Bookings — 16 direct queries

| File:Line | Table | Operation |
|-----------|-------|-----------|
| `lib/pages/tm_flow/tm_repository.dart:445` | `bookings` | realtime stream |
| `lib/pages/dispatch/dispatch_repository.dart:544` | `bookings` | realtime stream |
| `lib/pages/booking_funnel/booking_repository.dart:59` | `bookings` | INSERT |
| `lib/services/bookings_service.dart:49` | `bookings` | INSERT |
| `lib/services/bookings_service.dart:91,124` | `bookings` | SELECT |
| `lib/services/bookings_service.dart:155,186` | `bookings` | UPDATE |
| `lib/services/bookings_service.dart:209` | `bookings` | UPDATE (cancel) |
| `lib/services/bookings_service.dart:237` | `bookings` | SELECT |
| `lib/services/pro_bookings_service.dart:126,172,213,549,591` | `bookings` | SELECT |
| `lib/services/pro_bookings_service.dart:611` | `bookings` | UPDATE |

### Chat — 11 direct queries

| File:Line | Table | Operation |
|-----------|-------|-----------|
| `lib/services/chat_service.dart:39,98,130,184,194,223,243` | `chat_rooms` | SELECT / INSERT |
| `lib/services/chat_service.dart:68` | `chat_messages` | SELECT |
| `lib/services/chat_service.dart:108` | `chat_messages` | INSERT |
| `lib/services/chat_service.dart:114` | `chat_rooms` | UPDATE |
| `lib/services/chat_service.dart:161` | `chat_messages` | UPDATE |

### Dispatch / On-Demand — 13 direct queries (NO API exists for this)

| File:Line | Table | Operation |
|-----------|-------|-----------|
| `lib/pages/dispatch/dispatch_repository.dart:105` | `job_requests` | INSERT |
| `lib/pages/dispatch/dispatch_repository.dart:206` | `job_requests` | SELECT |
| `lib/pages/dispatch/dispatch_repository.dart:384,411` | `job_requests` | UPDATE |
| `lib/services/dispatch/dispatch_service.dart:40` | `job_requests` | INSERT |
| `lib/services/dispatch/dispatch_service.dart:76` | `job_requests` | STREAM |
| `lib/services/dispatch/dispatch_service.dart:91,232` | `dispatch_offers` | SELECT |
| `lib/services/dispatch/dispatch_service.dart:120` | `dispatch_offers` | STREAM |
| `lib/services/dispatch/dispatch_service.dart:133,196,212` | `job_requests` | SELECT / UPDATE |
| `lib/services/dispatch/dispatch_service.dart:101` | `profiles` | SELECT |

### Profiles — 7 direct queries

| File:Line | Table | Operation |
|-----------|-------|-----------|
| `lib/pages/tm_flow/tm_repository.dart:539` | `profiles` | SELECT (provider search) |
| `lib/pages/dispatch/dispatch_repository.dart:591,744` | `profiles` | SELECT |
| `lib/services/profiles_service.dart:33` | `profiles` | SELECT |
| `lib/services/profiles_service.dart:60,131` | `profiles` | UPDATE |
| `lib/pages/create_profile/create_profile_widget.dart:129` | `profiles` | SELECT |

### Service Listings — 4 direct queries

| File:Line | Table | Operation |
|-----------|-------|-----------|
| `lib/pages/booking_details/booking_details_widget.dart:63` | `service_listings` | SELECT |
| `lib/services/search_service.dart:28,60,90` | `service_listings` | SELECT |
| `lib/services/categories_service.dart:70` | `service_listings` | SELECT |

### Reviews — 7 direct queries

| File:Line | Table | Operation |
|-----------|-------|-----------|
| `lib/services/reviews_service.dart:24,58,76,97,107,121,156` | `reviews` | INSERT / SELECT / UPDATE / DELETE |

### Favorites — 4 direct queries

| File:Line | Table | Operation |
|-----------|-------|-----------|
| `lib/services/favorites_service.dart:32,63,94,126` | `favorites` | INSERT / DELETE / SELECT |

### Categories — 1 direct query

| File:Line | Table | Operation |
|-----------|-------|-----------|
| `lib/services/categories_service.dart:28` | `categories` | SELECT |

---

## 6. Backend Entity Gaps (TypeORM vs YAML Schema)

### `User` entity — Missing fields

| Missing Field | YAML Schema |
|---------------|-------------|
| `phone_number` | `User` has neither `phone` nor `phone_number` |
| `skill_profession` | Not in `User` schema (used by providers) |
| `latitude` | Not in `User` schema |
| `longitude` | Not in `User` schema |
| `location` (PostGIS) | Not in `User` schema |
| `id_document_url` | Not in `User` schema |

### `ServiceListing` entity — Missing fields

| Missing Field | YAML Schema |
|---------------|-------------|
| `category_name` | `ServiceListing.category_name` (:5000-5004) |
| `provider_name` | `ServiceListing.provider_name` (:5008-5009) |
| `provider_photo` | `ServiceListing.provider_photo` (:5011-5014) |
| `rating` | `ServiceListing.rating` (:5039-5041) |
| `review_count` | Not in YAML but used in Flutter |
| `images` | `ServiceListing.images` (:5046-5048) |
| `city` | `ServiceListing.city` (:5049-5051) |
| `province` | `ServiceListing.province` (:5052-5054) |
| `latitude` | `ServiceListing.latitude` (:5055-5062) |
| `longitude` | `ServiceListing.longitude` (:5063-5070) |
| `is_time_material` | Not in YAML but used in Flutter (`ServiceListing.isTimeMaterial`) |
| `created_at` | `ServiceListing.created_at` (:5071-5074) |

### `Category` entity — Missing fields

| Missing Field | YAML Schema |
|---------------|-------------|
| `slug` | `Category.slug` |
| `icon` | `Category.icon` |
| `image` | `Category.image` |
| `description` | `Category.description` |

### Missing Entire Entities

| Entity | Purpose | YAML Schema |
|--------|---------|-------------|
| `Address` | User saved addresses | `Address` (:3750-3783) |
| `Dispute` | Booking disputes | `Dispute` |
| `EarningsTransaction` | Provider earnings | `EarningsTransaction` |
| `PayoutRequest` | Payout requests | `PayoutRequest` (:4872-4906) |
| `ProviderAvailability` | Provider work schedule | `ProviderAvailability` (:4907-4929) |
| `KycSubmission` | KYC documents | `AdminKycSubmission` (:3786-3849) |
| `Notification` | User notifications | Not defined separately |
| `Payment` | Payment records | Not defined separately |
| `VideoCall` | Video call records | `VideoCall` (:5156-5211) |

---

## 7. Entire Feature Domains Missing from Both Dart and Backend

| Domain | YAML Endpoints | Flutter Supabase Queries | Notes |
|--------|---------------|-------------------------|-------|
| **Payments** | 5 | 0 | No payment integration at all |
| **Disputes** | 10 | 0 | No dispute flow |
| **Earnings/Payouts** | 8 | 0 | Pro dashboard shows hardcoded data |
| **Notifications** | 21 | 0 | Count hardcoded to `2` (`home_model.dart:34`) |
| **Analytics** | 5 | 0 | No analytics |
| **Recommendations** | 13 | 0 | No recommendations |
| **Provider Profiles** | 6 | 7 (Supabase direct) | Provider search bypasses API entirely |
| **Addresses** | 9 | 1 (Supabase direct) | Address update bypasses API |
| **On-Demand Dispatch** | 4 | 13 (Supabase direct) | Entire dispatch system bypasses API |
| **Profiles CRUD** | 9 | 4 (Supabase direct) | Profile reads/updates bypass API |

---

## 8. TODO Comments About Missing Features

| File:Line | Comment |
|-----------|---------|
| `lib/main/home/home_model.dart:32` | `// TODO: Replace with actual database query when notifications table is available` |
| `lib/services/logging_service.dart:118` | `// TODO: Integrate with crash reporting service` |
| `lib/pages/pro_verification/verification_reviewing_widget.dart:284` | `// TODO: Navigate to support` |

---

## 9. Summary of Key Gaps for "Find Nearby Pro"

The feature that triggered this analysis — finding the nearest provider — has these specific gaps:

1. **No `/api/providers/nearby/` endpoint** — the app queries `profiles` table directly from Supabase (`tm_repository.dart:539`)
2. **`ShphServiceListing` misses `latitude`/`longitude`** — the YAML schema has them but the Dart model doesn't
3. **`ShphBooking` misses `provider_lat`/`provider_lng`** — the YAML schema has them but the Dart model doesn't
4. **`ApiRowMapper.profileToRow()` doesn't map lat/lng** — even though `ProfilesRow` has those fields
5. **`ServiceListing` backend entity has no lat/lng** — no provider service area concept exists
6. **No distance-based querying anywhere in the API** — no `?lat=&lng=&radius=` filter
7. **`ApiConfig.preferShphApi` is `false`** — even if endpoints existed, the app wouldn't call them
8. **No `ProviderProfile` schema in YAML** — no dedicated provider profile with location exists in the API spec
