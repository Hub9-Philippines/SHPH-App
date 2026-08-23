## Purpose

Establishes one layout grid for the main navigation tab screens and defines context-aware empty states, so Explore, Bookings, and Messages share identical header geometry, horizontal margins, and block rhythm, and users always see copy that reflects their active filter or segment.

### Requirement: Tab screen header geometry
Explore, Bookings, and Messages SHALL render their ScreenHeader with a strict 16px vertical gap between the title block (title plus its supporting subtitle) and whatever component follows it — subtitle text or search bar — and 16px left/right margins, identically on all three screens.

#### Scenario: Identical top area across tabs
- **WHEN** the user switches between Explore, Bookings, and Messages
- **THEN** the vertical distance from the header block to the next element and the horizontal margins of that next element are pixel-identical

### Requirement: 16px horizontal layout grid
All content cards, segmented controls, full-width banners, and input boxes on the tab screens SHALL be inset exactly 16px from the screen's left and right edges, locking every row to one uniform horizontal grid; no element on these screens MAY use a different horizontal page margin.

#### Scenario: Cards align to the grid
- **WHEN** any card, banner, segmented control, or input renders on Explore, Bookings, or Messages
- **THEN** its left and right edges sit exactly 16px from the viewport edges, matching every other full-width element on the screen

### Requirement: 24px separation between standalone blocks
Distinct standalone page blocks — promotional banners, carousel sections, stacked feed groups — SHALL be separated by an explicit 24px vertical margin; adjacent in-flow elements within one block remain governed by their own internal spacing.

#### Scenario: Feed blocks keep consistent rhythm
- **WHEN** the user scrolls the Explore feed past the promo banner, category section, and provider carousels
- **THEN** each boundary between two standalone blocks measures the same 24px gap

### Requirement: Category carousel metrics
The Explore "Service Category" carousel SHALL use exactly 12px horizontal gaps between items and exactly 6px vertical space between each square icon background and its center-aligned label, and long labels such as "Aircon Repair" SHALL render fully without truncation or clipping at default text scale.

#### Scenario: Long label stays readable
- **WHEN** a category named "Aircon Repair" renders in the carousel
- **THEN** the full label is visible (scaled down if necessary) rather than ending in an ellipsis

#### Scenario: Carousel spacing is exact
- **WHEN** the carousel lays out its items
- **THEN** neighboring icon containers measure exactly 12px apart and each label sits exactly 6px below its icon container

### Requirement: Promotional banner internal padding
The Explore promotional banner SHALL use 16px internal padding on all edges and SHALL separate its bold headline block from the action button below it by exactly 16px.

#### Scenario: Banner cell structure
- **WHEN** the promo banner renders
- **THEN** all content sits 16px from the banner's edges and the headline block sits 16px above the action button

### Requirement: Provider proximity card legibility
The Explore "Top Rated Near You" cards SHALL prevent truncation overflow of detail fields such as the starting price — by widening the card bounding box and/or reducing the price style by 1px — while neighboring cards keep a crisp 12px column-separation gap and full price values like "Starting ₱450" render un-truncated at default text scale.

#### Scenario: Starting price never ellipsizes
- **WHEN** a proximity card renders a typical starting price
- **THEN** the complete price string is visible without ellipsis or clipping

#### Scenario: Column separation preserved
- **WHEN** two proximity cards are visible side by side
- **THEN** exactly 12px separates them

### Requirement: Bookings filter-aware empty states
When a Bookings filter yields no rows, the empty state inside the card container SHALL switch its heading and description to match the active filter chip — All: "No bookings found" / "You haven't scheduled any services yet. Find a pro to get started!"; Pending: "No pending jobs" / "Any service requests waiting for provider approval will appear here."; Completed: "No completed visits yet" / "Once a service technician finishes a job, your history will show up here."; Canceled: "No canceled bookings" / "Great! You don't have any canceled or interrupted service requests." A search query that filters everything out SHALL retain its own no-match variant.

#### Scenario: Empty state follows the active chip
- **WHEN** each filter chip (All, Pending, Completed, Canceled) is activated against an empty result set
- **THEN** the exact heading and description pair for that chip is displayed

#### Scenario: Search no-match keeps its variant
- **WHEN** a search query produces zero results under any chip
- **THEN** the empty state indicates no matches for the search rather than the generic chip copy

### Requirement: Messages segment-aware empty states
The Messages screen SHALL present its Chats/Calls-history segment toggle aligned to the same 16px grid and radius profile as the search field directly above it, and when a segment has no items SHALL show: a section heading ("Recent conversations" or "Recent calls") with a right-aligned teal counter capsule reading "N items"; a central illustration container with a soft teal accent background holding a chat-bubble glyph (Chats) or telephone-handset glyph (Calls history); heading "No conversations yet" / "No call activity yet"; and description "Messages from your providers will show up here once a booking starts." / "Your completed and missed calls will appear here when that history is available."

#### Scenario: Chats empty state
- **WHEN** the Chats segment is active with no conversations
- **THEN** the teal counter capsule shows "0 items", the illustration shows a chat bubble on a soft teal accent background, and the specified heading/description pair appears

#### Scenario: Calls history empty state
- **WHEN** the Calls history segment is active with no calls
- **THEN** the capsule shows "0 items", the illustration swaps to a telephone handset on the same soft teal background, and the call-specific heading/description pair appears
