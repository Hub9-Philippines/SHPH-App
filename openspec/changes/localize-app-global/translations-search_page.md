# Search Page - Filipino (Taglish) Strings

Screen: `lib/pages/search_page/`

Batch status: **approved & wired** (Task 3.7 done, `flutter analyze` = 0 errors, 699 total issues = baseline)

All strings below are present in both `app_en.arb` and `app_fil.arb` (keys prefixed `sp*`) and wired through `AppLocalizations`.

## Header / search bar

| Key | English | Approved Taglish |
|-----|---------|------------------|
| spHeaderTitle | Search | Search (kept) |
| spHeaderSubtitle | Browse services with filters that actually help. | Mag-browse ng services gamit ang filters na nakakatulong. |
| spSearchPlaceholder | Search for services... | Maghanap ng services... |

## Quick rail / filters

| Key | English | Approved Taglish |
|-----|---------|------------------|
| spAllServices | All services | Lahat ng services |
| spCategory | Category | Kategorya |
| spAll | All | Lahat |
| spMinRating | Minimum rating | Minimum rating (kept) |
| spPrice | Price | Presyo |
| spDefault | Default | Default (kept) |
| spLowToHigh | Low to High | Mababa papuntang Mataas |
| spHighToLow | High to Low | Mataas papuntang Mababa |
| spResetFilters | Reset filters | I-reset ang filters |
| spClearFilters | Clear filters | I-clear ang filters |

## Empty / no-results / suggestions

| Key | English | Approved Taglish |
|-----|---------|------------------|
| spEmptyTitle | Search for services | Maghanap ng services |
| spEmptySubtitle | Try keywords like cleaning, painting, or plumbing. | Subukan ang keywords tulad ng cleaning, painting, o plumbing. |
| spBrowseAllServices | Browse all services | I-browse ang lahat ng services |
| spRecentSearches | Recent searches | Kamakailang searches |
| spRecentBookings | Recent bookings | Kamakailang bookings |
| spNoServicesFound | No services found | Walang nahanap na services |
| spNoResultsSubtitle | Try another keyword, open a broader category, or clear your filters. | Subukan ang ibang keyword, pumili ng mas malawak na category, o i-clear ang filters mo. |
| spServiceFallback | Service | Serbisyo |

## Notes
- **Wiring:** `_l10n` State getter; `_SearchServiceCard` (separate StatelessWidget) reads `AppLocalizations.of(context)!.spServiceFallback` in its own build. `AppButton` children were de-const'd where needed.
- **Exclusions (D3):** Quick/rail category labels `Cleaning`/`Plumbing`/`Electrical`/`Painting` — they double as filter values compared against `service.categoryName` backend data, so they stay English (same as the back-end category codes). Rating chips (e.g. `4.0+`) numeric data. Price text `PHP {amount}`/`PHP 0` currency format. `Booking #{id}` recent-booking chip keeps English (`Booking` is a Taglish loanword; `#<id>` is data). Address fallbacks `Pinned location`/`Pinned address`/`Metro Manila` in `_openExpressCheckout` are booking-address defaults (backend/stored data path), consistent with the booking funnel. `LoggingService.error('Error loading recent bookings', ...)` and `'Error searching services', ...` are logging-only.
- `flutter analyze` = 0 errors; page-level `unused_import` (category_pill, content_container) + `directives_ordering` lints pre-existed.