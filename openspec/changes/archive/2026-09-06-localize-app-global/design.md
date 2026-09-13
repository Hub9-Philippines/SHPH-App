## Context

See proposal.md — Why. The app already runs full Flutter l10n: `l10n.yaml` points at `lib/l10n` with `app_en.arb` as the template; `app_fil.arb` ships parallel Filipino translations; `lib/main.dart` restricts `supportedLocales` to `[en, fil]` and live-switches via `FFAppState.locale`. Localized screens follow a single convention (`AppLocalizations.of(context)!`, often bound as `final l10n = ...` or an `_l10n => AppLocalizations.of(context)!` getter) — see `kyc_onboarding_widget.dart`, `create_profile_widget.dart`, `profile_widget.dart`. The gap is coverage: only a small fraction of the ~823 hardcoded English strings are wired to l10n at all.

Constraints that shape the approach:
- `AppLocalizations.of(context)` needs a `BuildContext`, so strings rendered by widgets are easy, but strings shown from FlutterFlow-style models and service-layer toasts must thread a context/localizations instance in.
- Nothing in this change touches routing, API, or behavior — it is a coverage + translation pass only.
- The user reviews every Filipino translation in screen-sized batches before it is finalized.

## Goals / Non-Goals

**Goals:**
- Move all ~823 hardcoded user-facing strings into `app_en.arb` (and `app_fil.arb`) and reference them via `AppLocalizations`, so selecting Filipino localizes the whole app.
- Keep `en` as the complete fallback base; maintain exact key parity between `app_en.arb` and `app_fil.arb`.
- Preserve the existing live-switch and `en`/`fil`-only behavior untouched.
- Establish a repeatable review loop so the user can correct each batch of Filipino wording.
- End with `flutter analyze` at 0 errors and a smoke-tested `fil` locale.

**Non-Goals:**
- Adding new locales beyond `en`/`fil`.
- Backend, routing, data-model, or API changes.
- Redesigning UI, copy, or layout (only the language of existing text changes).
- Localizing non-displayed implementation strings (wire values, enum codes, API keys, currency/format symbols, internal identifiers).

## Decisions

**D1 — Mechanism: use the existing `AppLocalizations.of(context)` convention.**
Every display string resolves through `AppLocalizations.of(context)!`. In widget `build()` methods this mirrors current code (`final l10n = AppLocalizations.of(context)!` or an `_l10n` getter). Rationale: it is the established, working pattern and requires no new dependency or architectural change. Alternative considered: an `intl`-based global service — rejected because it would diverge from the codebase and fight Flutter's delegate-controlled locale changes.

**D2 — Threading localization into models/service toasts.**
Where a model method or non-widget code currently throws a `SnackBar`/dialog with a literal, accept a `BuildContext` (or an `AppLocalizations`/`l10n` instance) as a parameter at the call site, then look up the string before showing it. Rationale: matches how `kyc_face_liveness_widget.dart` already localizes its error toasts by reading `AppLocalizations.of(context)` in the widget and passing localized values down. Alternative: a `GetIt`/global registry of the current locale — rejected as a broader pattern change not needed here.

**D3 — Categorize literals before editing.**
Run a lift so each inline string is triaged: (a) **localize** — anything rendered or presented to the user (labels, buttons, placeholders, titles, subtitles, empty states, success/error toasts, confirmations, tooltips, semantic labels); (b) **exclude** — implementation literals not shown to the user (API wire values, enum/catalogue codes, storage keys, currency symbols, regex/format templates, debug-only text). Only category (a) becomes an ARB key. Rationale: avoids polluting the ARB with non-localizable data and keeps the diff reviewable.

**D4 — ARB key naming.**
Group keys by feature using a short prefix and descriptive snake_case — e.g. `bookingFunnel_*`, `tmFlow_*`, `addressForm_*` — falling back to the existing unprefixed naming (e.g. `settings`, `languageSubtitle`) for keys that already exist. Plurals/placeholders follow the existing ARB conventions already used in the repo (`pendingRequests` / `pendingRequests_plural`, `progressComplete` with a `{percent}` placeholder and `@progressComplete` metadata). Rationale: keeps the large ARB navigable by screen and consistent with existing entries.

**D5 — Parallel ARB authoring + regeneration.**
Add each English key to `app_en.arb` and the matching Filipino key to `app_fil.arb` in the same pass, then run `flutter gen-l10n` to regenerate `app_localizations*.dart`. Rationale: never leaves a key half-defined; `flutter gen-l10n` fails loudly on placeholder/metadata mismatches, catching drift early.

**D6 — Review-gated Filipino batches.**
Implementation is ordered screen by screen (largest string counts first). After drafting the Tagalog wording for a screen's keys, present the batch to the user as a review table (English → proposed Filipino); apply their corrections; only then finalize that batch in `app_fil.arb` and move on. Rationale: satisfies the user's explicit requirement to review and correct every translation while keeping editing practical at this scale.

## Risks / Trade-offs

- **Huge mechanical diff (~130 files, ~823 strings)** → Mitigate by processing in screen-sized batches with `flutter gen-l10n` + `flutter analyze` after each batch; each batch merges cleanly and is independently reviewable.
- **Accidental over-localization** (converting non-displayed literals, e.g. enum wire values) → Mitigate with the D3 triage step and grep audits (`lib/l10n`-scoped) that confirm only display strings changed.
- **Placeholder/metadata drift between `en`/`fil` breaking `gen-l10n`** → Mitigate via D5 (edit both files in the same pass and regenerate immediately) and parity check that both ARBs define the same key set.
- **User-fatigue from ~823 per-string reviews** → Mitigate via batched review (D6); batches are grouped and pre-filtered to genuine translation candidates so review is fast.
- **Service/model toasts lack a `BuildContext`** → Mitigate with D2 (thread context/localizations at the call site) and keep display concerns inside widgets where feasible.

## Migration Plan

This is a local, app-only localization pass:
1. Author ARB keys and translations in screen-sized batches, regenerating delegates and running `flutter analyze` after each.
2. Verify `fil` on device/emulator via a debug build for representative screens (Settings, Explore/Home, a booking-flow screen, a toast path).
3. No backend rollout, no feature flags, no data migration. Rollback = revert the ARB/widget edits (diff is isolated to `lib/l10n/` and display literals).
