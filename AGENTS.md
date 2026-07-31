# AGENTS.md

Flutter mobile app for the SerbisyoHub PH marketplace (clients ↔ service providers). Reference/parity target is the Vue 3 + Ionic web app at `E:\Dev\shph-web` — check it when adding pages or matching UI behavior.

## Backend reality (read before touching data/auth)

- **The SHPH REST API (`https://api.serbisyohub.ph`, OpenAPI spec in `SHPH API.yaml`) is the sole backend. Supabase was fully removed.** Do NOT add `supabase_*` imports, `SupaFlow`, or `.from('table')` calls — existing code uses `currentUser?.uid` + `Shph*Api` resources.
- `lib/api/` is a **hand-written** Dio client (`lib/api/resources/*_api.dart`). `tool/generate_api_client.ps1` generates into `lib/api/generated/` but is not used — don't regenerate.
- Express backend lives in `backend/` (Dart app doesn't use it directly; REST hits the deployed API).
- `lib/backend/supabase/` is legacy generated row classes — leave alone.
- `docs/api_gaps.md` is **stale** (claims `preferShphApi=false`; it's `true`). Trust `lib/api/api_config.dart`.

## Architecture

- Pages follow the FlutterFlow pattern: `lib/pages/<name>/<name>_model.dart` + `<name>_widget.dart`. 75 page dirs under `lib/pages/`.
- The 5 bottom tabs + provider dashboard live in `lib/main/` (home, explore, bookings, messages, profile, pro_dashboard).
- Shared widgets in `lib/components/` (ScreenHeader, ServiceCard, StatusPill, etc.). Use these instead of inlining new UI.
- Routing: single `lib/router/app_router.dart` (GoRouter). State: `FFAppState()` (app_state.dart) + `provider`; dedicated services in `lib/services/`.
- Theming: `AppTheme.of(context)` / `AppThemeData` in `lib/theme/app_theme.dart`. **Always use theme tokens, never hardcoded hex/`Colors.*`** (dark mode depends on it). Status pills via `AppThemeData.statusColors()`. Font is `GoogleFonts.plusJakartaSans()` — `GoogleFonts.poppins` is banned.
- `lib/custom_code/**` and `lib/flutter_flow/custom_functions.dart` are excluded from analysis.

## Commands

- `flutter analyze` — the bar is **0 errors** (currently 0 errors; 88 warnings + ~570 info lints are accepted). Keep it at 0 errors.
- `flutter test` — **full suite FAILS** because `test/widget_test.dart` is stale FlutterFlow "Counter" boilerplate. Run files individually instead, e.g. `flutter test test/booking_funnel_test.dart`.
- `flutter build apk --release` — the phone-testing build. No release keystore yet; signed with the debug keystore.
- `flutter gen-l10n` — after editing `lib/l10n/*.arb` (en + es only).
- CI: `.github/workflows/flutter_build.yml` (APK + iOS IPA; iOS needs signing config and fails without it), `deploy-backend.yml` (deploys backend via CDK on push to `main`).

## Gotchas

- `pubspec.yaml` pins `dependency_overrides` (`http: 1.4.0`, `lints ^5.0.0`, `package_info_plus 8.0.2`, `rxdart 0.27.7`, `uuid ^4.0.0`) and a git fork of `flutter_google_places` — don't casually bump these.
- After `flutter pub get`, generated platform files (`linux|windows|macos/flutter/generated_*`) show as modified in git — that's expected noise, don't commit them unless needed.
- Lint rules are strict (`always_declare_return_types`, `use_build_context_synchronously`, etc.) — code must pass `flutter analyze`.
- Branch workflow: current feature work happens on `feat/ui-ux-reconstruction`; `docs/ui-ux-reconstruction-plan.md` is the living status doc — update it when landing page/theme work.
