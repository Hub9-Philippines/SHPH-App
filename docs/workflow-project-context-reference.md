# /opsx-propose — Workflow & Project Context Reference

Reference for the OpenSpec "propose" workflow (`/opsx-propose`) and the SHPH-App project answers to the standard onboarding questions (state management, theme, maps, data models, structure).

---

## Part 1 — The `/opsx-propose` workflow

**Purpose:** Propose a new change and generate all planning artifacts in one step.

With the default spec-driven schema, the artifacts are:

- `proposal.md` — what & why
- `specs/<capability>/spec.md` — what the system must do (a delta, not the main spec)
- `design.md` — how
- `tasks.md` — implementation steps

When ready to implement, run `/opsx-apply`.

### Store selection

If the user names a store (a store is a standalone OpenSpec repo registered on this machine) or the work lives in one:

1. Run `openspec store list --json` to discover registered store ids.
2. Pass `--store <id>` on commands that read or write specs and changes:
   `new change`, `status`, `instructions`, `list`, `show`, `validate`, `archive`, `doctor`, `context`, `view`.
3. Other commands do not take the flag. Hints printed by commands already carry the flag — keep it on follow-ups.

Without a store, commands act on the nearest local `openspec/` root.

### Input

The argument after `/opsx-propose` is:

- the **change name** (kebab-case), OR
- a **description** of what the user wants to build.

### Steps

#### 1. If no input provided, ask what they want to build

Ask the user (open-ended, no preset options):

> "What change do you want to work on? Describe what you want to build or fix."

From their description, derive a kebab-case name (e.g. "add user authentication" → `add-user-auth`).

**IMPORTANT:** Do NOT proceed without understanding what the user wants to build.

#### 2. Create the change directory

```bash
openspec new change "<name>"
```

This creates a scaffolded change in the planning home resolved by the CLI with `.openspec.yaml`.

#### 3. Get the artifact build order

```bash
openspec status --change "<name>" --json
```

Parse the JSON to get:

- `applyRequires`: array of artifact IDs needed before implementation (e.g., `["tasks"]`)
- `artifacts`: list of all artifacts, each with a `status` and `requires` edges (the artifact IDs it directly depends on)
- `planningHome`, `changeRoot`, `artifactPaths`, `actionContext`: path and scope context — use these instead of assuming repo-local paths.

#### 4. Create every artifact in the required set

Use a todo list to track progress through the artifacts.

Loop through artifacts in dependency order (artifacts with no pending dependencies first).

**a. For each artifact that is `ready` (dependencies satisfied):**

- Get instructions:

  ```bash
  openspec instructions <artifact-id> --change "<name>" --json
  ```

- The instructions JSON includes:
  - `context`: Project background (constraints for you — do NOT include in output)
  - `rules`: Artifact-specific rules (constraints for you — do NOT include in output)
  - `template`: The structure to use for your output file
  - `instruction`: Schema-specific guidance for this artifact type
  - `skipped`/`warning`: present when the change declares `skip_specs` and this artifact must NOT be created — stop and pick another artifact
  - `resolvedOutputPath`: Resolved path or pattern to write the artifact
  - `dependencies`: Completed artifacts to read for context
- Read any completed dependency files for context — always re-read them from disk, even if you saw them earlier (the user may have edited them).
- If the `instruction` field delegates creation to a specific skill or command, invoke it to produce the artifact instead of writing the file yourself, then verify the artifact file exists at `resolvedOutputPath`.
- Otherwise create the artifact file using `template` as the structure and write it to `resolvedOutputPath`. If `resolvedOutputPath` is a glob, follow `instruction` to choose the concrete file path.
- Apply `context` and `rules` as constraints — but do NOT copy them into the file.
- Show brief progress: "Created `<artifact-id>`".

**b. Continue until every artifact in the required set exists (not just `apply.requires`):**

- After creating each artifact, re-run `openspec status --change "<name>" --json`.
- The required set is `applyRequires` plus every artifact reachable from those by following the `requires` edges in `status --json` — walk them transitively (spec-driven closes over proposal, specs, design, tasks). Leave artifacts outside that set alone.
- `status` is file-existence only, so an `applyRequires` artifact reading `done` does NOT mean its dependencies exist — writing `tasks.md` early marks `tasks` done while `specs` was never written. Use each artifact's `requires` edges, not its `status`, to build the required set: a `done` artifact still lists what it depends on.
- An artifact already reading `status: "skipped"` is satisfied: the change declares `skip_specs` in `.openspec.yaml`, so its files must NOT exist. Never try to create one.
- Create every artifact in the required set that is missing, then re-check — creating one can unblock others.
- Skip one only when `status` already reports it `skipped`, or when its own `instruction` says it is conditional: run `openspec instructions <artifact-id> --change "<name>" --json` and skip only if its `instruction` field marks it optional (e.g. "create only if..."). Spec-driven's `design.md` qualifies; `specs` qualifies only via the `skipped` status above, never by your own judgment. Tell the user, and do not reconsider it.
- Dependencies are enablers, not gates: if a required artifact is still `blocked` only because you skipped a conditional dependency, write it anyway.
- Stop when every artifact in the required set is `done`, `skipped`, or was deliberately skipped.

**c. If an artifact requires user input** (unclear context):

- Ask the user to clarify.
- Then continue with creation.

#### 5. Show final status

```bash
openspec status --change "<name>"
```

### Output

After completing all artifacts, summarize:

- Change name and location
- List of artifacts created with brief descriptions, plus any conditional artifact you skipped and why
- What's ready: "All artifacts needed for implementation are ready."
- Prompt: "Run `/opsx-apply` to start implementing."

### Artifact creation guidelines

- Follow the `instruction` field from `openspec instructions` for each artifact type — it is the authoritative guidance, even for familiar artifact names.
- If the `instruction` field directs you to use a specific skill or command to create the artifact, invoke it instead of writing the artifact directly.
- The schema defines what each artifact should contain — follow it.
- Read dependency artifacts for context before creating new ones.
- Use `template` as the structure for your output file — fill in its sections.
- **IMPORTANT:** `context` and `rules` are constraints for YOU, not content for the file:
  - Do NOT copy `<context>`, `<rules>`, `<project_context>` blocks into the artifact.
  - These guide what you write, but should never appear in the output.

### Guardrails

- Create every artifact the apply phase transitively depends on, not just the ids listed in `apply.requires`.
- Always read dependency artifacts before creating a new one — re-read from disk, not from conversation memory (files may have changed since you last saw them).
- If context is critically unclear, ask the user — but prefer making reasonable decisions to keep momentum.
- If a change with that name already exists, ask if the user wants to continue it or create a new one.
- Verify each artifact file exists after writing before proceeding to the next.

---

## Part 2 — SHPH-App project answers

Answers to the standard questions a new screen/change proposal should know before writing design/tasks. Evidence paths included.

### State management: Provider + `FFAppState` (ChangeNotifier)

- **No Riverpod, Bloc, or GetX.** `pubspec.yaml` has none of `flutter_bloc`/`bloc`, `flutter_riverpod`, `get`.
- `provider: ^6.1.5+1` (`pubspec.yaml:83`, locked 6.1.5+1).
- Global app state: `FFAppState extends ChangeNotifier` singleton (`lib/app_state.dart:7`) with `SharedPreferences` persistence and `notifyListeners()` setters.
- Wired at root in `lib/main.dart`: `ChangeNotifierProvider<FFAppState>.value(...)` + `ChangeNotifierProvider<ConnectivityService>` (`main.dart:178-180`).
- Per-feature controllers are more `ChangeNotifier`s, e.g. `BookingFlowController` (`lib/pages/booking_funnel/booking_controller.dart:12`).
- Page-level local state uses the FlutterFlow pattern `FlutterFlowModel<T>` (`lib/flutter_flow/flutter_flow_model.dart:37`), one `*_model.dart` per page.

**Rule for new work:** use `provider` + `ChangeNotifier` (or extend `FlutterFlowModel` for page state). Do not introduce Riverpod/Bloc/GetX.

### Design system & theme: custom token system, Material 2

File: `lib/theme/app_theme.dart` (~700 lines).

- **Material 3 is OFF** — `useMaterial3: false` in both `AppTheme.lightTheme()` and `AppTheme.darkTheme()`.
- Two classes: `AppTheme` (initialize, themeMode, light/dark, `AppTheme.of(context)`) and `AppThemeData` (token bag, `.light()` / `.dark()`).
- Color tokens: `primary #1E3A8A`, `secondary #7C5CFC`, `tertiary #EE8B60`, `primaryText`, `secondaryText`, backgrounds, `bgPage`, `accent1-4`, `success`, `warning`, `error #DC2626`, `info`, borders, etc.
- Layout tokens: `radiusSm/Md/Lg/Card/Pill`, `spaceXs…spaceXl`, container widths, `shadowSoft/Md/Card/Lg`.
- Status pills: `statusConfirmed/Active/Completed/Cancelled/Pending(+Bg)` + `statusColors(String status)` mapper.
- Gradients: `profileHeroGradient`, `settingsBannerGradient`, `promoGradient`, `referralGradient`.
- Font: **only** `GoogleFonts.plusJakartaSans()` — `GoogleFonts.poppins` is banned. No custom font assets in `pubspec.yaml`.
- Full token/component reference: `docs/design-system.md`.

**Rule for new work:** always use `AppTheme.of(context)` / `AppThemeData` tokens — never hardcoded hex or `Colors.*` (dark mode depends on it).

### Map package: google_maps_flutter (Google Maps)

- `google_maps_flutter: ^2.17.1` (locked 2.18.0) — the mapping solution.
- `flutter_google_places` via pinned git fork (`pubspec.yaml:45-48`, locked 0.4.0) for place search; `flutter_flow_place_picker.dart` wraps it.
- `geolocator: ^14.0.1`, `flutter_polyline_points: ^3.1.0`.
- `google_maps: ^8.2.0` is declared but **unused** (zero imports in `lib/`).
- **No flutter_map, no Mapbox.**
- Existing wrappers/components: `lib/flutter_flow/flutter_flow_google_map.dart`, `lib/components/explore_map_view.dart`, `lib/components/provider_map_view.dart`, `lib/components/map_radar_scan.dart`; used in booking funnel, home, and tm_flow screens.

**Rule for new work:** use `google_maps_flutter` + `FlutterFlowGoogleMap` / existing map components; use `FlutterFlowPlacePicker` for address search. Don't add flutter_map/Mapbox.

### Data models

**Current typed models — `lib/api/models/`:**

| Concept | Class | File |
|---|---|---|
| Booking | `ShphBooking` | `lib/api/models/booking.dart` (status, scheduledAt, agreedPrice, totalPrice, serviceLat/Lng, `serviceListing`/`clientProfile` raw maps; `fromJson`, `toCreateJson`) |
| Address | `ShphAddress` | `lib/api/models/address.dart` (label, street, barangay, city, province, zipCode, isDefault, lat/lng) |
| Service listing | `ShphServiceListing` | `lib/api/models/service_listing.dart` |
| Category / Review | `ShphCategory`, `ShphReview` | `lib/api/models/category.dart`, `review.dart` |
| Recommendations | `NearbyRecommendation`, `RecommendationItem` | `lib/api/models/nearby_recommendation.dart`, `recommendation_item.dart` |
| Pagination | `PaginatedResponse<T>` | `lib/api/models/paginated_response.dart` |

**Gaps:**

- **ServiceProvider: no dedicated model.** `ShphProvidersApi` returns raw `Map<String, dynamic>`; UI-level shapes are private widget classes (`_TrendingProviderData`, `_RecommendedProviderCard` in `lib/main/home/home_redesign_widget.dart`) or `TMProviderProfile` (`lib/pages/tm_flow/tm_models.dart:28`).
- **PaymentMethod: no typed API model.** Only legacy `PaymentMethodsRow` used directly by `lib/main/payment_methods/payment_methods_widget.dart`. Stripe logic in `lib/services/payment_controller.dart` (`flutter_stripe ^14.0.0`).

**Legacy Supabase row classes — `lib/backend/supabase/database/tables/` (leave alone, don't extend):** `BookingsRow`, `AddressesRow`, `PaymentMethodsRow`, `ProfilesRow`, etc. (`lib/api/bridges/api_row_mapper.dart` maps API models ↔ rows.)

**Feature-local models:** `BookingAddress`/`BookingDraft`/`BookingQuote` (`lib/pages/booking_funnel/booking_models.dart`), `BookingItem` (`lib/main/bookings/bookings_model.dart`), dispatch models (`lib/services/dispatch/dispatch_models.dart`).

**Note:** most `lib/api/resources/*` methods return untyped `Future<Map<String, dynamic>>`; only some are typed (e.g. `favorites_api.dart`, `profiles_api.dart`).

### Project structure: FlutterFlow page pattern (page-per-directory)

```
lib/
  api/         hand-written Dio layer: shph_api_client.dart, api_config.dart,
               bridges/, models/ (8), resources/ (24)
  auth/        auth_manager_factory.dart, shph_auth/shph_user_provider.dart
  backend/     legacy generated Supabase row classes (leave alone)
  components/  48 shared widgets (ScreenHeader, ServiceCard, StatusPill,
               BookingCard, map views, cupertino_ui/, skeleton_loading/)
  flutter_flow/ runtime (flutter_flow_model, google map + place picker wrappers)
  l10n/        en + es ARB files (run `flutter gen-l10n` after edits)
  main/        bottom-tab dirs: home, category, bookings, messages, profile,
               services, payment_methods (+ pro_dashboard)
  models/      service_listing.dart (older duplicate)
  pages/       65 feature dirs — FlutterFlow pattern:
               <name>/<name>_model.dart + <name>_widget.dart
  router/      app_router.dart — single GoRouter, role/redirect guards
  services/    ~50 feature service classes (bookings, addresses, auth,
               payment_controller, dispatch/…)
  theme/       app_theme.dart
  utils/
  main.dart, app_state.dart, index.dart (barrel export for the router)
```

Conventions:

- **Page pattern:** `lib/pages/<name>/<name>_model.dart` (extends `FlutterFlowModel<T>`) + `<name>_widget.dart`. Bottom-tab pages live under `lib/main/` with the same pairing.
- **Routing:** single `lib/router/app_router.dart` (`AppRouter.createRouter`, `_RouteGates`, 100+ `GoRoute`s); new pages are registered there and exported via `lib/index.dart`.
- **Shared UI:** put reusable widgets in `lib/components/`, don't inline.
- **Data access:** through `lib/api/resources/*_api.dart` (Shph*Api) — never `supabase_*` / `.from('table')`.
- **Lint bar:** `flutter analyze` at 0 errors; strict rules (`always_declare_return_types`, `use_build_context_synchronously`, etc.).
