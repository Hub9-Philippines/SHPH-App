## ADDED Requirements

### Requirement: Recommended for you lists providers when booking history exists
When the user has at least one booking, the home page "Recommended for you" section SHALL render a non-empty list of recommended providers, with items derived from the user's booking history (categories/listings they booked) rather than being empty. The section MUST NOT render its header when the recommendation list would be empty; it is only shown together with at least one provider card.

#### Scenario: Booking history present and recommendations available
- **WHEN** the user has at least one existing booking and the recommendations feed returns providers
- **THEN** the "Recommended for you" section renders its header followed by the returned provider cards

#### Scenario: Booking history present but recommendation sources empty
- **WHEN** the user has at least one existing booking but the personalized and nearby recommendation sources both return no items
- **THEN** the home page falls back to top-rated providers for the section, so the list is not empty when shown

#### Scenario: Recommendation sources error out
- **WHEN** any recommendation source fails while loading with booking history present
- **THEN** the next fallback source is used and the section still renders a populated list without crashing

#### Scenario: Empty list never shows a bare header
- **WHEN** every recommendation source yields no providers
- **THEN** the "Recommended for you" section (header included) is not rendered at all

### Requirement: Recommendations are derived from booking history
The "Recommended for you" items SHALL prefer connections to the user's own bookings — the categories or listings the user has booked — over a generic nearby radius search, so the section reflects services the user has actually engaged with.

#### Scenario: Personalized feed preferred
- **WHEN** the user has bookings and the booking-history-based recommendation feed returns items
- **THEN** those items are used for the section and no nearby radius search substitutes for them

#### Scenario: Fallback to nearby providers
- **WHEN** the booking-history-based feed returns no items but the nearby recommendation endpoint returns providers
- **THEN** the section is populated from the nearby results

#### Scenario: Fallback to top-rated providers
- **WHEN** neither the booking-history-based nor the nearby feed returns items
- **THEN** the section is populated from top-rated listings near the user