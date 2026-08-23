# AGENTS.md

General behavioral guidelines for coding agents live in `CLAUDE.md`.

Flutter mobile app for the SerbisyoHub PH marketplace (clients ↔ service providers). Reference/parity target is the Vue 3 + Ionic web app at `E:\Dev\shph-web` — check it when adding pages or matching UI behavior.

## Backend reality (read before touching data/auth)

- **The SHPH REST API is the sole backend; Supabase was fully removed.** Default base URL `https://serbisyohubph.com` (override via `--dart-define=SHPH_API_BASE_URL`); OpenAPI spec in `SHPH API.yaml`. Do NOT add `supabase_*` imports, `SupaFlow`, or `.from('table')` calls — existing code uses `currentUser?.uid` + `Shph*Api` resources.
- `lib/api/api_config.dart` is the source of truth for backend wiring (`preferShphApi => true`). **`docs/api_gaps.md` and `README.md` are stale** (both still describe Supabase auth/backend) — don't trust them for data/auth facts.
- `lib/api/` is a **hand-written** Dio client (`resources/*_api.dart`, `shph_api_client.dart`). `tool/generate_api_client.ps1` is unused (its output dir `lib/api/generated/` doesn't even exist) — don't run it.
- Express backend lives in `backend/` (deployed separately; the Dart app never imports it).
- `lib/backend/supabase/` is legacy generated row classes — leave alone.

## Architecture

- Pages follow the FlutterFlow pattern: `lib/pages/<name>/<name>_model.dart` + `<name>_widget.dart` (75 page dirs).
- Bottom-tab pages + provider dashboard live in `lib/main/` (home, explore, category, bookings, messages, profile, pro_dashboard).
- Shared widgets in `lib/components/` (ScreenHeader, ServiceCard, StatusPill, etc.). Use these instead of inlining new UI.
- Routing: single `lib/router/app_router.dart` (GoRouter). State: `FFAppState()` (`lib/app_state.dart`) + `provider`; dedicated services in `lib/services/`.
- Theming: `AppTheme.of(context)` / `AppThemeData` in `lib/theme/app_theme.dart`. **Always use theme tokens, never hardcoded hex/`Colors.*`** (dark mode depends on it). Status pills via `AppThemeData.statusColors()`. Font is `GoogleFonts.plusJakartaSans()` — `GoogleFonts.poppins` is banned.
- `analysis_options.yaml` excludes `lib/custom_code/**` and `lib/flutter_flow/custom_functions.dart` from analysis.

## Commands

- `flutter analyze` — the bar is **0 errors** (~90 warnings + ~600 info lints are accepted noise). Never introduce new errors.
- Run tests per file: `flutter test test/booking_funnel_test.dart`. The **full suite fails** because `test/widget_test.dart` is stale FlutterFlow "Counter" boilerplate.
- `flutter build apk --release` — the phone-testing build. No release keystore yet; signed with the debug keystore.
- `flutter gen-l10n` — after editing `lib/l10n/*.arb` (en + es only).
- CI: `.github/workflows/flutter_build.yml` produces an Android APK artifact only (its iOS IPA job is commented out).

## Gotchas

- `pubspec.yaml` pins `dependency_overrides` (`google_api_headers 4.5.3`, `http 1.4.0`, `lints ^5.0.0`, `package_info_plus 8.0.2`, `rxdart 0.27.7`, `uuid ^4.0.0`) and a pinned git fork of `flutter_google_places` — don't casually bump these.
- After `flutter pub get`, generated platform files (`linux|windows|macos/flutter/generated_*`) show as modified in git — expected noise, don't commit them unless needed.
- Lint rules are strict (`always_declare_return_types`, `use_build_context_synchronously`, etc.) — code must pass `flutter analyze`.
- Branch workflow: current feature work happens on `feat/ui-ux-reconstruction`; `docs/ui-ux-reconstruction-plan.md` is the living status doc — update it when landing page/theme work.
- Structured change proposals live in `openspec/changes/` — use the openspec-* skills to propose/apply/archive changes.
