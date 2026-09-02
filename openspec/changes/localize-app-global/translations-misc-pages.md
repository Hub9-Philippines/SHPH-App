# Task 3.17 — Misc Pages Batch (`eta_tracking` → `wallet`)

62 user-approved keys, appended to both `lib/l10n/app_en.arb` and `app_fil.arb` after `rcmBrowse`.

## Prefixes
- `et*` — eta_tracking (safe; pre-existing key `eta` is a distinct exact key)
- `ppf*` — provider_profile (`pp*` already used)
- `fav*` — favorites
- `subcat*` — subcategory (`sc*` risky: `scanQRCode`/`scheduled` pre-existing)
- `catd*` — category_detail
- `catg*` — categories (`cat*` collides with category words)
- `abc*` — ai_booking_composer
- `spl*` — splash (`sp*` taken)
- `nf*` — not_found
- `onb*` — onboarding (`ob*` taken by on_demand_booking)
- `kycCamera`/`kycGallery` — extended existing ky* family
- `wl*` — wallet

## Scope decisions (user-confirmed)
- **Onboarding**: slide titles/descriptions stay English; only the Skip/Next buttons localized (`onbSkip`, `onbNext`).
- **AI Booking Composer**: extracted-detail field labels (Service/Description/Budget/Date/Time/Location) stay English; only chrome localized (title, describe label, placeholder, analyzing/compose button, extract error, "Extracted Details" header).
- **Category grid names** (Cleaning/Plumbing/Electrical/Handyman) kept English as backend IDs.

## D3 exclusions honored
- `₱...` amounts, date/time/transaction descriptions (backend data) in wallet/favorites.
- AI composer detail data values (extracted from user input) and field labels (per user English).
- Route names (`routeName`, e.g. 'Wallet'/'Favorites') left untouched.
- Logging-only strings (ai_composer logging) excluded.

## Wiring (all 12 targets)
- `eta_tracking_widget.dart`, `provider_profile_widget.dart`, `favorites_widget.dart`
- `categories_widget.dart`(page) + **shared** `components/categories_widget/categories_widget.dart` (catgError/NoCategories/Instant dispatch/Open services/24-7)
- `subcategory_widget.dart`, `category_detail_widget.dart`
- `ai_booking_composer_widget.dart`, `splash_widget.dart`, `not_found_widget.dart`
- `onboarding_widget.dart` (Skip/Next only), `kyc_document_widget.dart` (Camera/Gallery — de-const'd list titles), `wallet_widget.dart` (de-const'd `ScreenHeader`)

`flutter gen-l10n` clean; `flutter analyze` 0 errors.
