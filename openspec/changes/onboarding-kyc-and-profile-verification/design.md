## Context

See proposal.md — Why. Current state (verified in the code):

- The "welcome" page is the merged sign-in screen (`lib/pages/signin/signin_widget.dart`), whose `_SocialButton` (lines 714–747) renders `Icon(icon)` + `Text(label)` with **no explicit color**. `AppButton` applies its resolved foreground only to the loading spinner and wraps children in a `DefaultTextStyle` without a color (`lib/components/cupertino_ui/app_button.dart:104-107`), so the label inherits the ambient text color and can end up invisible (white) on the light surface.
- The completion page (`lib/pages/create_profile/create_profile_widget.dart`) already has a circular 104px avatar preview. Below it sits an `AppButton` `outlined` variant ("Add Photo"), a transparent fill with a ~1.25px faint border — this is the "blank field that opens the gallery".
- The completion form is a single "Display name" field + optional bio; the web `CreateProfilePage.vue` uses photo + **first name + last name + bio** with a filled-fields progress bar and disabled submit until 100%.
- Locale machinery already supports real-time switching: `FFAppState.locale` → `_onAppStateChanged` → `_syncLocale` → `safeSetState` (`lib/main.dart:117,134-145`). What's missing is `fil` localization and narrowing `_supportedLocales` (currently 10) and the Settings list (currently 10 entries) to `en`/`fil`. Flutter's global delegates already ship `fil`.
- KYC exists only at the service/API layer (`lib/api/resources/kyc_api.dart`, `lib/services/kyc_*_service.dart`), provider-flavored (`submitterRole: 'provider'`). The client app has no KYC UI, no `needs_kyc` state, and `client_auth_flow_test.dart:26` even asserts `needs_kyc` never appears. `camera ^0.12.0` and `image_picker ^1.2.1` are already dependencies; Android already declares CAMERA/etc. permissions.

## Goals / Non-Goals

**Goals:**
- Restore legibility of the Google/Apple buttons and the photo-picker control.
- Match the web completion form (first + last name, progress) with the same backend payload.
- Ship an onboarding language-selection step offering exactly English/Filipino, fully localized, switching in real time.
- Ship a client KYC flow (onboarding → documents → face liveness) with Skip for now and `customer`-role submission, wired into post-auth routing and the Profile hub.
- Keep every phase green: `flutter analyze` 0 errors, non-stale tests pass.

**Non-Goals:**
- Localizing every hardcoded English string already in the app (huge, out of scope) — only the strings touched/newly introduced by this change (onboarding language step, KYC pages, completion page labels) are localized.
- Removing the legacy `es` ARB / generated delegate (kept in place but no longer advertised or selectable).
- Real liveness scoring on-device (server-side review is the source of truth; see Risks).
- Touching the provider KYC flow (`submitterRole: 'provider'` or `NBI/portfolio/resume`).

## Decisions

### D1. Social buttons: explicit `primaryText` foreground on icon + label
Set `Icon(..., color: theme.primaryText)` and `Text(label, style: textTheme ... copyWith(color: theme.primaryText))` inside `_SocialButton`. Root cause is AppButton not propagating `fg` to children, so we don't change the shared button's contract — this is a local, low-risk fix in `signin_widget.dart`.
*Alternative considered:* adding a `foregroundColor` param to `AppButton` that wraps children in a colored `DefaultTextStyle`. Rejected as higher blast radius; several call sites rely on current behavior.

### D2. Photo picker becomes an unmistakable filled pill
Replace the faint outlined "Add Photo" `AppButton` below the avatar with a compact **filled primary pill** (royal-blue fill, white bold label, auto-width). A filled pill can't read as a blank field, passes the Ahem-font test without the width:180 overflow issue hit earlier, and guarantees label contrast. Keep the circular preview + upload progress overlay exactly as-is.
*Alternative considered:* web-style caption under the circle. Rejected — the preview circle already communicates photo state; the pill is the affordance.

### D3. Web-parity completion form
- Model: replace `displayNameController` with `firstNameController` + `lastNameController`; prefill from profile `firstName`/`lastName`, falling back to splitting `displayName` on the first space.
- `display_name` sent to `updateMe` = `"$first $last".trim()`, along with `first_name`, `last_name`, `bio_details`, `is_profile_complete: true`, optional `photo_url`.
- Progress = fraction of required fields filled (first + last, each half). Finish enabled only at 100%.
- Reuses the existing `ProfilesService.updateProfile` path; no backend change.

### D4. Onboarding language selection = first page of the existing PageView
The existing `OnboardingWidget` is a 3-slide PageView → add a **language-selection slide at index 0** (2 selectable cards: English / Filipino). Selection sets `FFAppState().locale` immediately (real-time switch already wired), continues to the marketing slides and then sign-in, keeping `hasCompletedOnboarding` semantics. No new route needed.
*Alternative considered:* a separate `/choose-language` route before onboarding. Rejected — more router churn; PageView index 0 is cohesive.
- Also trim `language_settings` `_languages` to `[{en, English, EN}, {fil, Filipino, FIL}]` and update its `_localeToName` fallback.

### D5. Filipino locale + narrowing
- Add `lib/l10n/app_fil.arb` mirroring all ~101 `app_en.arb` keys in Filipino; run `flutter gen-l10n` (regenerates delegates; `isSupported` picks up `fil`).
- Trim `lib/main.dart` `_supportedLocales` to `[en, fil]` only.
- New/changed strings in this change are added to **both** `app_en.arb` and `app_fil.arb` under `@`-free simple keys and referenced via `AppLocalizations.of(context)`. Onboarding slides/sign-in strings stay hardcoded (out of scope).
- `es` ARB + generated files remain in place but are neither advertised in `supportedLocales` nor listed in pickers (zero-churn).
- If the stored locale is outside `{en, fil}` at startup, resolve to `en` (main.dart `_syncLocale` guard).

### D6. Client KYC flow: three new pages + a thin client service
New `lib/services/client_kyc_service.dart` (plain, stateless wrapper around `ShphKycApi`):
- `status()` → `KycHubService`-normalized status (`not_submitted/pending/approved/rejected`) + `skipped` flag.
- `skip()` → `ShphKycApi.skipKyc()`.
- `requestLivenessChallenge()` → `ShphKycApi.requestLivenessChallenge()`.
- `submit({idFront, idBack, selfie, challengeNonce?, livenessMetadata?, livenessScore?})` → `ShphKycApi.submitKycDocs` with `submitterRole: 'customer'` (web vocabulary) — mapping `customer` to the API's `submitter_role` field.

Pages (all under `lib/pages/kyc/`, FlutterFlow page+model pattern):
| Route | Widget | Behavior |
|---|---|---|
| `/kyc-onboarding` | `KycOnboardingWidget` | Lists required docs + why verify; primary "Start verification" → documents; "Skip for now" → `skip()` then Home |
| `/kyc-documents`  | `KycDocumentWidget` | Capture/upload ID front + ID back + selfie (`image_picker`, camera & gallery), previews each; Continue enabled only when all three present; Skip for now |
| `/kyc-liveness`   | `KycFaceLivenessWidget` | `requestLivenessChallenge()` → camera preview (`camera`) guided by the returned plan; capture → submit with nonce + metadata + score; on challenge failure run a local fallback plan (center face / blink / smile) without nonce; Skip for now; success → Home |

- Register routes in `app_router.dart` and add them to the client-only allowed set; register `CreateProfile` stage reuse is untouched.
- Submission success shows a banner and routes to Home; nothing recorded locally (backend is source of truth). If the user previously skipped (recorded server-side), post-auth does not force KYC again.

### D7. Post-auth `needs_kyc` checkpoint + profile-hub three-state CTA
- `checkProfileStatus(userId)` (in `post_auth_navigation_flow.dart`) becomes:
  1. profile incomplete → `needs_profile`;
  2. profile complete AND KYC `not_submitted` AND not skipped → `needs_kyc`;
  3. otherwise → `ready_home`.
  `handlePostAuthNavigation` routes `needs_kyc` → `KycOnboardingWidget`. Existing `ready_home` behavior unchanged.
  Note: routing only runs at post-auth (login/OTP) — it never force-redirects a user already inside the app, and Skip is always available, so no user can get trapped.
- `lib/main/profile/profile_widget.dart` `_buildHeroCard` pill logic:
  - `needsCompletion` (unchanged) → "Complete your profile" → CreateProfile;
  - else if `!verified` (`isVerified != true` and `verificationStatus != 'verified'`) → "Verify now" → `pushNamed(KycOnboardingWidget.routeName)`;
  - else (verified) → **no action pill**, `_VerificationBadge` rendered as verified.
  - A small secondary "Edit Profile" pencil control stays available in every state so editing remains reachable (per `profile-settings-ui` delta).

### D8. Tests
- Update `test/client_auth_flow_test.dart` (drop the `isNot('needs_kyc')` assertion; cover incomplete→`needs_profile`, complete+not_submitted→`needs_kyc`, complete+skipped/approved→`ready_home`).
- New widget tests: `create_profile_page` greenfield update (first/last gate + progress + `display_name` computed); onboarding language step (exactly 2 options, locale applied); client KYC service payload shape (`submitterRole: 'customer'`, field names); profile hero three-state pill selection.
- Keep `flutter analyze` at 0 errors (info-lint noise accepted per AGENTS.md).

## Risks / Trade-offs

- [Forcing KYC on login for every new client could annoy users] → only gated at post-auth when status is `not_submitted` and no skip recorded; "Skip for now" on every KYC screen; existing sessions are never redirected.
- [Mobile can't compute a trustworthy liveness score] → submit the server challenge nonce + capture metadata with a conservative placeholder score; backend review remains the decision maker (matches the existing `ekyc-verification` spec's "backend is source of truth" rule).
- [Filipino translation for ~101 keys may need a native review] → ship a faithful translation now; refine later (out of scope); `en` remains the template.
- [Shrinking `supportedLocales` from 10 to 2 changes behavior for users with a stored non-`en`/`fil` locale] → guard `_syncLocale` to fall back to `en`; pickers already show only the two options.
- [Camera/liveness flakiness on low-end devices] → `camera` package already in tree; keep capture lightweight, allow retake, expose Skip for now as the escape hatch.
- [Missed hardcoded strings on KYC/onboarding pages would break the Filipino switch] → all new-page labels go through `AppLocalizations`; task list includes a loc pass over the three new pages + language slide.
- [`client_auth_flow_test.dart` currently asserts `needs_kyc` never appears] → test updated in D8 as part of this change (not a regression).

## Migration Plan

Implement as phases, each ending with `flutter analyze` (0 errors) + relevant non-stale tests green:
1. Visibility + completion-page fixes (D1–D3).
2. Onboarding language selection + Settings list (D4).
3. Filipino ARB + `gen-l10n` + `supportedLocales` narrow + `_syncLocale` guard (D5).
4. Client KYC service + three pages + routes (D6).
5. Post-auth `needs_kyc` + profile-hub CTA + test updates (D7–D8).
6. Full `flutter analyze`, full non-stale test run, Android smoke test via `flutter run`, `flutter gen-l10n` verified.

Rollback: revert the failing phase's commits; each phase is independently revertable.

## Open Questions

None that would change specs, approach, or tasks.