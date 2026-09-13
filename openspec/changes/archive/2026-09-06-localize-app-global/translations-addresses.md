# Task 3.13 — `addresses` + `geographic_selection` + `pin_location` Localization (Final CSV)

User-approved Taglish values. Keys appended to both `app_en.arb` and `app_fil.arb` before `plNoLocation` (last key).

## `addresses` — `ad*`

| Key | English (final) | Filipino/Taglish (final) |
|-----|-----------------|--------------------------|
| adTitle | Addresses | Addresses |
| adAddNewAddress | Add new address | Magdagdag ng bagong address |
| adNoAddressesYet | No saved addresses yet | Wala pang saved addresses |
| adEmptySubtitle | Add your home, work, or favorite places so booking is faster | Idagdag ang home, work, o favorite places mo para mas mabilis mag-book. |
| adSavedAddress | Saved address | Saved address |
| adEdit | Edit | I-edit |
| adSetAsDefault | Set as default | I-set bilang default |
| adDelete | Delete | I-delete |
| adDefault | Default | Default |
| adSelected | Selected | Selected |
| adErrorSetDefault | Error setting default address | Error sa pag-set ng default address |
| adDefaultUpdated | Default address updated | Na-update na ang default address |
| adErrorSetDefaultDetail | Error setting default address: {error} | Error sa pag-set ng default address: {error} |
| adDeleteTitle | Delete address | I-delete ang address |
| adDeleteConfirm | Are you sure you want to delete {label}? | Sigurado ka bang gusto mong i-delete ang {label}? |
| adDeletedSuccess | Address deleted successfully | Successfully na-delete ang address |
| adErrorDeleteDetail | Error deleting address: {error} | Error sa pag-delete ng address: {error} |
| adSelectedForBookings | {label} selected for bookings | {label} ang napili para sa bookings |

## `geographic_selection` — `ge*`

| Key | English (final) | Filipino/Taglish (final) |
|-----|-----------------|--------------------------|
| geSearch | Search... | Maghanap... |
| geNoItemsFound | No items found | Walang nahanap |
| geTitleRegion | Select Region | Pumili ng Region |
| geTitleProvince | Select Province | Pumili ng Province |
| geTitleCity | Select City/Municipality | Pumili ng City / Municipality |
| geTitleBarangay | Select Barangay | Pumili ng Barangay |

## `pin_location` — `pl*`

| Key | English (final) | Filipino/Taglish (final) |
|-----|-----------------|--------------------------|
| plSearchLocation | Search a location | Maghanap ng lokasyon |
| plSubmit | Submit | Submit |
| plNoLocation | Please select a location on the map | Pumili ng lokasyon sa mapa |

## Notes
- Widgets wired: `addresses_widget.dart` (all `ad*`, incl. SnackBars, delete dialog, error details with `{error}` placeholders), `geographic_selection_widget.dart` (`ge*`; added a `_getTitle` widget method that reads from `AppLocalizations` — the model's `getTitle` stays unused), `pin_location_widget.dart` (`pl*`).
- Pre-existing bug fixed in Task 3.13: 3 `PopupMenuItem`s in `addresses_widget.dart` used `const` while reading `_l10n` — de-const'd.

## Verification
- `flutter gen-l10n`: clean (802 es untranslated — expected)
- `flutter analyze`: 0 errors
