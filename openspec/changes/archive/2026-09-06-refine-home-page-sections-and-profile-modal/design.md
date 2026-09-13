## Context

The change is limited to the client home-page composition and its profile-action presentation. Existing booking state, trending content, profile actions, theme tokens, and navigation behavior remain the sources of truth; the implementation should adjust rendering and presentation without adding backend contracts or dependencies.

## Goals / Non-Goals

**Goals:**

- Derive the bookings section visibility from whether displayable bookings exist.
- Keep the trending section in the home-page flow regardless of the former conditional gate and place it before the help section.
- Present the existing profile actions through Flutter's modal bottom-sheet mechanism with normal dismissal behavior.
- Preserve existing loading, error, navigation, and theme behavior for the affected content.

**Non-Goals:**

- Changing booking retrieval, booking models, or API behavior.
- Changing the content, ranking, or data source of trending items.
- Redesigning profile actions or changing their destinations.
- Modifying other tab screens or global navigation.

## Decisions

- Use the existing booking collection/state as the sole condition for the bookings section. This keeps the rule aligned with the data already used by the home page and avoids introducing a second notion of an empty booking state.
- Keep the trending widget/content implementation intact and change only its placement and enclosing visibility logic. This minimizes behavioral drift while making its presence independent of the old condition.
- Replace the profile button's current modal presentation with `showModalBottomSheet` at the existing action boundary. This provides a true bottom-anchored modal, preserves the current action content, and supplies standard barrier and dismissal semantics without a new navigation route.
- Retain existing theme and safe-area conventions inside the sheet. The sheet should be sized by its content and remain usable when dismissed by the barrier, back navigation, or a sheet action.

## Risks / Trade-offs

- [Risk] A no-booking state may change vertical spacing around neighboring sections. -> Mitigation: let the page flow naturally after removing the absent section and verify both booking and no-booking layouts.
- [Risk] Trending data may be empty while the section remains in the layout. -> Mitigation: preserve the existing component's empty/loading behavior and validate that the section does not crash or create an unusable gap.
- [Risk] Moving to a bottom sheet can alter dismissal or inset behavior on small screens. -> Mitigation: use the framework modal-sheet API with the existing theme/safe-area handling and test open, barrier-dismiss, and back-dismiss flows.

## Migration Plan

1. Update the home-page rendering and profile-button callback.
2. Run focused home-page/widget tests and static analysis.
3. Roll back by restoring the prior section ordering/visibility and modal callback if validation identifies a regression; no data migration is required.
