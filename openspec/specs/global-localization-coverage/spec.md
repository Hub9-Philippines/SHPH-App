# global-localization-coverage Specification

## Purpose

Ensures every user-facing string in the app is routed through Flutter l10n with complete English and Filipino (Tagalog) translations, so the selected locale applies consistently across all screens, components, dialogs, toasts, and errors.

## Requirements

### Requirement: All user-facing text is localized
Every string rendered to or presented to the user — buttons, labels, placeholders, section titles, empty states, success/error toasts, dialog titles and actions, confirmations, tooltips, and screen-reader semantic labels — SHALL be sourced from the localization resources (`AppLocalizations`) rather than hardcoded as inline string literals in widgets, models, or view logic.

#### Scenario: Filipino locale renders translated text
- **WHEN** the app locale is set to Filipino (`fil`)
- **THEN** every visible user-facing string on the current screen is displayed using its Filipino translation rather than English

#### Scenario: English locale renders translated text
- **WHEN** the app locale is set to English (`en`)
- **THEN** every visible user-facing string is displayed using its English translation

### Requirement: No hardcoded user-facing strings remain
The localization coverage SHALL span the pages, bottom-tab screens, shared components, service-layer toasts, and auth/helper messages in the codebase. Aside from non-displayed implementation literals (wire values, API keys, enum codes, formatting/currency symbols, internal identifiers), no inline English string used for display SHALL remain.

#### Scenario: Audit finds no remaining display literals
- **WHEN** a review scans source files for inline display string literals outside localization resources
- **THEN** no such remaining literals are found except declared non-displayed implementation strings

### Requirement: Complete parallel ARB coverage
For every locale key defined, the English (`app_en.arb`) and Filipino (`app_fil.arb`) resources SHALL each define a translation, keeping the two files in parity so a locale switch never falls back to an untranslated string.

#### Scenario: Key exists in both locale files
- **WHEN** a new localization key is added to `app_en.arb`
- **THEN** the same key with a Filipino translation exists in `app_fil.arb`

### Requirement: Locale switching and restriction preserved
The existing language selection and live-switching behavior SHALL continue to work exactly as before: only `en` and `fil` remain available and supported, and changing the language applies the new locale to the running app without a restart.

#### Scenario: Live switch applies app-wide
- **WHEN** the user changes language from within the app while it is running
- **THEN** the visible UI updates to the newly selected language across all screens immediately

### Requirement: Filipino wording is reviewable
Translation wording for the Filipino locale SHALL be produced in reviewable, screen-sized batches and incorporate user corrections before the Filipino resource is finalized.

#### Scenario: Corrections applied to a batch
- **WHEN** the user reviews a screen-sized batch of Filipino translations and requests changes
- **THEN** the Filipino resource reflects those corrections before the batch is considered complete
