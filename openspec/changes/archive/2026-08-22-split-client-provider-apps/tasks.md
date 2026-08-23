## 1. Fork the Provider App

- [x] 1.1 Copy this working tree to `E:\Dev\shph-provider` (excluding `build/`, `.dart_tool/`, `.git`), init a fresh git repo there, and confirm `flutter pub get && flutter analyze` passes unchanged
- [x] 1.2 In the new repo: rename pubspec `name:` to `shph_provider`, set Android applicationId / iOS bundle id to `com.serbisyohub.provider`, update app display name, and verify `flutter build apk --release` succeeds
- [x] 1.3 Add a README section in the provider repo listing which top-level directories were copied verbatim from SHPH (provenance manifest per design D2)

## 2. Prune Provider App to Provider-Only

- [x] 2.1 In the provider repo, remove client-only page families (explore/home client surfaces, booking funnel as customer, favorites, addresses) after grep-auditing references; replace entry routing with the provider tab set from `lib/main.dart`
- [x] 2.2 Invert `PostAuthNavigationFlow`: providers proceed to the verification lifecycle/dashboard; non-provider accounts get the "use the SerbisyoHub client app" notice
- [x] 2.3 Remove client-only routes from `app_router.dart`, delete unused routes/gates, and verify `flutter analyze` reports 0 errors plus targeted tests pass

## 3. Client App: Signup Simplification

- [x] 3.1 Remove the "service provider" role option from `sign_options`, signup, and phone/OTP completion flows so all created accounts are clients (spec: client-only account creation)
- [x] 3.2 Strip provider-specific profile fields/steps from `create_profile` and simplify `_mapSignupRole` call sites accordingly

## 4. Client App: Auth Outcome & Notice

- [x] 4.1 Simplify `post_auth_navigation_flow.dart` so every sign-in lands on Home; when `AuthService.isProvider == true`, show the "Use the SerbisyoHub Provider app" notice with Continue-as-client and Sign-out actions (spec scenarios: provider signs in; mixed account continues)
- [x] 4.2 Add a store-link placeholder constant for the provider app listing used by the notice, and cover the flow with a widget test in `test/`

## 5. Client App: Shell & Router Pruning

- [x] 5.1 Delete `_providerTabs`, `_buildProviderItems`, and provider branch getters/setters from `lib/main.dart`; shell always renders the five client tabs (spec: fixed client tab set)
- [x] 5.2 Remove all provider-only route registrations, `RouteGates.requiresProvider` usage, and `_providerHomePaths` from `app_router.dart`; ensure legacy deep links (`/pro-dashboard`, etc.) fall through to Home without crashing (spec: provider-only routes unreachable)
- [x] 5.3 Reduce `FFAppState.isProvider` usage to the sign-in detection flag feeding task 4.1's notice

## 6. Client App: Page Deletions

- [x] 6.1 Grep-audit inbound references, then delete provider-only page families: `pro_dashboard` (main + pages), `earnings*`, `my_services`, `availability_calendar`, `provider_bids`, `provider_analytics`, `dispatch`, `tm_flow`
- [x] 6.2 Grep-audit and delete provider KYC/eKYC families: `kyc_hub`, `e_k_y_c_begin`, `i_d_verify`, `pro_verification`, plus `provider_verification_service` if unreferenced by kept code
- [x] 6.3 Verify kept look-alikes are intact: `provider_profile` (public view), `client_ondemand_jobs`, booking funnel, chat/calls, reviews, wallet/payment methods still compile and route correctly

## 7. Cleanup & Verification

- [x] 7.1 Update or delete tests referencing removed widgets; run `flutter analyze` (0 errors required) and per-file test runs on remaining tests including `test/booking_funnel_test.dart`
- [x] 7.2 Update stale docs touched by the split (README feature list, `docs/ui-ux-reconstruction-plan.md` status) and add the provider-app split to the change notes
- [x] 7.3 Build `flutter build apk --release` for the client app and smoke-test: signup → home → explore → book → chat → review, plus deep link to a removed provider path landing on Home
