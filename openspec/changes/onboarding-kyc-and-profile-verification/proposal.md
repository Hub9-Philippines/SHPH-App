## Why

The client onboarding path shipped rough edges that hurt trust and completion: the Google/Apple buttons on the auth entry page render invisible labels (white on a light surface), the "Complete your profile" step shows a faint blank field under the photo that opens the gallery, and its fields don't match the web signup form. There is also no identity-verification step for clients at all, even though the backend and web app already support `customer` KYC submissions — and no first-run language selection, so the marked-down 10-locale list stays confusing. This change fixes the visible bugs, brings the completion step to web parity, adds an English/Filipino onboarding language step with real-time switching, ships a client KYC flow (onboarding → documents → face liveliness, skippable), and reflects verification state in the Profile hub.

## What Changes

- **Fix invisible social-auth buttons** on the merged auth entry page (`_SocialButton`): give the Google/Apple icon + label an explicit `primaryText` color so they read on the light surface.
- **Fix the blank photo-picker field** on the completion page: replace the faint full-width outlined "Add Photo" box with a clearly-labeled, tappable photo control (mirrors web's photo-preview + label), with an explicit text color.
- **Web-parity completion step**: split "Display name" into web-style **First name** + **Last name** (keeps photo + optional bio), add a filled-fields progress indicator, gate Finish until first+last are set, and submit `first_name`, `last_name`, computed `display_name`, `bio`, `photo_url`, `is_profile_complete: true`.
- **Onboarding language selection** (first-run): before the marketing slides, a step offers exactly **English** and **Filipino**; selection applies immediately and persists.
- **Filipino localization**: add `lib/l10n/app_fil.arb`, regenerate delegates, restrict `supportedLocales` to `en`/`fil`, and trim the Settings language list to the same two options. Real-time switching already works via `FFAppState.locale` and must keep working for the new pages.
- **Client KYC flow**: three new pages — KYC onboarding/intro, document upload (ID front/back + selfie), and camera-based face liveliness (server challenge → capture → submit). Submits as `submitterRole: 'customer'`. Each page offers **Skip for now** (calls `skipKyc`), and post-auth routing gains a `needs_kyc` checkpoint after profile completion for clients who haven't submitted/skipped.
- **Profile hub verification state**: the hero CTA becomes three-state — incomplete profile → "Complete your profile"; complete but unverified → "Verify now" (routes to the client KYC flow); verified → no CTA, only the verified badge.

## Capabilities

### New Capabilities
- `social-auth-buttons-visible`: Google/Apple button labels and icons on the auth entry page always render legibly on the current surface.
- `create-profile-web-parity`: the mobile profile-completion step matches the web signup fields (photo, first name, last name, bio, progress) and fix the blank photo-picker control.
- `onboarding-language-selection`: first-run onboarding presents exactly English and Filipino and applies the choice immediately.
- `filipino-localization`: the app supports the `fil` locale end-to-end (ARB + delegates + `supportedLocales`), with other locales no longer advertised.
- `client-kyc-flow`: clients get an onboarding → documents → face-liveness verification flow with a Skip-for-now escape hatch and `customer`-role submission to the KYC API.

### Modified Capabilities
- `user-auth`: post-auth routing now includes a KYC checkpoint — `checkProfileStatus` returns `needs_kyc` for clients with a complete profile whose KYC is neither submitted nor skipped.
- `profile-settings-ui`: the Profile hero action pill becomes conditional on profile-completion and verification state (complete/verify-now/none + verified badge).

## Impact

- **Code**: `lib/pages/signin/signin_widget.dart`, `lib/pages/create_profile/*`, `lib/pages/onboarding/*`, `lib/pages/language_settings/*`, `lib/main.dart` (`_supportedLocales`), `lib/l10n/*` (new `app_fil.arb` + regenerated), `lib/app_state.dart`, `lib/main/profile/profile_widget.dart`, `lib/auth/post_auth_navigation_flow.dart`, `lib/router/app_router.dart` (new KYC routes), three new `lib/pages/kyc_*` pages and models, `lib/services/kyc_*_service.dart` (customer-role submission), `test/` (auth-flow, kyc, new widget tests).
- **APIs**: `ShphKycApi` (`submitKycDocs` with `submitterRole: 'customer'`, `skipKyc`, `requestLivenessChallenge`) — contracts already exist, no backend change.
- **Dependencies**: none new — reuse existing `camera`, `image_picker`, `intl`, `flutter_localizations`.
- **Behavior**: `supportedLocales` narrows from 10 → `[en, fil]`; Settings language list narrows to the same two.