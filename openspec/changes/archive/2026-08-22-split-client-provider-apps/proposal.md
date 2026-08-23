## Why

The app currently serves two distinct audiences in one binary: clients who book services and providers who offer them. This doubles every surface (auth role branching, dual tab sets in `lib/main.dart`, provider route gates in `lib/router/app_router.dart`, ~25 provider-only page directories) and forces each user to download features they never use. Splitting into a client app (this repo) and a standalone provider app lets each product evolve independently with smaller builds and simpler flows.

## What Changes

- **BREAKING**: This app becomes **client-only**. Provider-only screens, routes, and tab sets are removed from this codebase.
- Provider-only experiences move to a new standalone Flutter app (`shph-provider`, sibling repository) that reuses the same SHPH REST API and copies the shared architecture (Dio client in `lib/api/`, theme, components, services).
- Client app changes:
  - Signup/onboarding no longer offers a "provider" role choice; all accounts created here are clients.
  - Post-auth navigation always lands on the client home; `_providerTabs` / `_buildProviderItems` and provider branch logic are deleted from `MainNavWidget`.
  - Router drops provider-only routes and their `requiresProvider` gates; deep links to provider surfaces resolve to client home or not-found.
  - Removed page families (provider dashboard/jobs/schedule/earnings, service management, availability calendar, provider analytics/bids, provider KYC/eKYC/verification, dispatch, tm_flow); kept shared surfaces used by clients (booking funnel, chat, public `provider_profile`, `client_ondemand_jobs`, reviews, wallet/payments).
  - Login of an existing provider account in the client app shows a clear "use the Provider app" notice instead of silently rendering client tabs.
- Provider app (new project):
  - Same provider feature set as today: Jobs, Schedule, Earnings, Messages, Profile tabs; service CRUD, bids, analytics, availability, KYC verification flow.
  - Own application id/package name, store listing metadata, and CI pipeline; client accounts signing in there get an equivalent "use the SerbisyoHub app" notice.
- Both apps keep talking to the single backend at `https://serbisyohubph.com`; no API contract changes required for the split itself.

## Capabilities

### New Capabilities
- `client-app-scope`: Requirements for this repository becoming the dedicated client app — client-only signup/auth outcomes, fixed client tab set, removal/rejection behavior for provider-only routes, and messaging when a provider account signs in.
- `provider-app-extraction`: Requirements for the extracted standalone provider app — provider-only authentication outcome and navigation, carried-over provider capabilities (jobs, schedule, earnings, services, bids, analytics, availability, KYC), and rejection/messaging when a client account signs in.

### Modified Capabilities

(none — `openspec/specs/` has no existing specs yet)

## Impact

- **Code (this repo)**: `lib/main.dart` (dual tab maps), `lib/router/app_router.dart` (~30 provider routes + `RouteGates.requiresProvider` logic + `_providerHomePaths`), `lib/auth/post_auth_navigation_flow.dart` (provider branch), `lib/pages/pro_*`, `earnings*`, `my_services`, `availability_calendar`, `kyc_hub`, `e_k_y_c_begin`, `i_d_verify`, `dispatch`, `tm_flow`, plus their models/tests; `FFAppState.isProvider` usage reduced to sign-in detection.
- **Code (new repo)**: scaffolded from this app's structure — copied `lib/api/`, `lib/theme/`, `lib/components/`, `lib/services/`, shared page families (auth, chat, profile shell).
- **Build/CI**: `.github/workflows/flutter_build.yml` gains a provider-app job or a second workflow in the new repo; Android application IDs must diverge (`com.serbisyohub.app` vs `com.serbisyohub.provider`) to allow side-by-side install.
- **Backend**: none — same REST endpoints serve both apps; only guidance docs/store listings change.
