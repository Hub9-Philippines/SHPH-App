## Why

The app already has a working English/Filipino locale system (`AppLocalizations`, `app_fil.arb`, `supportedLocales: [en, fil]`, live switching via `FFAppState.locale`), but only a tiny fraction of the UI text is actually wired through it. Roughly **823 hardcoded English strings** remain scattered across ~130 files (pages, shared components, bottom tabs, services, auth, helpers). So when a user selects Filipino, most buttons, labels, empty-states, errors, dialogs, and toasts still render in English — the language toggle appears broken. This change makes localization global: every user-facing string flows through `AppLocalizations` and gets a Filipino (Tagalog) translation, so the selected language actually applies app-wide.

## What Changes

- **Localize every hardcoded user-facing string** (~823) across `lib/pages/*`, `lib/main/*`, `lib/components/*`, `lib/services/*`, `lib/auth/*`, and standalone helpers: add a key to `app_en.arb` (and matching `app_fil.arb`) and reference it via `AppLocalizations` in the widget, model, or util.
- **Remove all hardcoded UI text from widgets/models**: replace inline string literals passed to `Text`, labels, placeholders, tooltips, `SnackBar`/toast messages, dialog titles/actions, semantic labels, and error messages with `context.l10n.*` / `AppLocalizations.of(context)` lookups. Pure-implementation literals (keys, URLs, enum wire values, formatting strings like currency symbols) are excluded.
- **Complete Filipino (`fil`) coverage**: every new/localized key gets a Tagalog translation in `app_fil.arb` so a 100% match with `app_en.arb` is maintained. English keys also remain, keeping `en` as the fallback base.
- **Preserve existing behavior**: locale selection, live switching, and `en`/`fil` restriction are unchanged; only coverage expands.
- **Review-gated translation workflow**: Filipino wording is recorded in screen-sized batches and reviewed/corrected by the user before finalizing each batch in `app_fil.arb` (see design.md).
- **No behavior, routing, or API changes** — this is a localization coverage change only.

## Capabilities

### New Capabilities
- `global-localization-coverage`: every user-facing string in the app is routed through Flutter l10n (`AppLocalizations` + ARB) with complete English and Filipino translations, so the selected locale applies across all screens, components, toasts, dialogs, and errors.

### Modified Capabilities
- `profile-settings-ui`: the Settings and language-selection surfaces already ship localized, but consolidate on the fully-populated ARB set introduced here (adding any settings strings that were previously hardcoded).

## Impact

- **Code**: `lib/l10n/app_en.arb` and `app_fil.arb` (large key additions), `lib/l10n/app_localizations*.dart` (regenerated via `flutter gen-l10n`), and string literals throughout ~130 files in `lib/pages/`, `lib/main/`, `lib/components/`, `lib/services/`, `lib/auth/`, `lib/app_state.dart`, `lib/utils/`.
- **APIs**: none — no backend or DTO changes.
- **Dependencies**: none new — reuses existing `flutter_localizations`, `intl`, and the current `AppLocalizations` delegate wiring.
- **Behavior**: selecting Filipino now localizes all app text instead of only a subset; English remains fully covered as the fallback base locale.
- **Verification**: `flutter analyze` stays at 0 errors; `flutter gen-l10n` regenerates delegates; a smoke pass via the debug build confirms the Filipino locale renders translated text across representative screens.
