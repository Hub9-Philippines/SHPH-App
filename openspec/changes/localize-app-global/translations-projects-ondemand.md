# Task 3.15 — `project_create` + `project_detail` + `project_list` + `on_demand_booking` + `dispatch` + `client_ondemand_jobs` Localization (Final CSV)

User-approved Taglish values. Keys appended to both `app_en.arb` and `app_fil.arb` after `ckSent` (last keys: `cjStatusCancelled`).

Note: **`dispatch` has no dedicated UI widget.** Its dispatch UI lives in the tm_flow screens (localized in Task 3.2), and `dispatch_repository.dart` contains only logging-only strings, an internal thrown `StateError`, and backend-persisted metadata — all D3-excluded. So this batch covers the 5 widgets that render UI.

## `project_create` — `pc*`

| Key | English (final) | Filipino/Taglish (final) |
|-----|-----------------|--------------------------|
| pcTitle | Create Project | Gumawa ng Project |
| pcLabelTitle | Title | Title |
| pcLabelDescription | Description | Description |
| pcLabelCategory | Category | Category |
| pcB2B | B2B Project | B2B Project |
| pcFailedCreate | Failed to create project | Hindi na-create ang project |

Category dropdown options (Cleaning/Plumbing/Electrical/Handyman) intentionally left as English loanwords to keep 1:1 parity with backend category IDs (per user decision).

## `project_detail` — `pd*`

| Key | English (final) | Filipino/Taglish (final) |
|-----|-----------------|--------------------------|
| pdTitle | Project Details | Project Details |
| pdProjectNotFound | Project not found | Hindi nahanap ang project |
| pdRoleLines | Role Lines | Role Lines |
| pdNoProspects | No prospects yet | Wala pang prospects |
| pdQuoteGenerated | Quote generated | Na-generate na ang quote |
| pdFailed | Failed | Failed |
| pdGenerateQuote | Generate Quote | Mag-generate ng Quote |
| pdCancelProject | Cancel Project | I-cancel ang Project |
| pdBudget | Budget: {min} - {max} | Budget: {min} - {max} |
| pdHeadcount | Headcount: {count} | Headcount: {count} |
| pdExpires | Expires: {date} | Mag-e-expire sa: {date} |
| pdScore | Score: {score} | Score: {score} |

## `project_list` — `pl*` + shared project status

| Key | English (final) | Filipino/Taglish (final) |
|-----|-----------------|--------------------------|
| plProjects | Projects | Projects |
| plNoProjects | No projects yet | Wala pang projects |
| plCreateProject | Create a Project | Gumawa ng Project |
| pjStatusDraft | Draft | Draft |
| pjStatusQuoted | Quoted | Quoted |
| pjStatusMatching | Matching | Matching |
| pjStatusCommitted | Committed | Committed |
| pjStatusCancelled | Cancelled | Cancelled |
| pjStatusExpired | Expired | Expired |

The `pjStatus*` keys are shared between `project_list` and `project_detail` `_statusLabel` methods.

## `on_demand_booking` — `ob*`

| Key | English (final) | Filipino/Taglish (final) |
|-----|-----------------|--------------------------|
| obTitle | On-Demand Booking | On-Demand Booking |
| obSubtitle | Get help when you need it | Humingi ng tulong kapag kailangan mo |
| obWhenNeed | When do you need service? | Kailan mo kailangan ang service? |
| obOptionNow | Now | Ngayon |
| obOptionToday | Today | Ngayong araw |
| obOptionTomorrow | Tomorrow | Bukas |
| obOptionThisWeek | This Week | Ngayong linggo |
| obPreferredTime | Preferred Time | Preferred Time |
| obBookingSummary | Booking Summary | Booking Summary |
| obFeeService | Service Fee | Service Fee |
| obFeeUrgency | Urgency Fee | Urgency Fee |
| obFeeServiceCharge | Service Charge | Service Charge |
| obTotal | Total | Total |
| obConfirmBooking | Confirm Booking | I-confirm ang Booking |

Excluded per D3: `₱` amounts and currency templates, and the `8:00 AM - 10:00 AM`-style time-slot range templates.

## `client_ondemand_jobs` — `cj*`

| Key | English (final) | Filipino/Taglish (final) |
|-----|-----------------|--------------------------|
| cjTitle | My On-Demand Jobs | On-Demand Jobs Ko |
| cjNoJobs | No on-demand jobs yet | Wala pang on-demand jobs |
| cjResume | Resume | Ipagpatuloy |
| cjGeneral | General | General |
| cjProvider | Provider | Provider |
| cjFee | Fee: {fee} | Fee: {fee} |
| cjBids | {count} bid(s) | {count} bid(s) |
| cjStatusSearching | Searching | Searching |
| cjStatusAccepted | Accepted | Accepted |
| cjStatusExpired | Expired | Expired |
| cjStatusCancelled | Cancelled | Cancelled |

## Notes
- Widgets wired: `project_create_widget.dart`, `project_detail_widget.dart`, `project_list_widget.dart`, `on_demand_booking_widget.dart`, `client_ondemand_jobs_widget.dart`.
- Placeholder methods used: `pdBudget(min, max)`, `pdHeadcount(count)`, `pdExpires(date)`, `pdScore(score)`, `cjFee(fee)`, `cjBids(count)`.
- `on_demand_booking` was a `const ScreenHeader(...)` — de-const'd to read `_l10n`.
- `dispatch_repository.dart` provider-profile fallback labels (`Provider`/`Service Provider`/`Service unit` etc.) are service-layer user-facing strings — noted for Task 4.3, out of 3.15 scope.

## Verification
- `flutter gen-l10n`: clean (es untranslated — expected)
- `flutter analyze`: 0 errors
