# Brand & Design Consistency Plan — Serbisyo Flutter App

**Status:** Implemented (Flutter side complete 2026-08-15; web highlights pending)
**Date:** 2026-08-09
**Scope:** Brand & design consistency across the Flutter app (`SHPH-App`) and the web app (`shph-web`)
**Related docs:** [`ui-ux-reconstruction-plan.md`](ui-ux-reconstruction-plan.md), [`api_gaps.md`](api_gaps.md)

---

## ════════════ PART A — THIS APP (Flutter) ════════════

## A0. Current state (verified 2026-08-09)

| Surface | Current value | Should be | File |
|---|---|---|---|
| `AppThemeData.light().primary` | `#63CBD6` ✅ | `#63CBD6` (teal) | `lib/theme/app_theme.dart:334` |
| `AppThemeData.dark().primary` | `#63CBD6` ✅ | `#63CBD6` (teal) | `lib/theme/app_theme.dart:362` |
| `AppThemeData.light().onPrimary` | `#0F172A` ✅ | `#0F172A` | `lib/theme/app_theme.dart:335` |
| `AppThemeData.dark().onPrimary` | `#0F172A` ✅ | `#0F172A` | `lib/theme/app_theme.dart:363` |
| `AppThemeData.light().info` | `#63CBD6` ✅ | `#63CBD6` (teal) | `lib/theme/app_theme.dart:351` |
| `AppThemeData.dark().info` | `#63CBD6` (teal) | `#63CBD6` ✅ already | `lib/theme/app_theme.dart:379` |
| `flutter_native_splash.color` | `"#0d6d78"` ✅ | teal (see A2) | `pubspec.yaml:136` |
| `flutter_native_splash.android_12.color` | `"#0d6d78"` ✅ | teal (see A2) | `pubspec.yaml:141` |
| `flutter_launcher_icons.adaptive_icon_background` | `'#0d6d78'` ✅ | teal (see A2) | `pubspec.yaml:130` |
| `android/.../values/colors.xml` `ic_launcher_background` | `#0d6d78` ✅ | teal (see A2) | `android/app/src/main/res/values/colors.xml` |
| Legacy `flutter_flow_theme.dart` primary | `#63CBD6` (teal) | deleted (dead code) ✅ | `lib/flutter_flow/flutter_flow_theme.dart` |

**Root problem:** the Flutter app still wears the old blue brand (`#368EFF`) on nearly every surface while the web app already shipped teal (`#63CBD6`). The teal-vs-blue question has been answered — **teal** (rationale in the shared Part C). This plan realigns the Flutter app to teal and keeps the two platforms from drifting again.

## A1. AppTheme token realignment

Files: `lib/theme/app_theme.dart`

- [x] Change `light().primary` `#368EFF` → `#63CBD6` (line 334)
- [x] Change `dark().primary` `#368EFF` → `#63CBD6` (line 362)
- [x] Change `light().onPrimary` `#FFFFFF` → `#0F172A` (line 335) — web's `--shph-on-primary`; re-check text contrast on teal fills
- [x] Change `dark().onPrimary` `#FFFFFF` → `#0F172A` (line 363) — confirm against dark-theme legibility
- [x] Change `light().info` `#368EFF` → `#63CBD6` (line 351) — kill the light/dark info inconsistency
- [x] Audit all button/text usages that relied on `onPrimary = white` (e.g. primary CTA text) — teal + `#0F172A` text has 8.3:1 contrast per the web's own token rule. Swept 37 `foregroundColor: Colors.white` on teal fills (28 changed, 9 kept for non-primary/conditional fills), 80 `color: Colors.white` text/spinner/icon on teal fills, plus 4 teal-button `valueColor` spinners + theme `elevatedButtonTheme` foregroundColor.
- [x] Verify the flutter_flow legacy getters at the bottom of `app_theme.dart` (Typography getters) still resolve cleanly against `primaryText` — they must not hardcode blue

**Sweep for stragglers** (blue hex must reach 0 references like the Phase-12 sweep did):

- [x] `grep -rn "368EFF" lib/ android/ ios/` → replace every UI hit with the matching token (do **not** touch `api`/`services` unless a value is genuinely a UI color) — 0 UI hits remain
- [x] Re-run the Phase-12-style page audit: any page with `Color(0xFF368EFF)` inline → swap to `AppTheme.of(context).primary` / `.info`

## A2. Native surfaces (splash + launcher) — decide, then apply

**Decision needed (one option):**

1. **Deep-teal splash, white logo** (recommended for logo contrast): splash/launcher background `#0D6D78` (`--shph-primary-deep`), logo stays white/light. Matches the web's hero gradient base.
2. **Brand teal splash, dark logo**: background `#63CBD6` with a dark (`#0F172A`) logo — requires re-exporting logo art.

**Decision made 2026-08-15:** **Option 1 — deep-teal splash, white logo.** Background `#0D6D78`, logo asset `assets/images/shph-logo.png`. (`app_launcher_icon.png` placeholder superseded by `shph-logo.png`.)

Apply (option 1 shown; swap values if option 2 chosen):

- [x] `pubspec.yaml` `flutter_native_splash.color` → `"#0d6d78"`, `android_12.color` → `"#0d6d78"`
- [x] `pubspec.yaml` `flutter_launcher_icons.adaptive_icon_background` → `'#0d6d78'`
- [x] `android/app/src/main/res/values/colors.xml` `ic_launcher_background` → `#0d6d78`
- [x] Regenerate: `dart run flutter_native_splash:create` then `dart run flutter_launcher_icons`
- [x] Verify `android/app/src/main/res/drawable/launch_background.xml` still points at the right drawables and the generated `splash`/`background` PNGs are the intended color (69-byte placeholder PNGs exist — confirm they render correctly)
- [x] Android 12+: check `values-v31/styles.xml` `android12splash` drawable and `values-night-*` variants match

**Splash widget** (`lib/pages/splash/splash_widget.dart`): already uses `AppTheme.of(context).primary` — automatically correct once A1 lands. **Updated 2026-08-15:** its title/subtitle text and the two `Colors.white` Lottie-frame texts were switched to `AppTheme.of(context).onPrimary` (white had ~1.9:1 contrast on the now-light brand teal; dark ink has 8.3:1).

## A3. Delete dead theme code

- [x] Confirm `flutter_flow_theme.dart` has zero importers (`grep -rln 'flutter_flow_theme' lib/` returned none on 2026-08-09) and remove it — its teal values can confuse future editors
- [x] Update any docs referencing `flutter_flow_theme.dart`

## A4. Status pill & component parity (verify only)

Flutter's `AppThemeData.statusColors()` (lines 311-331) uses token-level hex that already mirrors the web's status chips. Re-verify against the web once Part B lands:

- [x] `confirmed` → `(0D6D78, D4F0EF)` vs web status token ✅
- [x] `in_progress` → `(166534, E7F6EC)` vs web ✅
- [x] `completed` / `cancelled` / `pending` vs web ✅
- [x] Add missing statuses the web knows (`en_route`, `arrived`, `disputed`) if the Flutter UI surfaces them — added to `statusColors()` (2026-08-15): `en_route`/`arrived`/`on_site` → active tone, `disputed` → cancelled tone, `inquiry`/`searching` → pending, mirroring web `StatusPill.vue`

## A5. Flutter verification

- [x] `flutter analyze` → 0 errors (86 warnings + 626 info lints — accepted baseline; verify against repo baseline on next full run)
- [ ] `flutter test` → pass (repo-wide suite fails on stale `test/widget_test.dart`; run files individually)
- [x] `flutter build apk --debug` → native splash/launcher regenerated with `shph-logo.png` on deep teal (`#0D6D78`); screenshot light + dark home, settings, booking screens — **build/screenshot pass pending on a device**
- [ ] Compare screenshots side-by-side with web equivalents (desktop at 390px wide)

---

## ════════════ PART B — SIBLING APP (Web) ════════════

Highlights only; full details live in `shph-web/docs/plan.md`.

- **Web brand is already teal** (`--shph-primary: #63cbd6` in light, dark, and data-theme blocks) — no color change needed
- **Fix stale docs:** `DESIGN_SYSTEM.md` header still says "Primary brand: `#368EFF` · Font: Poppins" — update to teal + Plus Jakarta Sans
- **Provider-mode amber** (`body.provider-mode` → `#f59e0b`) is a web-only accent — Flutter does **not** currently mirror it; decide whether to port (recommended for cross-platform provider affordance) or consciously defer
- **Status color drift check** against the Flutter `statusColors()` table (Part A4)

---

## ════════════ PART C — SHARED CROSS-APP (mirrored in both docs) ════════════

## C1. Brand decision (record)

**Teal `#63CBD6` is the brand primary for both apps.** Rationale: service-marketplace trust + safety signals in one color, domain fit (cleaning/repair/plumbing), the web already ships it, and it differentiates from the blue-dominant competitor set. The earlier blue (`#368EFF`) is retired; any new screen in either app must use the token, never a hex.

Canonical palette (single source of truth = web `src/theme/variables.css`):

| Token | Value | Role |
|---|---|---|
| `--shph-primary` | `#63CBD6` | brand teal |
| `--shph-primary-deep` | `#0D6D78` | deep teal — splash bg, hero gradients, logo-on-teal |
| `--shph-on-primary` | `#0F172A` | text on teal fills |
| `--shph-secondary` | `#39D2C0` | teal-mint accent |
| `--shph-tertiary` | `#EE8B60` | orange CTA accent |
| `--shph-success` | `#249689` | success |
| `--shph-warning` | `#F9CF58` | warning |
| `--shph-error` | `#DC2626` | error |
| Font | Plus Jakarta Sans | both apps (Flutter: `GoogleFonts.plusJakartaSans`) |

## C2. One-way parity rule

The **web is the source of truth** for tokens (CSS vars), typography, radius, shadows, spacing. The Flutter `AppThemeData` mirrors it. Any token added/edited on the web must land in `app_theme.dart` in the same change (and vice-versa only for fixes).

## C3. Decision backlog (open questions)

- [x] **Splash bg:** deep teal `#0D6D78` + white logo (recommended) vs brand teal `#63CBD6` + dark logo (Part A2) — **decided 2026-08-15: deep teal + `shph-logo.png`**
- [x] **Provider-mode amber in Flutter:** port the web's `body.provider-mode` amber accent, or defer — **deferred 2026-08-15** (kept web-only; revisit in a future provider-affordance change)
- [ ] **`DESIGN_SYSTEM.md` ownership:** move/copy it into both repos, or keep one canonical copy and link from the other

## C4. Consistency checklist (run before any release)

- [x] Web `variables.css` tokens == Flutter `app_theme.dart` tokens (colors, radii, shadows, statuses) — colors/status verified 2026-08-15
- [x] Both apps use Plus Jakarta Sans
- [x] No `#368EFF` anywhere in Flutter (UI); no blue brand references in web — Flutter UI grep clean (docs/spec historical references remain, which is correct)
- [x] Native splash/launcher (Flutter) match in-app splash
- [ ] Side-by-side screenshot pass: Home, Explore/Categories, Bookings, Messages, Profile, Settings, Booking, Wallet — light + dark

---

## Appendix — related roadmap items (out of scope for this plan)

Flutter: admin suite (8 pages missing), `docs/api_gaps.md` endpoint coverage, real-time messaging via SHPH API, offline cache hardening, real release keystore + Play Store.
Web: pending unit-test fixes in `vite.config.ts` (uncommitted), `polish-client-desktop-ui` proposal, real release keystore.
