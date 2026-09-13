# Address Form - Filipino (Taglish) Strings

Screen: `lib/pages/address_form/`

Batch status: **approved & wired** (Task 3.3 done, `flutter analyze` = 0 errors)

All strings below are present in both `app_en.arb` and `app_fil.arb` and wired through `AppLocalizations`. `{e}` marks an interpolated error placeholder.

## Screen / section headings

| Key | English | Approved Taglish |
|-----|---------|------------------|
| afEditAddress | Edit address | I-edit ang address |
| afNewAddress | New address | Bagong address |
| afContactInformation | Contact Information | Contact Information |
| afAddressDetails | Address Details | Address Details |
| afPinLocation | Pin Location | Pin Location |

## Contact Information fields

| Key | English | Approved Taglish |
|-----|---------|------------------|
| afFullName | Full name | Buong pangalan |
| afEnterFullName | Enter your full name | Ilagay ang buong pangalan mo |
| afErrorFullName | Please enter your full name | Pakilagay ang buong pangalan mo |
| afMobileNumber | Mobile number | Mobile number |
| afErrorMobileNumber | Please enter your mobile number | Pakilagay ang mobile number mo |
| afErrorValidMobile | Please enter a valid mobile number | Pakilagay ng wastong mobile number |

## Address Details fields

| Key | English | Approved Taglish |
|-----|---------|------------------|
| afStreetAddress | Street address | Street address |
| afHouseUnitStreet | House/Unit number, Street name | House/Unit number, Pangalan ng street |
| afErrorStreetAddress | Please enter your street address | Pakilagay ang street address mo |
| afPostalCode | Postal code | Postal code |
| afEnterPostalCode | Enter postal code | Ilagay ang postal code |
| afSetAsDefault | Set as default address | Itakda bilang default address |
| afUpdateAddress | Update address | I-update ang address |
| afSaveAddress | Save address | I-save ang address |

## Region / Province / City / Barangay

| Key | English | Approved Taglish |
|-----|---------|------------------|
| afRegion | Region | Region |
| afSelectRegion | Select region | Pumili ng region |
| afProvince | Province | Province |
| afSelectProvince | Select province | Pumili ng province |
| afCityMunicipality | City/Municipality | City/Municipality |
| afSelectCity | Select city/municipality | Pumili ng city/municipality |
| afBarangay | Barangay | Barangay |
| afSelectBarangay | Select barangay | Pumili ng barangay |
| afSelectBarangayTitle | Select Barangay | Pumili ng Barangay |
| afSearchBarangay | Search barangay... | Maghanap ng barangay... |
| afNoBarangays | No barangays available for this city/municipality | Walang available na barangay para sa city/municipality na ito |
| afNoBarangaysFound | No barangays found | Walang nahanap na barangay |

## Location picker

| Key | English | Approved Taglish |
|-----|---------|------------------|
| afPinLocationOnMap | Pin location on map (optional) | I-pin ang location sa mapa (opsyonal) |
| afChange | Change | Baguhin |

## Toasts / snackbars

| Key | English | Approved Taglish |
|-----|---------|------------------|
| afAddressUpdated | Address updated successfully | Matagumpay na na-update ang address |
| afAddressAdded | Address added successfully | Matagumpay na naidagdag ang address |
| afAddressDeleted | Address deleted successfully | Matagumpay na natanggal ang address |
| afErrorSavingAddress | Error saving address | Error sa pag-save ng address |
| afErrorSavingAddressDetail | Error saving address: {e} | Error sa pag-save ng address: {e} |
| afErrorLoadingAddress | Error loading address: {e} | Error sa pag-load ng address: {e} |
| afErrorDeletingAddress | Error deleting address: {e} | Error sa pag-delete ng address: {e} |

## Delete confirmation dialog

| Key | English | Approved Taglish |
|-----|---------|------------------|
| afDeleteAddress | Delete address | I-delete ang address |
| afDeleteConfirm | Are you sure you want to delete this address? | Sigurado ka bang gusto mong i-delete ang address na ito? |
| afCancel | Cancel | I-cancel |
| afDelete | Delete | I-delete |

## Notes
- **Exclusions confirmed (stay English, backend/stored data):** label chips `Home` / `Work` / `Partner` / `Other` (`afLabel` = "Label"), and the address summary `Current device location` / `Pinned location` values shown in the preview — these are stored address data, not UI chrome.
- `afLabel` key added (word "Label") but the actual chip values are backend data and remain untranslated.
