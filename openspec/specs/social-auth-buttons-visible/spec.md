# social-auth-buttons-visible Specification

## Purpose

Ensures the Google and Apple sign-in buttons on the auth entry page keep legible label and icon foregrounds on any background, so users can always see what the buttons say.

## Requirements

### Requirement: Social sign-in buttons render legible labels and icons
The auth entry page SHALL render its Google and Apple sign-in buttons with an explicit foreground color for both the brand icon and the label that contrasts with the button's surface in light mode; the label MUST NOT pick up an invisible (e.g., white-on-white) default from the ambient text style.

#### Scenario: Light surface shows contrast
- **WHEN** the auth entry page renders its Google and Apple buttons on the light background
- **THEN** the labels and icons use a dark foreground token and are clearly readable against the surface

#### Scenario: Disabled during sign-in stays visible
- **WHEN** a social button is disabled while a sign-in request is in flight
- **THEN** the label remains legible rather than collapsing to the background color
