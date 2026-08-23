## Why

The auth entry currently costs users an extra tap: splash → welcome page (Sign Options) → sign-in or sign-up. Meanwhile the Explore tab is just a categories grid — it doesn't do the job an "Explore" surface should do (drive discovery of providers and deals). This change removes the dead-end welcome step and turns Explore into a five-section discovery feed (search + category shortcuts, promo banner, nearby top-rated carousel, personalized recommendations, referral incentive).

## What Changes

- **BREAKING**: The standalone welcome page (`SignOptionsWidget`, `/signOptions`) is removed. Splash and onboarding now land directly on the merged sign-in page.
- Sign-in page becomes the app's welcome screen: "Welcome to SerbisyoHub PH" headline with a smaller version of the existing `welcome-graphic.png` artwork above the phone/email tabs; its "Sign Up" links go straight to the signup page.
- The full categories grid moves out of the Explore tab; it stays available on the Categories page (`/categories`), reached from Explore's "View All" link.
- Explore page is redesigned as one scrollable feed with 5 sections, in order:
  1. **Top search & categories** — search bar (mic + filter icons) plus a horizontal row of rounded-square category shortcut tiles and a "View All" link to the Categories page.
  2. **Hero offer banner** — wide vibrant blue promo card ("Explore Seasonal Deals – Get 60% OFF!") with technician imagery and a dark-blue "Book Now" CTA.
  3. **Discovery proximity cards** — "Top Rated Near You" horizontal carousel of provider cards: avatar, green star-rating badge, name, service type, distance in km, starting fee, blue "Book Now".
  4. **Personalized recommendations** — "Recommended for You" vertical feed of split-grid professional cards reusing the existing recommendation card componentry.
  5. **Footer incentive** — full-width purple "Invite & Earn" referral banner with cash-bonus copy and an outlined "Share Link" button.

## Capabilities

### New Capabilities
- `unified-auth-entry`: Requirements for the merged welcome + sign-in experience — single entry screen for returning and new users, brand header with welcome artwork, routing changes for splash/onboarding, and removal of the standalone welcome page.
- `explore-discovery`: Requirements for the redesigned Explore tab — section order and content (search & category shortcuts, hero offer banner, top-rated-near-you carousel, recommendations feed, invite-&-earn footer), data behavior (location-aware distance, ratings, fallbacks), navigation targets, and where the full categories grid lives.

### Modified Capabilities

(none — no main specs exist yet)

## Impact

- **Auth flow**: `lib/pages/signin/signin_widget.dart` (header + artwork + Sign-Up links → `SignupWidget`), `lib/pages/splash/splash_widget.dart` and `lib/pages/onboarding/onboarding_widget.dart` (route to Signin), deletion of `lib/pages/sign_options/`, cleanup in `lib/router/app_router.dart`, `lib/index.dart`.
- **Explore**: rewrite of `lib/main/explore/explore_widget.dart` + `explore_model.dart`; new shared components under `lib/components/` (hero offer banner, provider proximity card, invite & earn banner); category shortcut tiles derived from `CategoriesService`.
- **Categories**: `lib/pages/categories/categories_widget.dart` remains the home of `CategoriesWidgetWidget`; Explore links to it via "View All". `lib/main/category/` untouched.
- **Data/services**: top-rated-near-you uses provider/listing search plus distance from `FFAppState` selected location; recommendations reuse the existing recommendation service/components; distance falls back to hiding the metric when location is unavailable.
- **Assets**: reuse `assets/images/welcome-graphic.png`; hero banner needs a technician image asset (new or existing marketing art).
- **No backend changes** — all sections are served by existing SHPH REST endpoints.
