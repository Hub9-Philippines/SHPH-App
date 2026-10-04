## MODIFIED Requirements

### Requirement: Product page CTAs live in the bottom bar only
On the service/product detail page, the provider section card SHALL NOT render inline Contact or Book Now buttons; those actions SHALL exist only in the page's bottom bar without leading or trailing icons. The Contact and Book Now buttons SHALL render their labels completely on a single line with sufficient button width and padding so that no characters are truncated or clipped by the button container edges.

#### Scenario: Provider section card has no CTA row
- **WHEN** the product page renders its provider section
- **THEN** no Contact or Book Now button appears inside that section

#### Scenario: Bottom bar buttons render without icons
- **WHEN** the product page renders its bottom bar
- **THEN** the Contact and Book Now buttons display plain text labels with no icons, and both keep their respective actions

#### Scenario: Button text is fully legible and unclipped
- **WHEN** the bottom bar renders on any supported device viewport
- **THEN** the full label text for both "Contact" and "Book Now" is visible on a single line with adequate padding and no clipped descenders

## ADDED Requirements

### Requirement: Service listing card Book Now button without icons
On the services listing page, each service card's "Book Now" action button SHALL render as a clean, text-only button without an arrow or trailing icon, sized and padded to display the full label clearly.

#### Scenario: Service card renders text-only Book Now button
- **WHEN** a service card is displayed in the services listing
- **THEN** the "Book Now" action renders without icons and the complete text label is legible and unclipped
