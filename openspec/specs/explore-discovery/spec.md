## Purpose

Defines the redesigned Explore tab as a five-section discovery feed — search with category shortcuts, a seasonal-offer hero banner, top-rated providers near the user, personalized recommendations, and an invite-&-earn footer — and establishes that the full categories grid lives on the Categories page.

### Requirement: Explore section order and presence
The Explore tab SHALL render exactly five sections in one scrollable view, in this order: (1) search bar with category shortcuts, (2) hero offer banner, (3) "Top Rated Near You" carousel, (4) "Recommended for You" feed, (5) "Invite & Earn" banner. The Explore tab MUST NOT render the full categories grid.

#### Scenario: Explore tab opens
- **WHEN** an authenticated user switches to the Explore tab
- **THEN** the five sections appear in the stated order within a single scrollable page

#### Scenario: Full grid no longer in Explore
- **WHEN** the user scrolls the Explore tab
- **THEN** no full-page categories grid is present; only the horizontal shortcut row appears

### Requirement: Top search and category shortcuts
Explore SHALL show a search input with microphone and filter affordances at the top; submitting it SHALL open search results for the entered term. Below it, a "Service Category" row SHALL display horizontally scrollable rounded-square category tiles and a "View All" link that opens the Categories page. Tapping a category tile SHALL open services filtered to that category.

#### Scenario: User taps View All
- **WHEN** the user taps the "View All" link beside the Service Category section
- **THEN** the Categories page opens showing the full categories grid

#### Scenario: User taps a category tile
- **WHEN** the user taps any category tile in the shortcuts row
- **THEN** the services list opens filtered to that category

#### Scenario: User submits a search
- **WHEN** the user enters a term in the Explore search bar and submits
- **THEN** the search results screen opens for that term

### Requirement: Hero offer banner
Explore SHALL display a wide promotional banner card directly under the category shortcuts: vibrant blue background, bold white offer copy ("Explore Seasonal Deals – Get 60% OFF!"), service-technician imagery, and a dark-blue "Book Now" call-to-action button.

#### Scenario: Banner tap-through
- **WHEN** the user taps the hero banner's "Book Now" CTA
- **THEN** the app navigates into the booking entry flow (services list or featured booking start), not to a dead end

### Requirement: Top rated near you carousel
Explore SHALL show a horizontally scrollable "Top Rated Near You" carousel of provider cards. Each card SHALL include the provider's avatar, a green star-rating badge, provider name, service type, distance from the user's selected location in kilometers, a starting-fee indicator, and a blue "Book Now" button that starts booking for that provider's service.

#### Scenario: Location available
- **WHEN** the user has a selected location and nearby rated providers exist
- **THEN** each visible card shows its distance in km relative to that location

#### Scenario: Location or data unavailable
- **WHEN** the user has no selected location, or no rated providers are returned
- **THEN** the section hides gracefully (or shows an empty state) without breaking the page layout; cards MUST NOT render a blank or placeholder distance

#### Scenario: Book Now on a proximity card
- **WHEN** the user taps "Book Now" on a "Top Rated Near You" card
- **THEN** the booking flow opens for the tapped provider's service

### Requirement: Recommended for you feed
Explore SHALL show a "Recommended for You" vertical feed of detailed professional cards (photo, specialization badges, pricing) below the carousel, reusing the app's existing recommendation content source.

#### Scenario: Recommendations load
- **WHEN** the recommendation source returns providers for the signed-in user
- **THEN** they render as vertical feed cards beneath the "Top Rated Near You" section, each deep-linking to the provider or service detail

#### Scenario: No recommendations available
- **WHEN** the recommendation source returns nothing
- **THEN** the section shows an empty state and the remaining sections still render

### Requirement: Invite and earn footer
Explore SHALL end with a full-width purple "Invite & Earn" referral banner containing cash-bonus copy and an outlined "Share Link" button that shares or copies the user's referral invitation.

#### Scenario: Share Link tapped
- **WHEN** the user taps "Share Link" on the Invite & Earn banner
- **THEN** the app initiates sharing of the referral invitation (system share when available, otherwise copies the link and confirms)

### Requirement: Categories page hosts full grid
The full categories grid SHALL remain available on the Categories page (`/categories`) exactly as before; relocating it out of Explore MUST NOT change its behavior there.

#### Scenario: Categories page unchanged
- **WHEN** the user opens the Categories page from Explore's "View All" or any existing entry point
- **THEN** the complete tappable categories grid renders and navigates to filtered services as it did before
