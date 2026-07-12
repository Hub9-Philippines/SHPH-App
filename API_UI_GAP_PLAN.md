# SHPH API → UI Gap Analysis & Implementation Plan

**Context:** The codebase is migrating from direct Supabase calls to the SHPH Django API. Many API methods are fully
implemented in `lib/api/resources/` but have no UI binding. This plan maps every unused method to the specific page or
widget that should call it.

---

## 1. Auth API (19 unused)

### 1.1 Email Registration OTP Flow (`registerVerify`, `registerResend`)

| Method | UI Target | Priority |
|---|---|---|
| `registerVerify` | **New page:** `email_verify_register` — OTP input after `registerInitiate` | P0 |
| `registerResend` | "Resend code" button on `email_verify_register` | P0 |

**Pages to create:**
- `lib/pages/email_verify_register/email_verify_register_widget.dart`
- `lib/pages/email_verify_register/email_verify_register_model.dart`

**Pages to modify:**
- `lib/pages/signup/signup_widget.dart` — after `registerInitiate` succeeds, navigate to
  `email_verify_register` instead of `PhoneVerifyUserWidget`
- `lib/router/app_router.dart` — add route `/email-verify-register`

**Flow:**
`SignupWidget (fills email/password)` → `registerInitiate` → `EmailVerifyRegisterWidget (enter OTP)` →
`registerVerify` → `CreateProfileWidget`

### 1.2 Direct Registration (`register`)

| Method | UI Target | Priority |
|---|---|---|
| `register` | **Modification:** `SignupWidget` — add "Register" toggle (one-step vs two-step) | P2 |

**Flow:**
Same signup form; user toggles "one-step" mode → calls `register` directly → skips OTP → `CreateProfileWidget`

### 1.3 Firebase OTP (`sendOtp`, `verifyOtp`)

| Method | UI Target | Priority | Status |
|---|---|---|---|
| `sendOtp` / `verifyOtp` | **Modification:** `PhoneVerifyUserWidget` — alternative to `send-pin/verify-pin` | P1 | ⬜ Requires Firebase SDK setup |
| `sendPhoneLoginOtp` / `verifyPhoneLoginOtp` | **Modification:** `SigninWidget` — phone tab now calls SHPH API directly | P1 | ✅ Done |

**Flow for phone login:**
`SigninWidget (phone tab)` → `sendPhoneLoginOtp` → OTP dialog → `verifyPhoneLoginOtp` → Home

### 1.4 Google Sign-In (`socialGoogle`)

| Method | UI Target | Priority | Status |
|---|---|---|---|
| `socialGoogle` | **Modification:** `SignOptionsWidget` — replace Supabase OAuth flow with SHPH-native Google login | P1 | ✅ Done via `authManager` |

**Flow:**
`SignOptionsWidget (Google button)` → `authManager.signInWithGoogle()` → `ShphAuthApi.socialGoogle()` → Home

### 1.5 Supabase Session Migration (`supabaseExchange`)

| Method | UI Target | Priority | Status |
|---|---|---|---|
| `supabaseExchange` | **Modification:** `SplashWidget` — call on first launch if existing Supabase session detected | P1 | ✅ Done |

**Flow:**
`SplashWidget` → detects Supabase session → `supabaseExchange(accessToken)` → migrate tokens → navigate normally

### 1.6 Current User Refresh (`getCurrentUser`)

| Method | UI Target | Priority |
|---|---|---|
| `getCurrentUser` | **Modification:** `SettingsWidget` and `EditProfileWidget` — add "Refresh profile" action | P2 |

### 1.7 Skip KYC (`skipKyc`)

| Method | UI Target | Priority |
|---|---|---|
| `skipKyc` | **Modification:** `EKYCBeginWidget` — add "Skip for now" button | P0 |

**Flow:**
`EKYCBeginWidget` → "Skip for now" → `skipKyc()` → Home

### 1.8 Biometric (WebAuthn) (`biometricRegisterOptions/verify`, `biometricAuthOptions/verify`, `biometricListCredentials/deleteCredential`)

| Method | UI Target | Priority |
|---|---|---|
| `biometricRegisterOptions/verify` | **Modification:** `SecuritySettingsWidget` — replace local-only biometric with server-backed WebAuthn enrollment | P2 |
| `biometricAuthOptions/verify` | **Modification:** `SigninWidget` — add "Sign in with biometric" option | P2 |
| `biometricListCredentials/deleteCredential` | **Modification:** `SecuritySettingsWidget` — list enrolled credentials, allow deletion | P2 |

### 1.9 Session Management (`listSessions`, `revokeSession`, `revokeAllSessions`)

| Method | UI Target | Priority | Status |
|---|---|---|---|
| `listSessions` / `revokeSession` / `revokeAllSessions` | **Modification:** `SecuritySettingsWidget` — replace Supabase sessions list with SHPH API sessions | P1 | ✅ Done |

**Flow:**
`SecuritySettingsWidget (Active Sessions section)` → `listSessions()` → display list → swipe/button to
`revokeSession(id)` → "Revoke all" → `revokeAllSessions()`

---

## 2. Bookings API (2 unused)

### 2.1 Price Estimation (`estimateBooking`)

| Method | UI Target | Priority |
|---|---|---|
| `estimateBooking` | **Modification:** `BookingWidget` — call before showing price summary | P0 |

**Flow:**
`BookingWidget (user picks date/time)` → `estimateBooking(listingId, date, time)` → display estimated price → proceed to
`BookingPaymentWidget`

### 2.2 Reschedule (`rescheduleBooking`)

| Method | UI Target | Priority |
|---|---|---|
| `rescheduleBooking` | **Modification:** `BookingDetailsWidget` — add "Reschedule" button | P0 |

**Flow:**
`BookingDetailsWidget` → "Reschedule" → date/time picker → `rescheduleBooking(id, newDate, newTime)` →
refresh details

### 2.3 Review Booking (`reviewBooking`)

| Method | UI Target | Priority |
|---|---|---|
| `reviewBooking` | **New page:** `leave_review` — rating + comment form | P0 |

**Pages to create:**
- `lib/pages/leave_review/leave_review_widget.dart`
- `lib/pages/leave_review/leave_review_model.dart`

**Flow:**
`BookingDetailsWidget (completed booking)` → "Leave Review" → `LeaveReviewWidget` → `reviewBooking(id, rating, comment)`
→ navigate back

### 2.4 Share ETA (`shareEta`)

| Method | UI Target | Priority | Status |
|---|---|---|---|
| `shareEta` | **Modification:** `BookingDetailsWidget` — "Share ETA" button for provider | P1 | ✅ Done |

**Flow:**
`BookingDetailsWidget` → "Share ETA" → provider enters minutes → `shareEta(bookingId, minutes)` → notification to client

### 2.5 Invoice (`getInvoice`)

| Method | UI Target | Priority | Status |
|---|---|---|---|
| `getInvoice` | **Modification:** `BookingDetailsWidget` — "View Invoice" button with AlertDialog | P1 | ✅ Done |

**Flow:**
`BookingDetailsWidget` → "View Invoice" → `getInvoice(bookingId)` → dialog with invoice details

### 2.6 Parts Cost Approval (`approvePartsCost`, `rejectPartsCost`)

| Method | UI Target | Priority |
|---|---|---|
| `approvePartsCost` / `rejectPartsCost` | **New widget / modification:** `BookingDetailsWidget` — show parts cost pending section | P2 |

**Flow:**
Provider submits parts cost → `BookingDetailsWidget` shows "Parts cost: PHP X,XXX — Approve / Reject" →
`approvePartsCost(id)` or `rejectPartsCost(id, reason)`

### 2.7 Completion Photo (`completePhoto`)

| Method | UI Target | Priority |
|---|---|---|
| `completePhoto` | **Modification:** `TMActiveJobScreen` or `BookingDetailsWidget` — "Mark Complete with Photo" button | P1 |

**Flow:**
`TMActiveJobScreen` → "Mark Complete" → camera/gallery picker → `completePhoto(id, fileBytes, fileName)` → booking
status → `completed`

### 2.8 Live Location (`updateBookingLocation`)

| Method | UI Target | Priority |
|---|---|---|
| `updateBookingLocation` | **Modification:** `BookingDetailsWidget` — periodic location updates on map | P2 |

**Flow:**
`BookingDetailsWidget` (provider-side) → periodic GPS → `updateBookingLocation(id, lat, lng)` → client sees live updates

---

## 3. Chat API (11 unused)

### 3.1 Thread Details (`getThreadDetails`)

| Method | UI Target | Priority |
|---|---|---|
| `getThreadDetails` | **Modification:** `ChatPageWidget` — show participants, created date in app bar | P2 |

### 3.2 Direct Thread Creation (`createDirectThread`)

| Method | UI Target | Priority |
|---|---|---|
| `createDirectThread` | **Modification:** `ContactProviderWidget` or `ProductPageWidget` — replace Supabase direct thread creation | P0 |

**Flow:**
`ContactProviderWidget ("Message" button)` → `createDirectThread(participantId)` → navigate to `ChatPageWidget`

### 3.3 Typing Indicator (`sendTypingIndicator`)

| Method | UI Target | Priority |
|---|---|---|
| `sendTypingIndicator` | **Modification:** `ChatPageWidget` — debounced POST on text input change; show dots when peer is typing | P1 |

### 3.4 File Upload (`uploadFile`)

| Method | UI Target | Priority |
|---|---|---|
| `uploadFile` | **Modification:** `ChatPageWidget` — add attach button (gallery, camera, document) | P1 |

### 3.5 Edit/Delete Messages (`editMessage`, `deleteMessage`)

| Method | UI Target | Priority |
|---|---|---|
| `editMessage` / `deleteMessage` | **Modification:** `ChatPageWidget` — long-press context menu on own messages | P1 |

### 3.6 Voice/Video Calls (`initiateCall`, `acceptCall`, `rejectCall`, `endCall`)

| Method | UI Target | Priority |
|---|---|---|
| `initiateCall` | **Modification:** `ChatPageWidget` — phone/video icon in app bar | P2 |
| `acceptCall` / `rejectCall` / `endCall` | **New page / overlay:** `IncomingCallOverlay` + `ActiveCallScreen` | P2 |

**Flow:**
`ChatPageWidget (call button)` → `initiateCall(threadId, "audio|video")` → push notification to peer →
`IncomingCallOverlay (accept/reject)` → `ActiveCallScreen` → `endCall(callId)`

### 3.7 Call History (`listCalls`)

| Method | UI Target | Priority |
|---|---|---|
| `listCalls` | **Existing page:** `CallHistoryDetailsPageWidget` — feed it via API instead of hardcoded data | P2 |

---

## 4. Services API (3 unused — image management)

### 4.1 Create Listing (`createListing`)

| Method | UI Target | Priority |
|---|---|---|
| `createListing` | **Existing page:** `CreateServiceWidget` — already exists, needs to call API | P0 |

**Flow:**
`CreateServiceWidget` → provider fills form → `createListing(payload)` → navigate to `MyServicesWidget`

### 4.2 Subcategory Selector (`listSubcategories`)

| Method | UI Target | Priority |
|---|---|---|
| `listSubcategories` | **Modification:** `CreateServiceWidget` and `BookingWidget` — drill-down category selector | P1 |

### 4.3 Availability CRUD (`listAvailability`, `createAvailability`, `updateAvailability`, `deleteAvailability`)

| Method | UI Target | Priority | Status |
|---|---|---|---|
| `listAvailability` / `createAvailability` / `updateAvailability` / `deleteAvailability` | **New page:** `AvailabilityCalendarWidget` — provider sets weekly schedule | P1 | ✅ Done |

**Flow:**
`MyServicesWidget` → "Schedule" IconButton → `AvailabilityCalendarWidget` → CRUD time slots with calendar UI

### 4.4 Time Slots (`getTimeSlots`)

| Method | UI Target | Priority |
|---|---|---|
| `getTimeSlots` | **Modification:** `BookingWidget` — replace hardcoded time slots with API response | P0 |

**Flow:**
`BookingWidget (user selects date)` → `getTimeSlots(listingId, date)` → render available time slots

### 4.5 Listing Image Management (`uploadListingImage`, `deleteListingImage`, `reorderListingImages`, `setListingThumbnail`)

| Method | UI Target | Priority | Status |
|---|---|---|---|
| `uploadListingImage` | **Modification:** `CreateServiceWidget` — add image picker + upload | P0 | ✅ Done |
| `deleteListingImage` / `reorderListingImages` / `setListingThumbnail` | **Modification:** `CreateServiceWidget` — delete overlay + long-press menu for thumbnail | P1 | ✅ Done |

### 4.6 Archive/Unarchive (`archiveListing`, `unarchiveListing`)

| Method | UI Target | Priority |
|---|---|---|
| `archiveListing` / `unarchiveListing` | **Modification:** `MyServicesWidget` — toggle switch on each listing card | P1 |

### 4.7 ETA (`getEta`)

| Method | UI Target | Priority |
|---|---|---|
| `getEta` | **Modification:** `BookingDetailsWidget` — display ETA from provider | P2 |

### 4.8 Reply to Review (`replyToReview`)

| Method | UI Target | Priority |
|---|---|---|
| `replyToReview` | **Modification:** `ReviewsWidget` — provider can reply to reviews | P1 |

### 4.9 My Reviews (`listMyReviews`)

| Method | UI Target | Priority |
|---|---|---|
| `listMyReviews` | **Existing page:** `MyReviewsWidget` — already exists, needs API migration from Supabase | P1 |

---

## 5. Users API (1 unused — `getCurrentUser`)

### 5.1 Become a Provider (`applyProvider`)

| Method | UI Target | Priority |
|---|---|---|
| `applyProvider` | **Modification:** `ProUnverifiedLandingWidget` or `ProfileWidget` — "Become a Provider" CTA | P0 |

**Flow:**
`ProfileWidget ("Switch to Pro")` → `applyProvider(payload)` → redirect to pro verification flow

### 5.2 Enable Client Mode (`enableClient`)

| Method | UI Target | Priority | Status |
|---|---|---|---|
| `enableClient` | **Modification:** `ProDashboardWidget` — "Switch to Client" button | P1 | ✅ Done |

### 5.3 Phone Change (`initiatePhoneChange`, `verifyPhoneChange`)

| Method | UI Target | Priority | Status |
|---|---|---|---|
| `initiatePhoneChange` / `verifyPhoneChange` | **Modification:** `EditProfileWidget` — phone field with "Change" → OTP verify flow | P2 | ✅ Done |

**Flow:**
`EditProfileWidget ("Change Phone")` → `initiatePhoneChange(newPhone)` → OTP dialog → `verifyPhoneChange(code, session)`

### 5.4 Payment Methods (`listPaymentMethods`, `addPaymentMethod`, `deletePaymentMethod`, `setDefaultPaymentMethod`)

| Method | UI Target | Priority |
|---|---|---|
| `listPaymentMethods` / `addPaymentMethod` / `deletePaymentMethod` / `setDefaultPaymentMethod` | **Existing page:** `PaymentMethodsWidget` — already exists but uses Supabase; migrate to API | P1 |

### 5.5 Notification Preferences (`getNotificationPreferences`, `updateNotificationPreferences`)

| Method | UI Target | Priority |
|---|---|---|
| `getNotificationPreferences` / `updateNotificationPreferences` | **Existing page:** `NotificationPreferencesWidget` — currently uses `NotificationPreferencesService (Supabase)`; migrate to API | P1 |

---

## 6. Locations API (3 unused: `listProvinces`, `listCities`, `listBarangays`)

| Method | UI Target | Priority |
|---|---|---|
| `listProvinces` / `listCities` / `listBarangays` | **Existing page:** `GeographicSelectionWidget` — already exists, currently uses PSGC service; migrate to API | P1 |

**Flow:**
`EditProfileWidget / AddressFormWidget ("Location" field)` → `GeographicSelectionWidget` → `listProvinces()` →
select → `listCities(provinceCode)` → select → `listBarangays(cityCode)` → select → return to form

---

## 7. Notifications API (6 unused)

### 7.1 List Notifications (`listNotifications`)

| Method | UI Target | Priority |
|---|---|---|
| `listNotifications` | **Existing page:** `MyNotificationsWidget` — already exists, uses Supabase realtime; add API as primary data source | P0 |

### 7.2 Push Token Registration (`registerDevice`, `unregisterDevice`)

| Method | UI Target | Priority |
|---|---|---|
| `registerDevice` | **Modification:** App init (e.g., `main.dart` or `SplashWidget`) — call on Firebase token refresh | P0 |
| `unregisterDevice` | **Modification:** `SettingsWidget` logout flow — call before sign-out | P0 |

### 7.3 Mark All Read (`markAllRead`)

| Method | UI Target | Priority |
|---|---|---|
| `markAllRead` | **Existing page:** `MyNotificationsWidget` — "Mark all read" button already present, wire to API | P0 |

### 7.4 Preferences (`getPreferences`, `updatePreferences`)

| Method | UI Target | Priority |
|---|---|---|
| `getPreferences` / `updatePreferences` | **Existing page:** `NotificationPreferencesWidget` — currently uses `DisputesService` wrapper; migrate to `ShphNotificationsApi` | P1 |

---

## 8. Payments API (1 unused — `refundBookingPayment`)

### 8.1 Checkout (`createPaymentIntent`, `confirmPayment`)

| Method | UI Target | Priority |
|---|---|---|
| `createPaymentIntent` / `confirmPayment` | **Modification:** `BookingPaymentWidget` — replace direct Stripe/Maya calls with API-mediated flow | P0 |

**Flow:**
`BookingPaymentWidget ("Pay")` → `createPaymentIntent(amount, currency)` → use client_secret for Stripe sheet →
`confirmPayment(intentId, details)` → `BookingSuccessWidget`

### 8.2 Booking Payment Status (`getBookingPayment`)

| Method | UI Target | Priority | Status |
|---|---|---|---|
| `getBookingPayment` | **Modification:** `BookingDetailsWidget` — payment status now tappable → shows details dialog | P1 | ✅ Done |

### 8.3 Refund (`refundBookingPayment`)

| Method | UI Target | Priority |
|---|---|---|
| `refundBookingPayment` | **New page / modification:** `AdminDashboardWidget` — admin refund action | P2 |

### 8.4 Tip (`tipBookingProvider`)

| Method | UI Target | Priority |
|---|---|---|
| `tipBookingProvider` | **New page / modification:** `BookingDetailsWidget` — "Add Tip" button on completed booking | P1 |

**Flow:**
`BookingDetailsWidget (completed)` → "Add Tip" → amount picker → `tipBookingProvider(bookingId, amount)`

### 8.5 Voucher Validation (`validateVoucher`)

| Method | UI Target | Priority |
|---|---|---|
| `validateVoucher` | **Modification:** `BookingPaymentWidget` — add voucher code input field | P1 |

---

## 9. Wallet API (all wired — 0 unused)

### 9.1 Wallet Display (`getWallet`, `updateWallet`)

| Method | UI Target | Priority |
|---|---|---|
| `getWallet` / `updateWallet` | **Existing page:** `WalletWidget` — already exists; currently uses `WalletService (Supabase RPC)`; migrate to API | P0 |

### 9.2 Top-Up (`createTopUpIntent`, `confirmTopUp`)

| Method | UI Target | Priority |
|---|---|---|
| `createTopUpIntent` / `confirmTopUp` | **Modification:** `WalletWidget` — replace dialog-based top-up with payment intent flow | P0 |

**Flow:**
`WalletWidget ("Top Up")` → amount → `createTopUpIntent(amount, currency)` → Stripe sheet →
`confirmTopUp(paymentIntentId)` → refresh balance

### 9.3 Transaction History (`listTransactions`)

| Method | UI Target | Priority | Status |
|---|---|---|---|
| `listTransactions` | **Existing page:** `WalletWidget` — History card now opens modal bottom sheet with full list from API | P1 | ✅ Done |

### 9.4 Pay with Wallet (`payBookingWithWallet`)

| Method | UI Target | Priority |
|---|---|---|
| `payBookingWithWallet` | **Modification:** `BookingPaymentWidget` — add "Pay with Wallet" option alongside Stripe/Maya | P1 |

**Flow:**
`BookingPaymentWidget ("Pay with Wallet")` → `payBookingWithWallet(bookingId)` → `BookingSuccessWidget`

---

## Summary by Priority

| Priority | Count | Areas |
|---|---|---|---|
| **P0 (must-have)** | 16 methods | ✅ All 16 completed |
| **P1 (should-have)** | 2 remaining | `sendOtp`/`verifyOtp` (Firebase OTP — requires Firebase SDK) — all other 43 P1 methods wired ✅ |
| **P2 (nice-to-have)** | 19 remaining | register (direct), getCurrentUser, biometric all 6 methods, approvePartsCost/rejectPartsCost, updateBookingLocation, getThreadDetails, initiateCall/acceptCall/rejectCall/endCall, listCalls, getEta, refundBookingPayment (phone change promoted from P2 to P1 and done ✅) |

**Total: 64 unique methods mapped across all API classes — 59 wired ✅, 5 remaining across P1+P2.**
