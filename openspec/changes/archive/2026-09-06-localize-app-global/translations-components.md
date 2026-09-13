# Task 4.1 — Shared Components Batch (`lib/components/`)

67 user-approved keys, appended to both `lib/l10n/app_en.arb` and `app_fil.arb` after `wlSeeAll`.

## Prefix
- `cc*` — shared components. Verified collision-free (`comp*` collides with `completion*`/`completeYourProfile`).

## Scope decisions (user-confirmed)
- **Calendar dates** (`availability_calendar.dart`): month/year header + weekday headers converted from hardcoded English arrays to `DateFormat` with the app locale (`en`/`fil`) — **no ARB month/weekday keys**. Added `initializeDateFormatting('en'|'fil')` in `main()`.
- **`ccKmAway`** = `{km} km away` (kept "away"); the bare `"{n} km"` in `waiting_for_client_modal` left as wire distance format.
- **`ccPasswordLabel`** = "Password" in both en/fil (English loanword).
- **`ccDismiss`** (fil) = "Close".
- **`ccSelect`** = `Pumili ng {field}` function; wired as `_l10n.ccSelect(widget.label.toLowerCase())`.

## D3 exclusions honored
- Currency (`P ...`, `₱...`) in invoice_line_items / earnings_chart.
- Backend/enum codes (`total` label comparison, `completed`/`cancelled`/`canceled` in booking_action_row).
- Route names, logging-only strings, structural-only components (booking_card, service_card, empty_state, screen_header, status_pill — found free of hardcoded strings).

## Wiring (all display-bearing components)
- `auth_prompt_modal.dart`, `booking_action_row.dart`, `booking_step_indicator.dart`, `call_accept_permission_sheet.dart`, `connectivity_banner.dart`, `error_state.dart` (`title`→nullable + `effectiveTitle`), `hero_offer_banner.dart` (`title`/`highlight`→nullable + `effectiveHighlight`), `incoming_job_modal.dart`, `instant_dispatch_section.dart` (`static const` trap: `_windows`→`List<String>` codes + `windowLabels` list built in build; `window` strings are wire codes), `invite_earn_banner.dart` (`title`/`subtitle`/`shareLabel`→nullable), `invoice_line_items.dart`, `onboarding_overlay.dart`, `provider_map_view.dart` (dead code — never instantiated; still localized; moved overlay build to `didChangeDependencies` for safe l10n context), `provider_proximity_card.dart`, `provider_status_toggle.dart`, `quick_book_bar.dart`, `rich_chat_bar.dart`, `searchable_select.dart`, `section_header.dart` (`seeAllLabel`→nullable), `step_up_password_modal.dart`, `waiting_for_client_modal.dart`, `cupertino_ui/app_feedback.dart` (`okText`/`confirmText`/`cancelText`→nullable, resolved in-method), `cupertino_ui/app_pickers.dart`.

`flutter gen-l10n` clean; `flutter analyze` 0 errors (717 info baseline).
