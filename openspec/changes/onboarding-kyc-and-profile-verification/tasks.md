## 1. Visibility & completion-page fixes

- [x] 1.1 Give `_SocialButton` icon + label an explicit `primaryText` foreground in `lib/pages/signin/signin_widget.dart` so Google/Apple text is legible on the light surface
- [x] 1.2 Replace the faint outlined "Add Photo" `AppButton` on the completion page with a filled primary pill (royal-blue, white bold label, auto-width) so it no longer reads as a blank field
- [x] 1.3 Split the completion form: `firstNameController` + `lastNameController` in `create_profile_model.dart`, prefilled from profile first/last with a `displayName`-split fallback; keep bio + photo
- [x] 1.4 Add a required-field progress indicator (first/last) and gate Finish until 100% on `create_profile_widget.dart`
- [x] 1.5 Submit web-parity payload on Finish via `updateProfile`: `first_name`, `last_name`, `display_name` (`"$first $last".trim()`), `bio_details`, `photo_url` (when present), `is_profile_complete: true`

## 2. Onboarding language selection

- [x] 2.1 Add a language-selection slide at index 0 of `lib/pages/onboarding/onboarding_widget.dart` with exactly English and Filipino cards; selecting sets `FFAppState().locale` immediately
- [x] 2.2 Trim `_languages` in `lib/pages/language_settings/language_settings_widget.dart` to English + Filipino only and update `_localeToName` fallback

## 3. Filipino localization

- [x] 3.1 Add `lib/l10n/app_fil.arb` mirroring all `app_en.arb` keys in Filipino
- [x] 3.2 Run `flutter gen-l10n` and confirm `fil` is generated + supported in `app_localizations.dart`
- [x] 3.3 Narrow `_supportedLocales` in `lib/main.dart` to `[en, fil]` and guard `_syncLocale` to fall back to `en` for any stored locale outside the two
- [x] 3.4 Localize all new/changed strings (onboarding language slide, KYC pages, completion labels) via `AppLocalizations` with keys added to both `app_en.arb` and `app_fil.arb`

## 4. Client KYC flow

- [x] 4.1 Add `lib/services/client_kyc_service.dart` wrapping `ShphKycApi`: normalized `status()` (incl. skipped), `skip()`, `requestLivenessChallenge()`, and `submit({idFront, idBack, selfie, challengeNonce?, livenessMetadata?, livenessScore?})` with `submitterRole: 'customer'`
- [x] 4.2 Add `lib/pages/kyc/kyc_onboarding_widget.dart` (+ model): docs checklist, "Start verification" → documents, "Skip for now" → `skip()` then Home
- [x] 4.3 Add `lib/pages/kyc/kyc_document_widget.dart` (+ model): ID front/back + selfie capture via `image_picker` (camera/gallery), previews, Continue enabled only when all three present, Skip for now
- [x] 4.4 Add `lib/pages/kyc/kyc_face_liveness_widget.dart` (+ model): server liveness challenge → `camera`-based guided capture → submit with nonce + metadata + score; local fallback plan on challenge failure (no nonce); Skip for now; success → Home
- [x] 4.5 Register `/kyc-onboarding`, `/kyc-documents`, `/kyc-liveness` routes in `lib/router/app_router.dart` and add them to the client-only allowed set

## 5. Post-auth gating & profile hub CTA

- [x] 5.1 Extend `checkProfileStatus` in `lib/auth/post_auth_navigation_flow.dart`: profile complete AND KYC `not_submitted` + not skipped → `needs_kyc`; route `needs_kyc` → `KycOnboardingWidget` in `handlePostAuthNavigation`
- [x] 5.2 Update `_buildHeroCard` pills in `lib/main/profile/profile_widget.dart`: incomplete → Complete CTA; complete + unverified → "Verify now" pill → KYC onboarding; verified → no action pill + verified badge; keep a secondary Edit Profile control in every state

## 6. Tests & verification

- [x] 6.1 Update `test/client_auth_flow_test.dart`: remove the `isNot('needs_kyc')` assertion; cover incomplete→`needs_profile`, complete+not_submitted→`needs_kyc`, complete+skipped/approved→`ready_home`
- [x] 6.2 Rework `test/create_profile_page_test.dart` for first+last name gate, progress, and computed `display_name`
- [x] 6.3 Add widget test for the onboarding language step (exactly 2 options; selecting applies locale) and 6.4 add `ClientKycService` payload test (`submitterRole: 'customer'` + web field names)
- [x] 6.5 Full `flutter analyze` (0 errors) + run all non-stale test files and `flutter gen-l10n` verification
- [ ] 6.6 Android smoke test via active `flutter run`: social buttons legible, completion page parity, onboarding language switch in real time, client KYC end-to-end, Profile hub Verify now → verified badge