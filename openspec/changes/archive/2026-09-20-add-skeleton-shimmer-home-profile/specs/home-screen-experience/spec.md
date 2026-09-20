## ADDED Requirements

### Requirement: Home page skeleton loading state
While the home feed is loading, the home page SHALL render shimmer skeleton placeholders in place of its always-visible data-driven sections — the "Trending near you" provider rail and the "EXPLORE SERVICES" category rail — instead of empty rails, and SHALL swap those placeholders for the loaded content once the feed resolves. Static sections (emergency help, seasonal offer, referral banner) SHALL remain visible during loading. A pull-to-refresh gesture SHALL keep the currently displayed content on screen and must not replace it with skeleton placeholders.

#### Scenario: Initial load shows skeleton placeholders
- **WHEN** the home page begins loading its initial feed and the trending/category data is not yet available
- **THEN** the "Trending near you" and "EXPLORE SERVICES" sections render shimmer skeleton placeholders (matching the Bookings/Messages skeleton pattern) instead of empty horizontal rails

#### Scenario: Skeletons replaced by loaded content
- **WHEN** the initial feed finishes loading
- **THEN** the skeleton placeholders are replaced by the real trending-provider and category content

#### Scenario: Refresh preserves visible content
- **WHEN** the user triggers a pull-to-refresh while content is already displayed
- **THEN** the displayed content stays on screen with the refresh indicator, and skeleton placeholders do not appear