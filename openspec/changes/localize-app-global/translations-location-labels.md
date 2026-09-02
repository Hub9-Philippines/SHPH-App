# Task 4.4 — lib/app_state location labels + render-site fallbacks (DRAFT)

Scope approved by user:
- **Exclude `lib/utils/`** — audit found no user-facing display copy (emergency_categories/category_assets/category_icons are functional match keys + icon/asset lookups; tagalog_service_keywords is functional search data). Audited only, no keys.
- **Widget-layer fix** for app_state location labels — branch on `selectedLocationMode == 'device'` → render `_l10n.hmCurrentDeviceLocation`; localize widget-side hardcoded fallbacks. `app_state.dart` source defaults left as-is (no BuildContext there).
- **Exclude demo data**: `'Metro Manila'` (proper noun), `'123 Example Street'` / `'Home'` BookingDraft defaults (production sample data).

## Reused existing keys (no new key needed)
- `hmCurrentDeviceLocation` → device-mode location label at all render sites (home, services, search_page, address_form)
- `bfPinnedLocation` → 'Pinned location' fallback (search_page, address_form)
- `hmPinnedAddress` / `svPinnedAddress` → 'Pinned address' fallback (search_page, services)
- `spAll` → 'All' category sentinel chip text (services)
- `adAddNewAddress` → 'Add new address' (edit_address)
- `adNoAddressesYet` → 'No addresses yet' (edit_address)
- `adDefault` → 'Default' badge (edit_address)
- `bfHome` → 'Home' label (unchanged; already localized — listed for completeness)

## New keys (append to both ARBs)
| key | EN | FIL (Taglish) |
|---|---|---|
| `hmSavedAddresses` | Saved addresses | Mga naka-save na address |
| `bfAddress` | Address | Address |

### Placeholder/metadata
- `hmSavedAddresses` and `bfAddress` are plain strings — no `@` placeholder blocks needed.

## Wiring plan

### 1. `lib/main/home/home_widget.dart`
- `_buildController` (304-307): when `selectedLocationMode == 'device'`, use `_l10n.hmCurrentDeviceLocation` for label (and `_l10n.hmPinnedAddress` line1) instead of the stored English `selectedAddressLabel`/`selectedAddressLine1`. Keep `'Metro Manila'` city (excluded).
- `_HomeLocationSheet._buildSavedSection` heading (373): `Text('Saved addresses')` → `Text(_l10n.hmSavedAddresses)`. (This `_HomeLocationSheet` has a build-local `_l10n`.)

### 2. `lib/main/services/services_widget.dart`
- `_buildLocationPill` (278-280, 298-308): when device mode, render `_l10n.hmCurrentDeviceLocation` instead of `selectedAddressLabel`.
- Booking controller build (743-751): device-mode branch → `_l10n.hmCurrentDeviceLocation` / `_l10n.svPaintedAddress`; keep `'Metro Manila'` city fallback.
- `_buildCategoryFilter` chip (520): the `'All'` sentinel inserts a raw `category` value displayed as `Text(category)`; map `category == 'All'` → `_l10n.spAll`. (line 424-426 non-'All' backend names still rendered directly → keep.)

### 3. `lib/pages/search_page/search_page_widget.dart` (922-930)
- Device-mode → `_l10n.hmCurrentDeviceLocation`; `'Pinned location'` fallback → `_l10n.bfPinnedLocation`; `'Pinned address'` fallback → `_l10n.hmPinnedAddress`; keep `'Metro Manila'`.

### 4. `lib/pages/booking_funnel/booking_flow_screen.dart` (384)
- `(result.addressLine2 ?? 'Address')` fallback → `(result.addressLine2 ?? l10n.bfAddress)`. (has `l10n`)

### 5. `lib/pages/booking_funnel/checkout/checkout_screen.dart` (203) + `widgets/express_checkout_sheet.dart` (850)
- `(result.addressLine2 ?? 'Address')` fallback → `(result.addressLine2 ?? _l10n.bfAddress)`.

### 6. `lib/components/edit_address/edit_address_widget.dart` (144, 172, 255)
- `Text('No addresses yet')` → `_l10n.adNoAddressesYet`
- FFButton `text: 'Add new address'` → `_l10n.adAddNewAddress`
- `Text('Default')` badge → `_l10n.adDefault`
- Also `'Address'` fallback (238) `address.addressLine2 ?? 'Address'` → `?? _l10n.bfAddress` (de-const if needed).

### 7. `lib/pages/address_form/address_form_widget.dart` (99, 160, 1121, 1211)
- `'Current device location'` assignments (99, 160) → `_l10n.hmCurrentDeviceLocation`.
- `'Pinned location'` fallbacks (1121, 1211) → `_l10n.bfPinnedLocation`.

## Exclusions recap
- All of `lib/utils/` (data, not display).
- `lib/api/`, `lib/backend/`, `lib/router/`, `lib/theme/`, `lib/models/` — backend/data/config, audited clean.
- `lib/flutter_flow/upload_data.dart` + `otp_rate_limiter.dart` + `lib/custom_code/` — latent/dead code (no consumers; some excluded from analysis). Audited, not wired.
- Demo data: `'Metro Manila'`, `'123 Example Street'`, `'Home'`.

## Open verification
- `flutter gen-l10n` clean + `flutter analyze` 0 errors after wiring.
- Confirm `edit_address_widget` has/build-local `_l10n` and no const traps.
