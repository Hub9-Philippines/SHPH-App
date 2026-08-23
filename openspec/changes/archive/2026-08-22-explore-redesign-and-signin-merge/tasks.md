## 1. Auth Entry Merge (unified-auth-entry)

- [x] 1.1 Rewire entry points: `splash_widget.dart` and `onboarding_widget.dart` (both call sites) navigate to `SigninWidget.routeName`; signin's two "Sign Up" links target `SignupWidget.routeName`
- [x] 1.2 Add compact welcome header to `signin_widget.dart`: rounded `welcome-graphic.png` (max ~150px height) above "Welcome to SerbisyoHub PH" headline + subtitle, inside the existing scroll view
- [x] 1.3 Replace the `/signOptions` GoRoute in `app_router.dart` with an alias route building `SigninWidget`; remove the `SignOptionsWidget` export from `index.dart`
- [x] 1.4 Grep-audit remaining `SignOptions` references (tests included), then delete `lib/pages/sign_options/`; run `flutter analyze` (0 errors required)

## 2. Theme & Shared Building Blocks (explore-discovery prep)

- [x] 2.1 Add marketing color constants to `AppThemeData`: promo blues gradient, referral purple gradient, rating-badge green (dark-mode safe, single source)
- [x] 2.2 Extract slug/name→icon mapper from `categories_widget.dart` into `lib/utils/category_icons.dart`; switch the categories grid to consume it (behavior unchanged)
- [x] 2.3 Create `lib/components/hero_offer_banner.dart`: wide blue-gradient card, technician image slot, bold white "Explore Seasonal Deals – Get 60% OFF!" copy, dark-blue "Book Now" CTA (onTap callback)
- [x] 2.4 Create `lib/components/provider_proximity_card.dart`: avatar, green star-rating badge, provider name, service type, km-away text, starting fee, blue "Book Now" button (all fields as params; distance optional → omitted when null)
- [x] 2.5 Create `lib/components/invite_earn_banner.dart`: full-width purple card, cash-bonus copy, outlined white "Share Link" button (onShare callback)

## 3. Explore Feed Implementation

- [x] 3.1 Rewrite `explore_widget.dart` as a lazy scrollable feed with the five ordered sections; keep pull-to-refresh and per-section skeletons/error isolation; remove the full categories grid from the tab
- [x] 3.2 Section 1 — search bar (mic + filter icons) wired to search results navigation + "Service Category" horizontal shortcut tiles from `CategoriesService` via the shared icon mapper; "View All" pushes `/categories`; tile tap pushes services filtered by category
- [x] 3.3 Extend `explore_model.dart`: load categories, top-rated-near-you (listings + ratings sorted client-side by rating/distance via geo_utils + FFAppState location, cap 10), and recommendations reusing the Home recommendation source; expose per-section state
- [x] 3.4 Section 3 — "Top Rated Near You" carousel of `ProviderProximityCard`s; hide section when no location or no results; Book Now opens the booking flow for that listing (same extra-passing pattern as ProductPage)
- [x] 3.5 Section 4 — "Recommended for You" vertical feed of `RecommendationCard`s deep-linking to provider/service detail; empty state on no data
- [x] 3.6 Sections 2 & 5 — place `HeroOfferBanner` (CTA → featured services) and `InviteEarnBanner` at top/bottom positions; Share Link copies invite URL constant + confirmation snackbar

## 4. Verification & Docs

- [x] 4.1 Widget test for merged sign-in: welcome artwork + headline render; Sign Up navigates to SignupWidget route
- [x] 4.2 Widget/model tests for Explore: five sections render in order; category tile tap emits filtered-services navigation; proximity distance hidden when location null
- [x] 4.3 Run `flutter analyze` (0 errors) and targeted test files; smoke-test flows: cold start signed-out → merged sign-in; Explore sections; View All → `/categories` grid intact; Book Now paths
- [x] 4.4 Update `docs/ui-ux-reconstruction-plan.md` status notes for the auth merge + explore redesign
