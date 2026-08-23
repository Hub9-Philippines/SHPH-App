## Context

Today's entry flow is splash → `SignOptionsWidget` (`/signOptions`, the "welcome" screen with `welcome-graphic.png` and Sign Up buttons) → signin/signup. References live in `splash_widget.dart:47`, `onboarding_widget.dart:96,425`, `signin_widget.dart:705` (its Sign-Up link oddly loops back to SignOptions), plus the router and `index.dart`.

The Explore tab (`lib/main/explore/explore_widget.dart`) is only `ScreenHeader` + the full `CategoriesWidgetWidget` grid. Reusable building blocks already exist: `RecommendationCard` (avatar/badges/price/onTap), `UserAvatar`, `StarRating`, `TrustBadge`, `SearchService.searchServices/searchByCategory/getAllServices`, `CategoriesService`, `geo_utils` (distance math), `FFAppState` selected-location fields, and the home page's search-capsule pattern (`searchBarHero`). Theme rule: all colors via `AppThemeData` tokens — no inline hex.

## Goals / Non-Goals

**Goals:**
- One auth entry screen (sign-in absorbs the welcome header/artwork); zero intermediate steps.
- Explore becomes a 5-section discovery feed matching the approved mockup order.
- Full categories grid remains intact on `/categories`.

**Non-Goals:**
- No backend/API changes; no new auth mechanics (phone/email tabs unchanged).
- No real referral program backend — Share Link shares/copies a static invite URL.
- No changes to `main/category` (`/category`) or signup/forgot-password flows beyond link rewiring.
- No new package dependencies.

## Decisions

### D1: Sign-in absorbs the welcome page; `/signOptions` becomes an alias
Keep `SigninWidget` and its `/signin` path (deep-link stability). Replace its current icon-based header with a compact welcome block: `welcome-graphic.png` at reduced height (~140–160px, rounded, centered) above a "Welcome to SerbisyoHub PH" headline and subtitle, then the existing Phone/Email tabs — all inside the existing single `SingleChildScrollView` so nothing falls below the fold. Both "Sign Up" links navigate to `SignupWidget.routeName`.
- Splash and onboarding now `goNamed(SigninWidget...)`.
- Router: replace the `SignOptionsWidget` GoRoute with an alias route on the same `/signOptions` path building `SigninWidget`, satisfying the retired-route scenario without relying on the generic error fallback.
- Delete `lib/pages/sign_options/` and its `index.dart` export after all references are rewired (delete-last ordering).

### D2: Explore is one scrollable feed of extracted components
Rewrite `explore_widget.dart` as a `ListView` (lazy, keeps `RefreshablePage` pull-to-refresh) composed of five section builders backed by three new shared components:
- `lib/components/hero_offer_banner.dart` — blue gradient card, offer copy, technician image slot, dark-blue CTA.
- `lib/components/provider_proximity_card.dart` — avatar, green rating badge, name, service type, km-away, starting fee, Book Now.
- `lib/components/invite_earn_banner.dart` — purple full-width footer card with outlined Share Link button.
Category shortcut tiles stay inline in Explore (a horizontal `Row` of rounded-square tiles built from `CategoriesService` data, capped ~8 + implicit variety); extract the slug→icon mapping from `categories_widget.dart` into `lib/utils/category_icons.dart` so grid and shortcuts share one mapper.
- *Alternatives considered*: keeping everything inline in explore_widget — rejected; the mockup cards are reusable marketing surfaces and AGENTS.md prefers shared components over inlined UI.

### D3: Data wiring per section
- **Shortcuts**: `CategoriesService.instance.getCategories()` (already cached by request manager).
- **Top Rated Near You**: derive from `SearchService.getAllServices()` joined with listing rating/review data already carried by listings; compute km via `geo_utils` haversine between each listing's coordinates and `FFAppState` selected lat/lng; sort by rating then distance; cap at 10. When location or results are missing → hide the whole section (spec allows graceful hide; no blank distances).
- **Recommended for You**: reuse the same recommendation source the Home "Recommended for You" carousel uses (`ServiceRecommendations`/recommendation service), rendered as vertical `RecommendationCard`s — split-grid look achieved via the card's existing photo-left/content-right layout.
- **Hero banner**: static campaign content v1 (asset + copy constants in the component); CTA pushes `/services` (featured services list).
- Loading: skeleton loaders per section (`SkeletonLoadingWidget`), independent failures don't kill the page (each section guards its own FutureBuilder).

### D4: Banner colors become theme constants
Add named gradient/color constants to `AppThemeData` (e.g. `promoGradient` blues, `referralGradient` purple, `ratingBadgeGreen`) instead of hardcoding hex inside widgets — honors the "theme tokens only" rule while giving marketing surfaces their exact brand colors; dark mode inherits centrally.

### D5: Share Link v1 = clipboard fallback
No new dependency: tap → try platform share via existing channels is not available, so copy the invite URL constant to clipboard and show a confirmation snackbar. The URL lives in one constant next to `kProviderAppStoreUrl`-style app constants so a real referral program can replace it later.
- *Alternative*: adding `share_plus` — rejected this change (pubspec overrides are pinned and sensitive; dependency additions deserve their own change).

## Risks / Trade-offs

- [Top-rated/near-you data is derived, not served by one endpoint] → Section derives and sorts client-side; hides cleanly when location or data missing; revisit with a dedicated endpoint later if volume grows.
- [Deleting sign_options misses a reference → compile break] → grep audit for `SignOptions` before deletion, delete route/export/page in one commit, `flutter analyze` 0-error gate.
- [Explore first-paint cost (5 sections, images)] → lazy `ListView.builder` semantics, `cached_network_image` (already used), skeletons, capped lists (10 carousel, ~8 tiles).
- [Welcome artwork crowds small screens] → fixed max-height image inside existing scroll view; verified against the smallest supported form factor during smoke test.
- [Static promo/referral content] → acceptable v1; constants are single-source so swapping in real campaigns/links later is trivial.
- [Stale LSP/analyzer cache after deletions] → rely on full `flutter analyze` runs, not IDE diagnostics, as the gate.

## Migration Plan

1. Auth merge (D1): rewire splash/onboarding/signin links → alias route → compact header → delete sign_options last; analyze green.
2. Theme constants (D4), then build the three new components with previewable defaults.
3. Rewrite Explore feed (D2/D3): sections behind individual futures; categories grid removal from Explore; verify `/categories` unchanged.
4. Smoke test: cold start signed-out → merged sign-in; Sign Up直达 signup; Explore five sections; View All → grid; tile → filtered services; Book Now paths; Share Link copies link.

## Open Questions

- Final referral URL and bonus copy (placeholder until the referral program exists — does not affect structure).
- Whether the hero campaign should deep-link to a specific category instead of `/services` once marketing decides (constant swap).
- Technician image asset: reuse best available marketing art now, real asset can be dropped into the same asset path later.
