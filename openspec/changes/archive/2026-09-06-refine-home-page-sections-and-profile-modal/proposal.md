## Why

The home page currently gives empty booking space visual prominence, conditionally hides the nearby-trending content, and uses a modal interaction for the profile action that does not match the desired mobile behavior. Refining these states will keep the page focused for users without bookings while making local discovery and profile actions consistently available.

## What Changes

- Hide the home-page "Your bookings" section when the user has no bookings, while preserving it when bookings exist.
- Move the "Trending near you" section above "Need help right now" and remove the condition that currently hides trending content.
- Replace the home-page profile button modal implementation with `showModalBottomSheet`.

## Capabilities

### New Capabilities

- `home-screen-experience`: Defines the home-page section visibility and ordering rules and the profile action's bottom-sheet interaction.

### Modified Capabilities

- None.

## Impact

- Affected Flutter home-page UI and its profile action callback.
- Existing booking data/state used to determine whether the bookings section renders.
- Existing trending-near-you content and profile modal contents remain in use; no backend API or dependency changes are expected.
