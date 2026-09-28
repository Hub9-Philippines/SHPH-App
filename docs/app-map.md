# SHPH App Map — pages, connections, and key components

Flutter mobile app for the Serbisyo marketplace (clients ↔ service providers).
Generated from the source tree; all names are the real Dart identifiers.

- Framework: Flutter + GoRouter (`lib/router/app_router.dart`)
- State: `FFAppState` (`lib/app_state.dart`) + `provider`; per-domain singletons in `lib/services/`
- Backend: SHPH REST API via a hand-written Dio client (`lib/api/`) — Supabase is fully removed
- Web parity target: `E:\Dev\shph-web` (Vue 3 + Ionic)
- **§5 is the page-anatomy reference** — widget trees, private classes, and
  shared components for every important page. Read it before editing a page.

---

## 1. App shell & boot sequence

`lib/main.dart` is the entry point.

```
main()                       lib/main.dart
 └─ SHPHRootApp
     ├─ ChangeNotifierProvider<FFAppState>
     ├─ ChangeNotifierProvider<ConnectivityService>
     └─ MaterialApp.router     lib/main.dart:227
         ├─ routerConfig: AppRouter.createRouter(FFAppState)
         └─ builder: Stack      lib/main.dart:250   (sits ABOVE the Router)
             ├─ child                    ← the routed page / NavBarPage
             ├─ ConnectivityBanner       ← offline strip
             └─ CallLayerHost            ← global call overlays
```

`FFAppState` is passed to GoRouter as `refreshListenable`, so any auth-state change
re-runs routing. `RoleBasedRedirectGuard` (`lib/router/app_router.dart:789`) gates
routes: not logged in + a gated route → `/signin`.

**Boot flow**

```
/ (_initialize)                      app_router.dart:72
 ├─ logged in  → NavBarPage(initialPage: 'Home')
 └─ not logged in → SplashWidget      pages/splash/splash_widget.dart
                   ├─ first run → OnboardingWidget   pages/onboarding/
                   └─ returning  → SigninWidget      pages/signin/
```

`errorBuilder` falls back to `NavBarPage` when logged in, `SplashWidget` otherwise —
so a bad deep link never lands on a blank 404 for signed-in users.

---

## 2. Bottom navigation (the 4 tabs)

`NavBarPage` (`lib/main.dart:275`) holds exactly four tabs, defined in `_tabs`:

| Tab | Widget | File | Route |
|---|---|---|---|
| Home | `HomeRedesignWidget` | `lib/main/home/home_redesign_widget.dart` | `/home`* |
| Bookings | `BookingsWidget` | `lib/main/bookings/bookings_widget.dart` | `/bookings` |
| Messages | `MessagesWidget` | `lib/main/messages/messages_widget.dart` | `/messages` |
| Profile | `ProfileWidget` | `lib/main/profile/profile_widget.dart` | `/profile` |

System back from any non-Home tab returns to Home rather than exiting the app
(`PopScope` in `lib/main.dart:375`).

> \* The `/home` path constant lives on the **legacy** `HomeWidget`
> (`home_widget.dart:32`), but the route builder at `app_router.dart:120`
> returns `const HomeRedesignWidget()`. The legacy class is therefore routed
> but never rendered.
>
> `HomeWidget` and `CategoryWidget` (`lib/main/home/home_widget.dart`,
> `lib/main/category/`) still exist and are routed, but are **not** tabs — Home is
> the redesign. `ServicesScreen` is a full page pushed from Home, not a tab.

---

## 3. Page inventory

### 3.1 Auth & onboarding

| Widget | Route | File |
|---|---|---|
| `SplashWidget` | `/splash` | `lib/pages/splash/splash_widget.dart` |
| `OnboardingWidget` | `/onboarding` | `lib/pages/onboarding/onboarding_widget.dart` |
| `SigninWidget` | `/signin` | `lib/pages/signin/signin_widget.dart` |
| `SignupWidget` | `/signup` | `lib/pages/signup/signup_widget.dart` |
| `PhoneVerifyUserWidget` | `/phoneVerifyUser` | `lib/pages/phone_verify_user/phone_verify_user_widget.dart` |
| `OtpPageWidget` | `/otp` | `lib/pages/otp_page/otp_page_widget.dart` |
| `ForgotPasswordWidget` | `/forgotPassword` | `lib/pages/forgot_password/forgot_password_widget.dart` |
| `SetPasswordWidget` | `/setPassword` | `lib/pages/set_password/set_password_widget.dart` |
| `CreateProfileWidget` | `/createProfile` | `lib/pages/create_profile/create_profile_widget.dart` |
| `BiometricSetupWidget` | `/biometric-setup` | `lib/pages/biometric_setup/biometric_setup_widget.dart` |

`/pro-profile-setup-form` (name `ProProfileSetup`) renders `CreateProfileWidget` —
a pro-onboarding alias for the client profile form.

`/signOptions` is a retired route that aliases to `SigninWidget` so stale deep
links still work.

### 3.2 Discovery & services

| Widget | Route | File |
|---|---|---|
| `HomeRedesignWidget` | `/home` (path from `HomeWidget.routePath`) | `lib/main/home/home_redesign_widget.dart` |
| `ServicesScreen` | `/services` | `lib/main/services/services_widget.dart` |
| `CategoryWidget` | `/category` | `lib/main/category/category_widget.dart` |
| `CategoriesWidget` | `/categories` | `lib/pages/categories/categories_widget.dart` |
| `CategoryDetailWidget` | `/category/:categoryId` | `lib/pages/category_detail/category_detail_widget.dart` |
| `SubcategoryWidget` | `/category/:categoryId/subcategories` | `lib/pages/subcategory/subcategory_widget.dart` |
| `SearchPageWidget` | `/searchPage` | `lib/pages/search_page/search_page_widget.dart` |
| `ProductPageWidget` | `/productPage` | `lib/pages/product_page/product_page_widget.dart` |
| `ProviderProfileWidget` | `/provider/:providerId` | `lib/pages/provider_profile/provider_profile_widget.dart` |
| `ProviderReviewsWidget` | `/provider/:providerId/reviews` | `lib/pages/provider_reviews/provider_reviews_widget.dart` |
| `ReviewsWidget` | `/reviews` | `lib/pages/reviews/reviews_widget.dart` |
| `RecommendationsWidget` | `/recommendations` | `lib/pages/recommendations/recommendations_widget.dart` |
| `FavoritesWidget` | `/favorites` | `lib/pages/favorites/favorites_widget.dart` |
| `GeographicSelectionWidget` | `/geographic-selection` | `lib/pages/geographic_selection/geographic_selection_widget.dart` |
| `PinLocationWidget` | `/pinLocation` | `lib/pages/pin_location/pin_location_widget.dart` |
| `ContactProviderWidget` | `/contactProvider` | `lib/pages/contact_provider/contact_provider_widget.dart` |

### 3.3 Booking

Two parallel funnels exist — pick deliberately.

**A. `ProductPageWidget` funnel (4 numbered step cards)**

```
ProductPageWidget  "Book now"        product_page_widget.dart:1029  (_buildBottomBar)
 └─ _openBooking()                   product_page_widget.dart:1290
     └─ BookingWidget       /booking       cards 1-4: date, time, address, notes
         └─ BookingPaymentWidget     /booking-payment
             └─ BookingSuccessWidget /booking-success  → renders BookingConfirmationView
```

> The step count is **4**, not 3: `_buildStepCard(step: '1'…'4')` at
> `booking_widget.dart:231-289`. Steps 1-3 are date/time/address; step 4 is a
> free-text notes field. `ProductPageWidget` passes `serviceId` (plus display
> context) in `extra`; provider identity for the booking comes from
> `serviceId` server-side, so the `providerId` it also sends is display-only.

| Widget | Route | File |
|---|---|---|
| `BookingWidget` | `/booking` | `lib/pages/booking/booking_widget.dart` |
| `BookingPaymentWidget` | `/booking-payment` | `lib/pages/booking_payment/booking_payment_widget.dart` |
| `BookingConfirmationView` | via `/booking-success` | `lib/pages/booking_funnel/booking_success_screen.dart` |
| `BookingDetailsWidget` | `/booking-details` | `lib/pages/booking_details/booking_details_widget.dart` |
| `WriteReviewWidget` | `/write-review/:bookingId` | `lib/pages/write_review/write_review_widget.dart` |
| `OnDemandBookingWidget` | `/on-demand-booking` | `lib/pages/on_demand_booking/on_demand_booking_widget.dart` |

`BookingSuccessWidget` is **retired** — its route builder returns
`BookingConfirmationView` (`app_router.dart:520`).

**B. `BookingFlowScreen` funnel (multi-step, richer)**

`lib/pages/booking_funnel/` — a controller/repository split rather than the
FlutterFlow model/widget pattern:

```
BookingFlowScreen              /booking-flow   map + step panel
 ├─ setup/BookingSetupScreen                  no map — scope/level/estimate
 ├─ checkout/CheckoutScreen                   map via BookingStatusScaffold
 ├─ express_checkout_screen.dart              map via BookingStatusScaffold
 ├─ live_matching/LiveMatchingScreen          map + glass draggable dashboard
 │   └─ _AssignedProviderRouteMap             matched state, map + route polyline
 ├─ status_page.dart                          NO map (see map-less-booking-tracking)
 └─ booking_success_screen.dart
     ├─ BookingSuccessScreen                  funnel wrapper (Consumer<BookingFlowController>)
     └─ BookingConfirmationView              the actual confirmation UI
```

`booking_flow_screen.dart` is the route entry; `widgets/booking_flow_route.dart`
holds the in-funnel sub-routing via `buildBookingFlowRoute<T>(Widget)` (fade +
slide, 320ms).

Panels live in `widgets/`:

| File | Public class |
|---|---|
| `booking_flow_route.dart` | *(no widget)* `buildBookingFlowRoute<T>` |
| `booking_status_scaffold.dart` | `BookingStatusScaffold`, `BookingStatusBottomSheet` |
| `booking_step_spine.dart` | `BookingStepSpine` |
| `location_confirmation_panel.dart` | `LocationConfirmationPanel` |
| `time_selection_panel.dart` | `TimeSelectionPanel` |
| `service_selection_panel.dart` | `ServiceSelectionPanel` |
| `express_checkout_sheet.dart` | `ExpressCheckoutSheet` |
| `express_shimmer.dart` | `ExpressShimmer`, `ExpressCheckoutSkeleton` |
| `emergency_service_panel.dart` | `EmergencyServicePanel` |

> `lib/components/booking_step_indicator.dart` (`BookingStepIndicator`) exists but
> is **not** used by this funnel — the funnel uses its own `BookingStepSpine`.

### 3.4 Chat & calling

| Widget | Route | File |
|---|---|---|
| `MessagesWidget` | `/messages` | `lib/main/messages/messages_widget.dart` |
| `ChatPageWidget` | `/chat/:roomId` | `lib/pages/chat_page/chat_page_widget.dart` |
| `CallHistoryDetailsPageWidget` | `/call-details/:callId` | `lib/pages/call_history_details_page/call_history_details_page_widget.dart` |
| `CallPermissionWidget` | `/call-permission` | `lib/pages/call_permission/call_permission_widget.dart` |

> `ChatDetailWidget` (`/chat/:threadId`, `lib/pages/chat_detail/`) is **superseded
> and unrouted** — `ChatPageWidget` replaced it. Safe to delete.

### 3.5 Profile, settings, account

| Widget | Route | File |
|---|---|---|
| `ProfileWidget` | `/profile` | `lib/main/profile/profile_widget.dart` |
| `SettingsWidget` | `/settings` | `lib/pages/settings/settings_widget.dart` |
| `EditProfileWidget` | `/edit-profile` | `lib/pages/edit_profile/edit_profile_widget.dart` |
| `AddressesWidget` | `/addresses` | `lib/pages/addresses/addresses_widget.dart` |
| `AddressFormWidget` | `/addressForm` | `lib/pages/address_form/address_form_widget.dart` |
| `PaymentMethodsWidget` | `/paymentMethods` | `lib/main/payment_methods/payment_methods_widget.dart` |
| `AddCardPaymentWidget` | `/addCardPayment` | `lib/main/payment_methods/add_card_payment_widget.dart` |
| `AddEwalletPaymentWidget` | `/addEwalletPayment` | `lib/main/payment_methods/add_ewallet_payment_widget.dart` |
| `WalletWidget` | `/wallet` | `lib/pages/wallet/wallet_widget.dart` |
| `SecuritySettingsWidget` | `/security-settings` | `lib/pages/security_settings/security_settings_widget.dart` |
| `SessionsWidget` | `/sessions` | `lib/pages/sessions/sessions_widget.dart` |
| `LanguageSettingsWidget` | `/language-settings` | `lib/pages/language_settings/language_settings_widget.dart` |
| `ThemeSettingsWidget` | `/theme-settings` | `lib/pages/theme_settings/theme_settings_widget.dart` |
| `MyNotificationsWidget` | `/my-notifications` | `lib/pages/my_notifications/my_notifications_widget.dart` |
| `NotificationPreferencesWidget` | `/notification-preferences` | `lib/pages/notification_preferences/notification_preferences_widget.dart` |
| `MyReviewsWidget` | `/my-reviews` | `lib/pages/my_reviews/my_reviews_widget.dart` |
| `HelpPage` | `/help` | `lib/pages/help/help_page.dart` |
| `ChatbotPage` | `/chatbot` | `lib/pages/help/chatbot_page.dart` |
| `ReportProblemWidget` | `/report-problem` | `lib/pages/report_problem/report_problem_widget.dart` |
| `DisputesWidget` | `/disputes` | `lib/pages/disputes/disputes_widget.dart` |
| `PrivacyPolicyWidget` | `/privacy-policy` | `lib/pages/privacy_policy/privacy_policy_widget.dart` |
| `TermsOfServiceWidget` | `/terms-of-service` | `lib/pages/terms_of_service/terms_of_service_widget.dart` |

### 3.6 KYC

| Widget | Route | File |
|---|---|---|
| `KycOnboardingWidget` | `/kyc-onboarding` | `lib/pages/kyc/kyc_onboarding_widget.dart` |
| `KycDocumentWidget` | `/kyc-documents` | `lib/pages/kyc/kyc_document_widget.dart` |
| `KycFaceLivenessWidget` | `/kyc-liveness` | `lib/pages/kyc/kyc_face_liveness_widget.dart` |

### 3.7 Trades / on-demand (`tm_flow`)

| Widget | Route | File |
|---|---|---|
| `TMSubCategoryScreen` | `/tm/sub-category` | `lib/pages/tm_flow/tm_sub_category_screen.dart` |
| `TMBroadcastScreen` | `/tm/broadcast` | `lib/pages/tm_flow/tm_broadcast_screen.dart` |
| `TMEstimateScreen` | `/tm/estimate` | `lib/pages/tm_flow/tm_estimate_screen.dart` |
| `TMInvoiceScreen` | `/tm/invoice` | `lib/pages/tm_flow/tm_invoice_screen.dart` |
| `TMPaymentScreen` | `/tm/payment` | `lib/pages/tm_flow/tm_payment_screen.dart` |
| `TMRatingScreen` | `/tm/rating` | `lib/pages/tm_flow/tm_rating_screen.dart` |
| `TMActiveJobScreen` | `/tm/active-job` | `lib/pages/tm_flow/tm_active_job_screen.dart` |
| `ClientOnDemandJobsWidget` | `/client-on-demand-jobs` | `lib/pages/client_ondemand_jobs/client_ondemand_jobs_widget.dart` |
| `EtaTrackingWidget` | `/track/:token` | `lib/pages/eta_tracking/eta_tracking_widget.dart` |

### 3.8 Rooms & projects (legacy/collaboration)

| Widget | Route | File |
|---|---|---|
| `RoomListWidget` | `/rooms` | `lib/pages/room_list/room_list_widget.dart` |
| `RoomCreateWidget` | `/rooms/create` | `lib/pages/room_create/room_create_widget.dart` |
| `RoomJoinWidget` | `/rooms/join` | `lib/pages/room_join/room_join_widget.dart` |
| `RoomDetailWidget` | `/rooms/:roomId` | `lib/pages/room_detail/room_detail_widget.dart` |
| `ProjectListWidget` | `/projects` | `lib/pages/project_list/project_list_widget.dart` |
| `ProjectCreateWidget` | `/projects/create` | `lib/pages/project_create/project_create_widget.dart` |
| `ProjectDetailWidget` | `/projects/:projectId` | `lib/pages/project_detail/project_detail_widget.dart` |

> `AiBookingComposerWidget` (`/ai-booking-composer`, `lib/pages/ai_booking_composer/`)
> is **unrouted and unreferenced** — dead code.

`NotFoundWidget` (`/404`, `lib/pages/not_found/not_found_widget.dart`) is the
catch-all unknown-route screen.

---

## 4. Key navigation connections

### 4.1 Discovery → booking

```
HomeRedesignWidget ──"See all"──> ServicesScreen        /services
       │                     └─> CategoriesWidget    /categories
       ├──service card────────> ProductPageWidget     /productPage
       ├──provider card───────> ProviderProfileWidget /provider/:providerId
       └─quick action─────────> BookingFlowScreen     /booking-flow
BookingFlowScreen (no service in extra) → NavBarPage(Home)   app_router.dart:130
ProductPageWidget ──"Book now"──> BookingWidget        /booking
ProviderProfileWidget ──service card──> ProductPageWidget     :445
ProviderProfileWidget ──"Contact"──> ContactProviderWidget    :282
FavoritesWidget ──card──> ProductPageWidget                  :210
SearchPageWidget ──result──> ServicesScreen                   :323
```

### 4.2 Booking funnel connections

```
BookingWidget ──confirm──> BookingPaymentWidget        booking_widget.dart:144
BookingPaymentWidget ──paid──> BookingSuccessWidget     booking_payment_widget.dart:189
                             (renders BookingConfirmationView)
BookingFlowScreen status_page ──> ContactProviderWidget  status_page.dart:268
                              ──> WriteReviewWidget      status_page.dart:289
BookingsWidget ──card──> BookingDetailsWidget            bookings_widget.dart:380
                    ──> BookingPaymentWidget            :400
                    ──> WriteReviewWidget               :363
MyNotificationsWidget / HomeRedesignWidget ──> BookingDetailsWidget
```

> **Two funnels, two different maps.** The legacy `BookingWidget` /
> `BookingPaymentWidget` path has **no map at all** (plain `CustomScrollView` +
> sticky bottom bar). All map+sheet layout lives in `booking_funnel/`, where the
> map framing is currently inconsistent across three screens — see §5.4 and the
> open change `fix-booking-flow-map-sheet-layout`.

### 4.3 Chat & calls

```
MessagesWidget ──chat card──> ChatPageWidget                /chat/:roomId
MessagesWidget ──call card──> CallHistoryDetailsPageWidget   /call-details/:callId
ProviderProfileWidget ──"Chat"──> ChatPageWidget   provider_profile_widget.dart:257
ContactProviderWidget ──"Chat"──> ChatPageWidget   contact_provider_widget.dart:228
BookingDetailsWidget ──"Chat"──> ChatPageWidget   booking_details_widget.dart:293
ProductPageWidget ──"Chat"──> ChatPageWidget      product_page_widget.dart:1153

ChatPageWidget header buttons ──> CallSessionController.startCall  (in-room, no nav)
```

**Every external "Call using app" action goes through one helper:**

```
ProductPageWidget / BookingDetailsWidget / ContactProviderWidget
        │
        ▼
InAppCallLauncher.startInChatRoom()          lib/services/in_app_call_launcher.dart
        │  1. push ChatPageWidget (/chat/:roomId)   — fire-and-forget
        │  2. CallSessionController.call(...)      — immediately after
        ▼
CallSessionController  →  CallLayerHost renders the overlay (global, above Router)
                            ├─ ringing            → IncomingCallOverlay
                            ├─ outgoing/connecting/active → Audio/VideoCallOverlay
                            │     └─ minimize → PiP bubble (call stays live)
                            └─ ended/failed      → outcome panel, auto-dismiss 3s
```

This mirrors the web app: `ContactProviderPage.vue` pushes `/chat/:id` and
relies on the globally mounted `VideoCallOverlay`.

### 4.4 Settings & account

```
ProfileWidget ──> BookingsWidget, PaymentMethodsWidget, LanguageSettingsWidget,
           FavoritesWidget, MyReviewsWidget, MyNotificationsWidget, HelpPage,
           SecuritySettingsWidget, CreateProfileWidget, EditProfileWidget,
           AddressesWidget, KycOnboardingWidget
ProfileWidget ──logout──> goNamedAuth(SplashWidget)         profile_widget.dart:1195
SettingsWidget ──logout──> goNamedAuth(SplashWidget)        settings_widget.dart:77
SettingsWidget ──> LanguageSettings, MyNotifications, SecuritySettings,
                 EditProfile, TermsOfService, PrivacyPolicy
HelpPage ──> ChatbotPage                                      help_page.dart:122
AddressFormWidget ──> GeographicSelectionWidget, PinLocationWidget
KycOnboardingWidget ──> KycDocumentWidget ──> KycFaceLivenessWidget ──> Home
```

---

## 5. Page anatomy

What each important page is *made of*: the outermost widget its `build`
returns, its direct children in order, the private widgets it defines, and the
shared components it consumes. Read the file before trusting a line number —
these are point-in-time references.

Legend: `→` = direct child, `·` = nested. Build-outermost is noted because it is
routinely not the `Scaffold`.

### 5.1 Shell

**`NavBarPage`** — `lib/main.dart:275`, `StatefulWidget`
- Build-outermost `PopScope` → `Scaffold`. State: `_currentPageName = 'Home'`,
  `_currentPage`.
- `_tabs` is a `Map<String, Widget>` of exactly **4** entries (not 5 — there is
  no Explore/Category tab): `Home`→`HomeRedesignWidget`, `Bookings`,
  `Messages`, `Profile`.
- `Scaffold.body` → `ListenableBuilder(FFAppState)` → `_currentPage ?? tabs[…]`.
- `Scaffold.bottomNavigationBar` → `ListenableBuilder(FFAppState)` →
  `SafeArea(top:false)` → `CupertinoTabBar` (not a Material `BottomNavigationBar`).
- `_buildMessagesIcon` renders a `99+` unread badge from
  `FFAppState().unreadConversations`.

**`CallLayerHost`** — `lib/main.dart:442`, `StatelessWidget`
- Build-outermost `ListenableBuilder(CallSessionController.instance)`; **no
  Scaffold**. Switches on `CallUiState`:
  `ringing`→`IncomingCallOverlay`;
  `outgoing|connecting|active|ended|failed`→`VideoCallOverlay` or
  `AudioCallOverlay` by `CallMediaType`; `idle`→`SizedBox.shrink()`.
- Mounted above the `Router`, so `GoRouter.of`/`Navigator.of` are unavailable —
  this is why calls are an overlay and not a pushed route.

**`MaterialApp.router.builder`** — `lib/main.dart:243-268`
`CupertinoThemeScope` → `AnnotatedRegion<SystemUiOverlayStyle>` → `Stack`:
1. `child` (the routed page / `NavBarPage`)
2. `Positioned(top:0,l:0,r:0)` → `ConnectivityBanner(isOffline:)` — animates
   height 0↔36 with `AnimatedSlide`
3. `const CallLayerHost()`

### 5.2 Tab pages

**`HomeRedesignWidget`** — `lib/main/home/home_redesign_widget.dart:32`
- Build-outermost `GestureDetector(onTap: unfocus)` → `PopScope` → `Scaffold`.
- `_HomeRedesignWidgetState` mixes in `RefreshablePage<HomeRedesignWidget>`.
- `Stack`: gradient `DecoratedBox` · `Positioned(top)` → `PrototypeAppHeader`.
- The gradient layer's child is `wrapWithRefresh(slivers:)` →
  `RefreshIndicator` + `CustomScrollView`. Slivers: a 150px spacer for the
  pinned header, then one `SliverList` of sections:
  *YOUR BOOKINGS* (`ActiveBookingCard`) → *Trending near you* (horizontal
  `TrendingProviderCard`) → `EmergencyHelpCard` → *EXPLORE SERVICES*
  (horizontal `CategoryTileItem`) → `SeasonalOfferCard` → *Recommended for you*
  (`_RecommendedProviderCard`) → `ReferralBannerCard`.
- Header collapse: `_scrollController` + `_isHeaderCompact` +
  `_headerCollapseProgress`, range `_headerCollapseRange = 96`.
- Private widgets: `_HomeSectionHeader`, `_RecommendedProviderCard`,
  `_AccountMenu`, `_AccountMenuItem`.
- **Imperative push, not a named route:** `_openSearchPage` does
  `Navigator.push(PageRouteBuilder(240ms, …SearchPageWidget))`.
- Entry to the funnel: `_startBookingProcess` optionally shows
  `ServiceSelectionPanel` as a sheet, then pushes
  `buildBookingFlowRoute(… ExpressCheckoutScreen)`.

**`BookingsWidget`** — `lib/main/bookings/bookings_widget.dart:16`
- `GestureDetector` → `Scaffold` → `SafeArea` → `Column`.
- Fixed header (`_buildTopBar`, `SearchBarField`, `_buildFilterChips` for
  `all/pending/completed/canceled`) then `Expanded` → `wrapWithRefresh(slivers:)`.
- Sliver branches: error → `SliverFillRemaining(_buildErrorState)`;
  loading → `_bookingsListSliver` of `BookingCardSkeleton`;
  empty → `SliverFillRemaining(_buildEmptyState)`;
  else → `SliverList.separated` of `_buildBookingCard`.
- No private widget classes — all helpers are methods.
- Note: `searchController` is declared **public** (no leading underscore).

**`MessagesWidget`** — `lib/main/messages/messages_widget.dart:16`
- `GestureDetector` → `Scaffold` → `SafeArea` → `Column`.
- `ScreenHeader` · `SearchBarField` · `SegmentedControl<int>` · section label ·
  `Expanded` → `RefreshIndicator` → `CustomScrollView` with a single
  `SliverPadding` whose sliver is a ternary on `_model.selectedTabIndex`:
  `_buildChatTabSliver` or `_buildCallTabSliver`.
- No private widget classes. Card builders: `_buildChatRoomCard`,
  `_buildCallHistoryCard`.

**`ProfileWidget`** — `lib/main/profile/profile_widget.dart:32`
- Build-outermost `Theme(data: AppTheme.lightTheme())` → `FutureBuilder<ProfilesRow?>`.
  Three branches: loading (6 skeletons), `profile == null` (centered text), data.
- Data branch: `GestureDetector` → `Scaffold` → `SafeArea` → `wrapWithRefresh`
  → one `SliverToBoxAdapter` → `ContentContainer(variant: wide)` → `Column`.
- Groups: `_buildHeroCard` (gradient hero + `FutureBuilder<List<ShphAddress>>`
  saved-places) · `_buildVerificationSection` · 3 grouped tile blocks
  (account / prefs / system-access, built by `_buildGroup` returning
  `TintedMenuTile`s).
- Private widgets: `_CompleteProfilePill`, `_EditPill`, `_VerificationBadge`.

### 5.3 Discovery

**`ServicesScreen`** — `lib/main/services/services_widget.dart:28`
- `GestureDetector` → `Scaffold` → `SafeArea` → `Column`. No bottom nav bar.
- `RefreshIndicator` → `CustomScrollView` (Bouncing +
  `AlwaysScrollableScrollPhysics`). First sliver holds
  `SearchBarField` + location pill, `_buildCategoryRail` (horizontal
  `FilterChip`s), optional `InstantDispatchSection`, `_buildSortRow`.
- Second sliver `_buildServiceResults`: `SliverFillRemaining` empty state, or
  `SliverList.builder` of `_buildServiceCard`.
- "Book now" (`_l10n.ccBookNow`) → `_openExpressCheckout` →
  `buildBookingFlowRoute(… ExpressCheckoutScreen)`.
- Private widgets: `_ServiceCardImage` (`size = 84`), `_ServiceCardImageFallback`.
- Search is debounced: `EasyDebounce.debounce('services_screen_search', 250ms)`.

**`ProductPageWidget`** — `lib/pages/product_page/product_page_widget.dart:26`
- `GestureDetector` → `Scaffold` → `CustomScrollView` +
  `bottomNavigationBar: _buildBottomBar()`. Only **2** slivers.
- Sliver 1: `SliverAppBar(expandedHeight: 360, pinned, stretch)` with
  `FlexibleSpaceBar` whose background is `Stack` = `_buildHeroImage` · gradient ·
  `SafeArea` category chip + title + `Wrap` of `_heroInfoChip`s.
- Sliver 2: `SliverToBoxAdapter` (bottom padding **120** to clear the sticky
  bar) → `Column` of `_buildOverviewCard`, `_buildProviderCard`,
  `_buildSectionCard(About)`, `_buildTrustCard`, `_buildReviewsCard`.
- `_buildBottomBar` is a `Row` of two `FFButtonWidget`s: **Contact**
  (`flex: 1`) and **Book now** (`flex: 2`). There is deliberately no inline CTA
  in the provider card (web parity).
- All helpers are **private methods**; this file defines no private widget classes.
- Contains hardcoded hex colors (`0xFFF4F7FB`, `0xFF14213D`, …) — violates the
  theme rule in §9.

**`ProviderProfileWidget`** — `lib/pages/provider_profile/provider_profile_widget.dart:20`
- `Scaffold` with `appBar: PreferredSize → CupertinoPageHeader`.
- `body` is a ternary: loading → `AppActivityIndicator`; `provider == null` →
  `_buildError`; else → `_buildContent`.
- `_buildContent` is a `SingleChildScrollView` → `Column`:
  `_buildHero` (gradient card, avatar, bio, Contact `OutlinedButton`) ·
  `_buildStats` · services section (`_buildServicesGrid` = `LayoutBuilder` +
  `Wrap` of 2-up cards) · reviews section (`_buildSeeAllReviews`).
- Loads provider + listings only — **no reviews on this page**.
- No private widget classes.

**`SearchPageWidget`** — `lib/pages/search_page/search_page_widget.dart:33`
- `GestureDetector` → `Scaffold` → `SafeArea` → `Column`.
- Header `Row`: `BackButtonWidget` · title/subtitle · filter toggle `IconButton`.
- `CustomScrollView` slivers: header adapter (search bar wrapped in
  `Hero(tag:'searchBarHero')`, quick category rail, optional `_buildFilterPanel`)
  then a ternary result sliver — loading (5 × `SearchCardSkeleton`),
  `SliverFillRemaining` (empty or no-results), or `SliverList.builder`.
- Private widgets: `_SearchServiceCard`, `_SearchServiceThumbnail` (`size = 92`),
  `_SearchServiceThumbnailFallback`.
- `_searchGeneration` guards stale responses.

**`CategoriesWidget`** — `lib/pages/categories/categories_widget.dart:15`
- Thin wrapper page: `GestureDetector` → `Scaffold` →
  `bottomNavigationBar: QuickBookBar` → `SafeArea` → `Column` of header + the
  FlutterFlow-generated `CategoriesWidgetWidget` from
  `lib/components/categories_widget/`.
- No private classes of any kind.

### 5.4 Booking funnel B — `booking_funnel/` (the rich funnel)

**Shared map/sheet host — `BookingMapSheetHost`**
(`widgets/booking_map_sheet_host.dart`) — the layout every map-plus-sheet booking
screen funnels through. It enforces two invariants:

1. **The map is always `Positioned.fill`.** Full-bleed coverage is structural, so
   the map's bottom edge can never be bounded by a layout box. The sheet's surface
   is what occludes the map, never a gap.
2. **Camera padding is derived from the sheet, not a pixel constant.** The host
   measures the sheet's real height (via a `RenderProxyBox` callback,
   `SheetHeightMeasurer`) or, for a resizable sheet, follows its live drag extent.
   A viewport-derived `fallbackSheetFraction` covers the first frame before the
   first measurement lands.

API: `mapBuilder(context, cameraPadding)` is invoked with the derived padding, so
the caller builds the `GoogleMap` itself — the host never wraps it in a
`Consumer`/`AnimatedBuilder`, which is what keeps the radar ripple's per-tick
`ValueListenableBuilder` isolation intact. Optional slots: `background` (painted
under the map — shows through only on a map-free layout), `overlays` (above the
map, below the sheet), `aboveSheet` (above the sheet). `resizable` takes a
`BookingResizableSheet(initialFraction, minFraction, maxFraction)`; `maxExtentBuilder`
can derive the max extent from the measured content height instead. `sheet` is a
plain auto-measured widget; `sheetBuilder` additionally receives the host's
height callback and the `DraggableScrollableSheet` scroll controller.

**Consumers:** `BookingFlowScreen`, `BookingStatusScaffold`, and
`LiveMatchingScreen`'s `_AssignedProviderRouteMap` all derive their map framing
from this host. No booking screen hardcodes a pixel overlap or bounds its map
above the sheet any more.

**`BookingFlowScreen`** — `lib/pages/booking_funnel/booking_flow_screen.dart:25`
- Public `StatelessWidget`; `build` returns
  `ChangeNotifierProvider(create: BookingFlowController)` →
  `const _CleaningBookingFlowView()`. The real screen is the private
  `_CleaningBookingFlowViewState`.
- State: `late LatLng _center`, `bool _isLocationConfirmed = false`,
  `GoogleMapController? _mapController`,
  `late final bool _prefersSelectedAddressCenter`.
- `Scaffold` → `BookingMapSheetHost`. The host paints the map `Positioned.fill`
  and derives the camera padding from the measured panel height, so the pin stays
  framed in the band between the top card and the panel's top edge and re-frames
  when the step swaps. `maxSheetFraction: 0.64` caps the panel;
  `fallbackSheetFraction: 0.45` covers the first frame. The panel already applies
  its own `SafeArea(top:false)`, so `includeBottomSafeArea: false`.
- `mapBuilder` → `GoogleMap`, zoom 16, all gestures/controls disabled, single
  `MarkerId('selected_booking_pin')`. `onCameraIdle` →
  `BookingFlowController.setCoordinates`; `onCameraMove` updates `_center`.
- `overlays` (above the map, below the panel), in order:
  1. `Positioned.fill` → `DecoratedBox` 3-stop black scrim.
  2. `Positioned(top: padding.top + 12)` → `Consumer<BookingFlowController>`
     → `_FlowTopCard`.
- `sheet` → `Consumer<BookingFlowController>` → `SafeArea(top:false)` → the step
  panel.
- Panel swap is a single ternary on `_isLocationConfirmed`, which also drives
  `stepIndex: _isLocationConfirmed ? 1 : 0`:
  `true` → `TimeSelectionPanel`, `false` → `LocationConfirmationPanel`.
- `_FlowTopCard` = back `IconButton` · step text · `BookingStepSpine` ·
  `_AddressBanner`.

**`BookingStatusScaffold`** — `widgets/booking_status_scaffold.dart:9`
- `Scaffold` → `BookingMapSheetHost`. The host paints the map `Positioned.fill`
  in every mode, so the map's bottom edge can never be bounded — that bounded map
  was what left a band of background between the map and the sheet.
- `background` → the gradient `DecoratedBox`. An opaque map hides it, so it only
  shows through on the map-free path.
- `mapBuilder` → `showMap ? _RadarMapLayer(...) : const SizedBox.shrink()`. The
  map-free path constructs no `GoogleMap` at all.
- `overlays` → optional `Center(child: center!)`.
- `sheet` → `bottomSheet`.
- `aboveSheet` → optional `Positioned(top)` → `topCard`.
- `resizable` is set when `isDraggable`: `BookingResizableSheet(initialFraction:
  sheetInitialFraction, minFraction: sheetMinFraction, maxFraction:
  sheetMaxDraggableFraction)`. The camera padding follows the live drag extent.
- `includeBottomSafeArea: false` / `includeTopSafeArea: false` — the sheet applies
  its own `SafeArea(top:false)` and the map does not extend behind the status bar,
  so neither inset is added.
- `const double _kDefaultSheetMaxFraction = 0.64`; the four fraction fields
  (`sheetMaxFraction`, `sheetInitialFraction: 0.35`, `sheetMinFraction: 0.12`,
  `sheetMaxDraggableFraction: 0.75`) are *budgets*, clamped — they should not be
  used as layout bounds.
- `_RadarMapLayer` wraps `GoogleMap` in a `ValueListenableBuilder<Set<Circle>>`
  when `radarScan != null`, so ripple ticks rebuild only circle data.
- `BookingStatusBottomSheet` = `Container` (radius top 32) → `SafeArea(top:false)`
  → `child` — a host, not content.

**Consumers of `BookingStatusScaffold`**
- `CheckoutScreen` (`checkout/checkout_screen.dart:22`) — `Consumer` →
  `PopScope(canPop: !isSubmitting)` → scaffold. Sheet swaps on
  `showWaiting = controller.isMatchingActive`: `_MatchingWaitingSheet` (with
  Resume → `LiveMatchingScreen` / Cancel) vs `_CheckoutSheet`. Passes no
  `topCard`/`center`. Private widgets: `_CheckoutSheet`, `_MatchingWaitingSheet`,
  `_WaitingInfoRow`, `_ModeBanner`, `_SummaryGrid`, `_ActionRowCard`,
  `_SectionTitle`, `_TotalCard`, `_EstimateRetryBanner`, `_Pill`.
- `ExpressCheckoutScreen` (`express_checkout_screen.dart:20`) — same shape.
  Sheet swaps on `controller.isLoadingData` inside a 200ms `AnimatedSwitcher`:
  `ExpressCheckoutSkeleton` vs `ExpressCheckoutSheet`.

**`BookingSetupScreen`** — `setup/booking_setup_screen.dart:16` — **no map**
- `Scaffold` + `AppBar` (title = step 3 of 4 + `bfServiceSetup`) →
  `SafeArea` → `Consumer<BookingFlowController>` → `Column`:
  `BookingStepSpine(currentStep: 2)` · `Expanded(ListView)` of sections ·
  a **sticky CTA outside the scroll view** (`SafeArea` + `AppButton` → push
  `CheckoutScreen`).
- Private widgets: `_SetupHero`, `_SectionLabel`, `_LandmarksField`,
  `_ArrivalCodeTile`, `_EstimateSection`, `_EstimateSkeleton`, `_SummaryTile`,
  `_StepperRow`, `_StepperButton`, `_ChoiceGroup`, `_PriceBreakdown`.

**`LiveMatchingScreen`** — `live_matching/live_matching_screen.dart:40` (2857 lines)
- `StatefulWidget`. **Two completely different layouts:**
  - matched (`_matchedPro != null && _providerLatLng != null`) → `PopScope(canPop:false)`
    → `_AssignedProviderRouteMap`, bypassing the Stack entirely.
  - otherwise → `PopScope` → `Scaffold` → `Stack`:
    `Positioned.fill(_mapBody)` · `if (!_timedOut) Positioned(top)(_StatusBadge)` ·
    `Align(bottomCenter)(_buildDashboard)`.
- `_buildDashboard` = `DraggableScrollableSheet(initial 0.38, min 0.12, max 0.82,
  snapSizes [0.12, 0.38, 0.72])` → blur `BackdropFilter(sigma 12)` →
  `ClipRRect(top 32)` → three-way swap: `_TimeoutSheet` / `_MatchedSheet` /
  `_SearchingSheet`.
- `_mapBody` passes **no `padding:`** — camera framing is
  `CameraUpdate.newLatLngBounds` from `_fitCameraToRadius()` with
  `radiusMeters = _currentRadiusKm * 1000`.
- `_AssignedProviderRouteMap` is a `BookingMapSheetHost`. The map is
  `Positioned.fill`; the camera padding follows the sheet's live drag extent.
  `resizable` = `BookingResizableSheet(initial/min: _collapsedSheetExtent = 0.25,
  max: _expandedSheetExtent = 0.50)`, and `maxExtentBuilder` derives the max extent
  from the measured content height (`_sheetContentHeight`), clamped between
  `0.25` and `0.50` — the same rule the screen used to apply privately.
  `removeBottomPaddingForDraggable: true` wraps the sheet in
  `MediaQuery.removePadding(removeBottom: true)` so the keyboard inset doesn't
  push it around. `onSheetContentHeightChanged` calls `_scheduleBoundsUpdate()`
  to re-frame the provider polyline. The screen's private `_sheetContentHeight`,
  `_dynamicMaxSheetExtent`, `_bottomSheetExtent`, and
  `_handleSheetNotification` plumbing is gone — the host owns it.
- Private widgets: `_AssignedRouteTopBar`, `_AssignedRouteBottomSheet`,
  `_BookingStatusChip`, `_BookingActionButton`, `_SheetPrimaryButton`,
  `_StatusBadge`, `_GradientBar`, `_SearchingSheet`, `_MatchedSheet`,
  `_MatchedInfoTile`, `_TimeoutSheet`, `_MetaRow`, `_MeasureSize`.
- State consts: `_searchWindowSeconds = 180`, `_expandRungInterval = 30s`,
  `_zoomNearby = 16.0`, `_zoomMatched = 15.0`.
- Uses `flutter_polyline_points` for the provider route; keys from
  `AppConfig.googleDirectionsKey`.

**`StatusPage`** — `status_page.dart:17` — **no map by design**
- `StatefulWidget with TickerProviderStateMixin`; `static const int _kStageCount = 5`.
- `build` returns a `Scaffold` and, when `shouldPopToHome`, wraps it in
  `PopScope(canPop:false)`. Body = gradient `DecoratedBox` → `SafeArea(bottom:false)`
  → `Column`: a floating-controls row (back, home, `_ProviderCard`) and
  `Expanded(_TrackingSheet(...))`.
- Enforces `map-less-booking-tracking`: coordinates are resolved for distance/ETA
  only; no `GoogleMap` is ever built. Polls every 4s via
  `ShphBookingsApi.instance.getBooking`.
- Private widgets: `_FloatingCircleButton`, `_ProviderCard`, `_MapActionButton`,
  `_TrackingSheet`, `_InfoBadge`, `_StageRow`, `_EtaChip`, `_BookingStatusChip`;
  `_BookingStage` is a plain model.

**`BookingSuccessScreen` / `BookingConfirmationView`** — `booking_success_screen.dart:401` / `:18`
- `BookingSuccessScreen` is a thin `Consumer<BookingFlowController>` wrapper that
  maps controller state into `BookingConfirmationView` props.
- `BookingConfirmationView.build`:
  `Scaffold` → `SafeArea` → `SingleChildScrollView(Bouncing)` → `Column`:
  `_CheckHero` · headline · `_ReceiptCard` · *Track my booking* `AppButton` ·
  *Add to calendar* `AppButton` · `Divider` · `InviteEarnBanner`.
- `_CheckHero` is a `StatefulWidget` running a 700ms
  `Interval(0, 0.7, easeOutBack)` scale + fade.
- Private widgets: `_CheckHero`, `_ReceiptCard`, `_ReceiptRow`.
- No map, no bottom sheet, no `RefreshIndicator`.

**Step panels** (all `StatelessWidget` unless noted; all self-contained
`Container`s with a radius-top-28 surface, so they are height-agnostic hosts)
- `LocationConfirmationPanel` — drag handle · `bfPinnedLocation` badge ·
  service card · drop-off card · `Row` of *Edit pin* / *Continue* (`AppButton`).
- `TimeSelectionPanel` — handle · badge · optional schedule summary card ·
  three `_TimeCard`s (`rightNow` / `laterToday` / `scheduled`; the latter two
  `await` `onPickLaterToday` / `onPickScheduledSlot`) · full-width *Continue*.
  `_TimeCard` = `InkWell` → `AnimatedContainer(220ms)`.
- `ServiceSelectionPanel` — **`StatefulWidget`**, the only panel with no
  `SafeArea`/shadow/`AppButton`. Fetches
  `ServiceListingService.instance.fetchServiceListings(ordering:'-rating', pageSize: 9)`
  in `initState` and shows a 3×3 `GridView` placeholder
  (`NeverScrollableScrollPhysics`, `itemCount: 9`) while loading. Returns the
  selection via `Navigator.pop(service)`.
- `ExpressCheckoutSheet` — `Column(mainAxisSize.min)` with **no wrapper
  `Container`**; designed to be dropped into a host sheet. Internally steps 0/1/2
  via a keyed `Column` inside `SingleChildScrollView`, swapping
  `_SpecialistSummary`+`_ServiceMatrix` → `_LocationContextCard`+`_ArrivalCodeRow`
  → `_PaymentMatrix`, then `_CheckoutFooter`.

### 5.5 Booking funnel A — the legacy 3-screen path

**`BookingWidget`** — `lib/pages/booking/booking_widget.dart:18`
- `GestureDetector` → `Scaffold` → `CustomScrollView` +
  `bottomNavigationBar: _buildBottomBar()`. **No Scaffold-level `SafeArea`.**
- 2 slivers: header adapter (`SafeArea(bottom:false)` → back + title) and one
  `SliverToBoxAdapter` (bottom padding **130**) containing `_buildHeroCard` and
  **4** `_buildStepCard`s — date, time, address, notes.
- `_buildProviderRow` and `_buildServiceImage` are private **methods**.
- Notes field uses `_model.notesController` — the controller lives on the model,
  not in State.

**`BookingPaymentWidget`** — `lib/pages/booking_payment/booking_payment_widget.dart:17`
- Same skeleton: `GestureDetector` → `Scaffold` → `CustomScrollView` +
  `_buildBottomBar()`, 2 slivers, bottom padding **130**.
- Body: `_buildServiceHero` · `_buildScheduleSummary` · `_buildEscrowNotice` ·
  4 × `_buildPaymentOption` (`'card'`, `'ewallet'`, `'qr'`, `'cash'`).
- `paymentStatus` mapping: cash→`pay_on_completion`, card/ewallet→`paid`,
  qr→`authorized_escrow`.

### 5.6 Chat & calls

**`ChatPageWidget`** — `lib/pages/chat_page/chat_page_widget.dart:17`
- `GestureDetector` → `Scaffold` → `SafeArea` → `Column`. **No `appBar`** — the
  header is inlined as the first child.
- Column: `_buildHeader` · `if (isSearching)` search bar · `Expanded` →
  decorated card container → `_buildConversationBody` · `_buildQuickReplies` ·
  `_buildComposer`.
- `_buildConversationBody` is a 3-way ternary: loading placeholder bubbles,
  empty state, or a `ListView.builder` that interleaves day chips, system
  messages, and bubbles via `_buildRowWithSeparators`.
- `_buildComposer` = `SafeArea` → `Padding` → `Row(crossAxisAlignment: end)`:
  pill `Container` (attach + `AppTextField` `minLines:1/maxLines:4` + emoji) and
  a 52×52 gradient send button.
- Header actions: search, and **audio + video only when `isDirectThread`**,
  plus overflow.
- Private widgets: `_HeaderIconButton`, `_ComposerIconButton`.
- `_showStickerPicker` is toggled but never rendered — dead flag.

### 5.7 Profile, settings, KYC, auth

**`SettingsWidget`** — `lib/pages/settings/settings_widget.dart:17`
- `GestureDetector` → `Scaffold` → `SafeArea` → `ListView`. No appBar.
- Flat list: header `Row` · `_buildHeroCard` · `_buildSection(General, 4 tiles)` ·
  `_buildSection(Legal, 3 tiles)` · a standalone Log Out `TintedMenuTile`.
- Private widget: `_GearShieldBadge`.

**`KycOnboardingWidget`** — `lib/pages/kyc/kyc_onboarding_widget.dart:18`
- The one page whose `build` returns a `Scaffold` **directly** (no
  `GestureDetector`). Takes an injectable `ClientKycService? kycService` for tests.
- `SafeArea(top:false)` → `Column`: `PreferredSize(44)` → `CupertinoPageHeader`
  (with a *Skip for now* action) · `Expanded(SingleChildScrollView)` of intro +
  checklist card + start/skip buttons.

**`OnboardingWidget`** — `lib/pages/onboarding/onboarding_widget.dart:18`
- `GestureDetector` → `Scaffold` → `Padding` → `Column`. **No `SafeArea`** —
  padding is `fromSTEB(0, 50, 0, 20)`.
- Skip `FFButtonWidget` · `Expanded(Container(height: 70% clamped 400-700))` →
  `Stack`: `PageView` of **4** slides + `Align(bottomCenter)` →
  `SmoothPageIndicator(count: 4, ExpandingDotsEffect)`.
- **Slide 1 is the language picker** (`_buildLanguageSlide`, sets
  `FFAppState().locale`); slides 2-4 are marketing.
- Slides 2-4 titles/bodies are **hardcoded English literals**, not localized —
  only `chooseYourLanguage`, `onbSkip`, `onbNext` use l10n.
- Requests location then camera permission from a post-frame callback.
- No `lib/components/` imports at all.

**`SigninWidget`** — `lib/pages/signin/signin_widget.dart:24`
- `GestureDetector` → `PopScope` → `Scaffold`. The only page with a `PopScope`.
- `appBar: PreferredSize(56) → CupertinoPageHeader` (leading `BackButtonWidget`).
- `SafeArea(top:true)` → `SingleChildScrollView` → `Column`: `_buildHeader` ·
  `_buildTabBar` (a **hand-rolled** `Container`+`GestureDetector` segmented
  control, *not* the shared `SegmentedControl<T>`) · `SizedBox(height: 520)` →
  `TabBarView` of `_buildPhoneTab` / `_buildEmailTab`.
- Phone tab: masked `TextFormField` (`'+63##########'`, `MaxLengthEnforcement.enforced`)
  → sign in → `_OrDivider` → 2 × `_SocialButton` → forgot password → signup.
- Private widgets: `_OrDivider` (no `const` ctor — a lint smell),
  `_SocialButton` (wraps `AppButton`).
- All controllers/focus nodes live on `SigninModel`, created in `initState`;
  `dispose` only calls `_model.dispose()`.

---

## 6. Important components (`lib/components/`)

Reusable UI. Prefer these over inlining new widgets.

**Shared layout & chrome**
`ScreenHeader`, `SectionHeader`, `ContentContainer`, `SoftCard`, `RefreshablePage`,
`EmptyState`, `ErrorState`, `StatusPill`, `TintedMenuTile`, `PopoverMenu`,
`SegmentedControl`, `SmoothProgressBar`, `SearchBarField`, `SearchableSelect`,
`CategoryPill`, `ImageLightbox`, `StarRating`, `UserAvatar`, `TrustBadge`.

**Cards & feeds**
`ServiceCard`, `BookingCard`, `BookingActionRow`, `RecommendationCard`,
`ServiceRecommendations`, `ProviderProximityCard`, `HeroOfferBanner`,
`InviteEarnBanner`, `QuickBookBar`.

**Booking funnel**
`BookingStepIndicator`, `AvailabilityCalendar`, `EarningsChart`, `InvoiceLineItems`,
`ProviderStatusToggle`.

**Chat & calling**
`IncomingCallOverlay`, `AudioCallOverlay`, `VideoCallOverlay`,
`CallAcceptPermissionSheet` (+ `enum CallType`), `ContactActionSheet`
(+ `ContactActionKind` / `ContactActionChoice`), `RichChatBar`.

> The call overlays are **global**, not routed. They are mounted by `CallLayerHost`
> from `MaterialApp.router`'s `builder`, which sits *above* the `Router` — so
> `GoRouter.of(context)` and `Navigator.of(context)` are **not** available there.
> Do not push routes from that layer.

**Provider / on-demand**
`InAppNotification`, `ConnectivityBanner`, `InstantDispatchSection`,
`IncomingJobModal`, `WaitingForClientModal`, `OnboardingOverlay`,
`ExploreMapView` (+ `ExploreMapMarker`), `ProviderMapView`,
`MapRadarScan` + `RadarScanController`, `AuthPromptModal`,
`StepUpPasswordModal`, `PrototypeComponents`.

> `RadarScanController` is the performance-critical piece: a
> `ValueListenableBuilder<Set<Circle>>` so ripple ticks rebuild only circle data
> and never the map or sheet. Preserve that isolation in any new map host — see
> the `native-radar-scan` spec.

---

## 7. Services (`lib/services/`)

Singletons, mostly `X.instance`.

**Calling & chat**
`CallSessionController` (`ChangeNotifier` state machine: `idle/outgoing/ringing/connecting/active/ended/failed`),
`ShphWebRTCCallService`, `ShphWebSocketService`, `CallSignal` models in
`call_signal_models.dart`, `InAppCallLauncher`, `CallService`, `ChatService`,
`ChatDetailService`, `RoomsService`.

**Bookings & payments**
`BookingsService`, `PaymentController` (Stripe + Maya), `WalletService`,
`BidsService`, `AvailabilityService`, `ProviderBookingsService`, `ProBookingsService`.

**Catalog & discovery**
`ServiceListingService`, `CategoriesService`, `SubcategoryService`, `SearchService`,
`RecommendationsService` (via `api/resources/recommendations_api.dart`),
`FavoritesService`, `ReviewsService`, `ProviderProfileService`, `MyServicesService`,
`ProviderAnalyticsService`, `EarningsService`.

**Account & trust**
`AuthService`, `ProfilesService`, `AddressesService`, `SessionsService`,
`ClientKycService`, `KycHubService`, `KycSubmissionService`, `BiometricService`,
`DisputesService`, `ReportProblemService`, `NotificationStore`, `NotificationsPrefsService`,
`PushNotificationService`.

**Platform**
`LoggingService`, `ErrorHandler`, `ConnectivityService`, `OfflineService`,
`DeviceInfoService`, `PsgcService`, `TrackingService`, `VerificationTimerService`,
`VoiceSearchService`, `AiService`, `AiComposerService`, `OndemandJobsService`,
`ProjectsService`.

---

## 8. API layer (`lib/api/`)

Hand-written Dio client — **not** generated. `tool/generate_api_client.ps1` is unused;
`lib/api/generated/` does not exist.

```
lib/api/api_config.dart          base URL (https://serbisyohubph.com),
                                 preferShphApi => true  ← single source of truth
lib/api/shph_api.dart            ShphApi facade
lib/api/shph_api_client.dart     ShphApiClient (Dio)
lib/api/shph_api_exception.dart  ShphApiException
lib/api/shph_token_storage.dart  token persistence
lib/api/bridges/                 ShphAuthBridge, ApiRowMapper
lib/api/models/                  typed response models
lib/api/resources/               one *_api.dart per domain
```

> `docs/api_gaps.md` and `README.md` are **stale** — both still describe Supabase
> auth/backend. Do not trust them for data/auth facts.

---

## 9. Theming & conventions

- `AppTheme.of(context)` / `AppThemeData` in `lib/theme/app_theme.dart`.
  **Always use theme tokens, never hardcoded hex or `Colors.*`** — dark mode
  depends on it. Status colors via `AppThemeData.statusColors()`.
- Font is `GoogleFonts.plusJakartaSans()`. **`GoogleFonts.poppins` is banned.**
- Full token reference: `docs/design-system.md`.
- Page pattern: `lib/pages/<name>/<name>_model.dart` + `<name>_widget.dart`
  (FlutterFlow). `booking_funnel/` and `tm_flow/` deliberately use a
  controller/repository split instead.
- `analysis_options.yaml` excludes `lib/custom_code/**` and
  `lib/flutter_flow/custom_functions.dart`.

---

## 10. Known dead / superseded code

| Item | Status |
|---|---|
| `lib/pages/call/` (route-based call screens) | **Deleted** — replaced by the global overlays |
| `ChatDetailWidget` (`/chat/:threadId`) | Superseded by `ChatPageWidget`; unrouted |
| `AiBookingComposerWidget` (`/ai-booking-composer`) | Unrouted, unreferenced |
| `BookingSuccessWidget` | Retired; route now renders `BookingConfirmationView` |
| `HomeWidget` | Path constant still owns `/home`, but the builder returns `HomeRedesignWidget` — the class is routed but never rendered |
| `CategoryWidget` | Routed but not a bottom tab |
| `BookingStepIndicator` (`lib/components/`) | Real class, but the booking funnel uses its own `BookingStepSpine` instead |
| `ChatPageWidget._showStickerPicker` | Toggled but never rendered — dead flag |
| `live_matching_screen.dart:1924-1933` | Comment block describing a "match reveal" widget that does not exist |
| Stray comments | `// TAIL2/TAIL3/TAIL4` in `express_checkout_sheet.dart`, `// SHEET_PLACEHOLDER` in `status_page.dart` |
| `docs/api_gaps.md`, `README.md` | Stale Supabase descriptions |

**Hardcoded colors (theme-rule violations)**
`ProductPageWidget` embeds ~12 literal hex values (`0xFFF4F7FB`, `0xFF14213D`,
`0xFF027A48`, …) instead of `AppTheme` tokens — see §9. Others in the booking
funnel use `Colors.black.withValues(...)` for scrims and shadows, which is
acceptable since they are alpha-only overlays, not surface colors.
