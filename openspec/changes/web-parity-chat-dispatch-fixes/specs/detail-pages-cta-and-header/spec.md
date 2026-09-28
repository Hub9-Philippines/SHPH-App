## Purpose

Covers the product/service detail page CTA layout, the provider profile contact entry point, and the home page header collapse behavior: where contact and booking actions live on each surface and how the home header responds to scrolling.

## ADDED Requirements

### Requirement: Product page CTAs live in the bottom bar only
On the service/product detail page, the provider section card SHALL NOT render inline Contact or Book Now buttons; those actions SHALL exist only in the page's bottom bar, where the Contact button SHALL carry a chat/contact icon and the Book Now button SHALL carry a calendar icon.

#### Scenario: Provider section card has no CTA row
- **WHEN** the product page renders its provider section
- **THEN** no Contact or Book Now button appears inside that section

#### Scenario: Bottom bar carries icons
- **WHEN** the product page renders its bottom bar
- **THEN** the Contact button shows a chat/contact icon and the Book Now button shows a calendar icon, and both keep their existing actions

### Requirement: Provider profile offers a contact action
The provider profile page SHALL expose a Contact action that opens the same contact-options flow used elsewhere in the app (in-app chat, call, SMS where available).

#### Scenario: Contact opens the contact sheet
- **WHEN** the user taps the Contact action on the provider profile
- **THEN** the contact action sheet appears with the provider's name and available channels, and each channel performs its action

### Requirement: Home header collapse animates with scroll
On the home page, the pinned header SHALL transition continuously between its expanded greeting state and its compact bar as a function of scroll position (progressive compression and cross-fade), rather than switching at a single offset threshold. Both states SHALL retain the same actions (search, notifications, profile), and a scroll back to the top SHALL restore the full expanded header.

#### Scenario: Progressive collapse while scrolling
- **WHEN** the user scrolls the home feed downward
- **THEN** the expanded header compresses and fades progressively with scroll offset until only the compact bar remains

#### Scenario: Expanding on scroll-to-top
- **WHEN** the user scrolls back to the top of the feed
- **THEN** the full expanded header is restored with the same actions
