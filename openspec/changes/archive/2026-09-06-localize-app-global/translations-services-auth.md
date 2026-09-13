# Task 4.3 — lib/services + lib/auth localization (DRAFT)

Scope approved by user: **live strings only** (skip dead-code earnings_service / pro_bookings tmStageLabel), **generic localized messages** (drop raw exception text), **localize wallet tx strings + intl dates**.

Files in scope:
- `lib/services/error_handler.dart` (main hotspot — statics used app-wide)
- `lib/auth/auth_util.dart`
- `lib/auth/post_auth_navigation_flow.dart`
- `lib/services/payment_controller.dart`
- `lib/services/wallet_service.dart`

Excluded (per triage + prior user decisions):
- **nearby_pro_mock_data.dart** `_formatDistance` (`'X m away'`/`'X km away'`) — wire distance label format, excluded by prior user scope; rendered with localized `svDistanceUnknown` fallback already in place.
- Raw backend/DRF messages surfaced verbatim by `describeError` (server-owned, not translatable in-app).
- Stripe `e.error.localizedMessage` (SDK already device-localized).
- Dead code: `earnings_service.dart` (getEarningsSummary never called), `pro_bookings_service.dart` `tmStageLabel` (never called).
- 42 service files (log-only/backend/data) — clean.
- `tm_controller.dart` (TMFlowController) — already localized via `l10n?.tmXxx ?? fallback`; all keys exist.

## Reused existing keys (no new key needed)
- `retry` → ErrorHandler.showError default action label
- `ccOK` → ErrorHandler.showErrorDialog default action label
- `ccConfirm` → ErrorHandler.showConfirmDialog confirm label
- `ccCancel` → ErrorHandler.showConfirmDialog cancel label
- `bpPaymentFailed` → payment_controller generic payment failure (rendered via `result.errorMessage ?? _l10n.bpPaymentFailed`)
- `pfProviderDetected` → post_auth provider-notice dialog title

## New keys (append to both ARBs after the 4.2 block)

Prefix `eh*` = error_handler, `au*` = auth_util, `pan*` = post_auth_navigation_flow, `pmt*` = payment_controller, `wt*` = wallet_service.

### error_handler.dart (`eh*`)
| key | EN | FIL (Taglish) |
|---|---|---|
| `ehConnectionError` | Cannot reach the server. Check your internet connection and try again. | Hindi maabot ang server. I-check ang internet connection mo at subukan muli. |
| `ehGenericError` | Something went wrong. Please try again. | May nangyaring mali. Subukan muli. |
| `ehInvalidFormat` | Invalid format. Please try again. | Hindi valid na format. Subukan muli. |
| `ehInvalidArgument` | Invalid input. Please try again. | Hindi valid na input. Subukan muli. |

### auth_util.dart (`au*`)
| key | EN | FIL (Taglish) |
|---|---|---|
| `auSignOutError` | There was a problem signing you out. Please try again. | Nagkaproblema sa pag-sign out. Subukan muli. |
| `auVerificationEmailSent` | Verification email sent | Naipadala ang verification email |
| `auVerificationError` | There was a problem sending the verification email. Please try again. | Nagkaproblema sa pagpapadala ng verification email. Subukan muli. |

### post_auth_navigation_flow.dart (`pan*`)
| key | EN | FIL (Taglish) |
|---|---|---|
| `panProviderAppBody` | Provider tools have moved to the Serbisyo Provider app. You can continue using this app as a client, or sign out. | Ang provider tools ay nasa Serbisyo Provider app na. Pwede kang magpatuloy dito bilang client, o mag-sign out. |
| `panSignOut` | Sign out | Mag-sign out |
| `panContinueAsClient` | Continue as client | Magpatuloy bilang client |
| `panNavigationError` | Navigation error. Please try again. | Nag-error sa navigation. Subukan muli. |

### payment_controller.dart (`pmt*`)
| key | EN | FIL (Taglish) |
|---|---|---|
| `pmtFailedObtainClientSecret` | Failed to obtain payment client secret | Nabigong makuha ang payment client secret |
| `pmtFailedObtainCheckoutUrl` | Failed to obtain checkout URL | Nabigong makuha ang checkout URL |
| `pmtPaymentFailed` | Payment failed | Nabigo ang pagbabayad |

### wallet_service.dart (`wt*`)
| key | EN | FIL (Taglish) |
|---|---|---|
| `wtUnknownService` | Unknown Service | Hindi kilalang Service |
| `wtClient` | Client | Client |
| `wtDebitDesc` | Payment to Provider — {serviceName} | Payment sa Provider — {serviceName} |
| `wtCreditDesc` | Service Payment — {serviceName} ({clientName}) | Payment ng Service — {serviceName} ({clientName}) |
| `wtDateNa` | N/A | N/A |

## Wiring plan

### error_handler.dart
Thread an `AppLocalizations l10n` parameter into the static methods that render defaults:
- `showError({ ..., AppLocalizations? l10n })` → `actionLabel ?? (l10n?.retry ?? 'Retry')`
- `showErrorDialog({ ..., AppLocalizations? l10n })` → default `actionLabel = l10n?.ccOK ?? 'OK'` (can't use default from optional; restructure default inside body)
- `showConfirmDialog({ ..., AppLocalizations? l10n })` → `confirmLabel`/`cancelLabel` default to `l10n?.ccConfirm`/`l10n?.ccCancel`
- `describeError(Object exception, { AppLocalizations? l10n })` → connection/generic branches use `l10n?.ehConnectionError`/`l10n?.ehGenericError`
- `handleException`/`_getErrorMessage` → since `handleException` is dormant (never called), localize `_getErrorMessage` with an `l10n` param using `ehInvalidFormat`/`ehInvalidArgument`; keep dormant.
- Make `connectionErrorMessage` const removed (or repurposed); update consumers of error_handler in signin/signup/phone_verify to pass `_l10n`.

Call sites to update (pass `_l10n`):
- `signin_widget.dart` 368/372, 611/615
- `signup_widget.dart` 340/344
- `phone_verify_user_widget.dart` 279, 405
(main.dart only touches `scaffoldMessengerKey`, no label change.)

### auth_util.dart
Thread `AppLocalizations l10n`:
- `signOutUser(BuildContext context, AppLocalizations l10n)` → error snackbar `l10n.auSignOutError`
- `verifyCurrentUserEmail(BuildContext context, AppLocalizations l10n)` → `l10n.auVerificationEmailSent` / `l10n.auVerificationError`
Find and update all callers of `signOutUser` and `verifyCurrentUserEmail` to pass `_l10n`.

### post_auth_navigation_flow.dart
- `_showProviderNotice(BuildContext context)` → add `final l10n = AppLocalizations.of(context)!;` use `l10n.pfProviderDetected`, `l10n.panProviderAppBody`, `l10n.panSignOut`, `l10n.panContinueAsClient`; de-const the dialog Texts.
- Nav error snackbar (line 151-156) → `l10n.panNavigationError`; de-const.

### payment_controller.dart
Thread `AppLocalizations l10n` into `processStripePayment` and `processMayaPayment` so `errorMessage` is localized at call time:
- `pmtFailedObtainClientSecret` / `pmtFailedObtainCheckoutUrl`
- Stripe catch → use `e.error.localizedMessage ?? l10n.pmtPaymentFailed`
- generic catch → `l10n.pmtPaymentFailed` (drop `e.toString()`)
Callers: `booking_payment_widget.dart` (110, 131) + `live_matching_screen.dart` (748-749) — both have `_l10n`; pass it.

### wallet_service.dart
Thread `AppLocalizations l10n` + locale for dates:
- `getWalletData(AppLocalizations l10n)` → pass to `_txFromBooking`
- `_txFromBooking(booking, type, l10n)` → `wtUnknownService`, `wtClient`, `wtDebitDesc`/`wtCreditDesc`
- `_formatDate(dateStr, l10n)` → use `intl` `DateFormat` with locale from `Localizations.localeOf` — but no context in service. **Thread a `String locale` (or `Locale`) param** into `getWalletData` from the caller (`wallet_model.dart` has access? it's async). Use `AppLocalizations.of` via context in `wallet_model` or pass `widget` locale. Use `DateFormat('MMM d, y', locale)` with `initializeDateFormatting` (already set up in Task 4.1). Fallback `l10n.wtDateNa` for null/invalid.
- Caller `wallet_model.dart:16` → pass `_l10n` (resolve from context) + locale.

> Note on intl dates: `wallet_model` is a `FlutterFlowModel` with `Context` access. We'll obtain locale via `Localizations.localeOf(context)` there and thread it. Month abbreviations come from `DateFormat` locale automatically (en/fil).

## Open verification
- Confirm all `signOutUser`/`verifyCurrentUserEmail` callers identified for the l10n param addition.
- Confirm `wallet_model` has `context`/`_l10n` access for threading locale.
- Confirm `live_matching_screen` line ~748 has `_l10n` available.
- `flutter gen-l10n` clean + `flutter analyze` 0 errors after wiring.
