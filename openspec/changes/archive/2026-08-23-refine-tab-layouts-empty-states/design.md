## Context

Current geometry, measured from source:

- **Margins**: ScreenHeader pads 20px horizontally; Explore inner blocks pad 20; Bookings and Messages pad 20; HeroOfferBanner/InviteEarnBanner margin 20. Three different effective grids depending on component.
- **Header**: ScreenHeader bottom padding 18px; title→subtitle internal gap 4px.
- **Explore carousel**: item separator 14px (skeleton uses 12), tile width 76px, label `maxLines: 1` + ellipsis at ~76px → "Aircon Repair" clips; icon→label gap already a `SizedBox(height: 6)`.
- **Promo banner**: internal padding 18px, headline→CTA gap 14px.
- **Proximity cards**: width 220px, price rendered in `titleSmall` (16px w800) inside an `Expanded` right-aligned cell that ellipsizes when the distance text is long ("Starting P..."); inter-card margin already 12px.
- **Bookings**: filter chips exist (`BookingsFilter` enum: all/pending/completed/canceled); `_buildEmptyState` shows one generic heading/description regardless of chip, with a separate search no-match variant.
- **Messages**: search field radius 22, segment container radius 24 height 68 wrapping `CupertinoSlidingWidgetMessages`; section label + teal capsule ("N items") already dynamic per segment; empty states already swap icon/copy per segment but use `primaryLight`/`primaryDark` colors and a 28px-radius card.

Constraints from AGENTS.md: theme tokens for color/font (Plus Jakarta Sans stays), `flutter analyze` at 0 errors, dark mode must keep working. Brand palette (royal blue `actionPrimary`, light teal family, deep purple referral gradient/accentPurple) is untouched by this change.

## Goals / Non-Goals

**Goals:**
- One horizontal grid (16px) and one block rhythm (24px) across the three tabs, enforced via named spacing constants.
- Exact carousel/banner metrics on Explore; zero truncation for category labels and price fields.
- Filter-driven empty-state copy on Bookings; segment-driven teal empty states on Messages aligned to the new radius/grid profile.

**Non-Goals:**
- Redesigning Home or Profile screens (only header constant change applies there passively).
- Changing any navigation, data loading, refresh behavior, or route.
- Replacing the Cupertino sliding custom widgets' internals — only their containers/margins change.
- New dependencies or icon-font swaps.

## Decisions

1. **Spacing constants live on `AppThemeData` as statics**: `spaceXs = 4`, `spaceSm = 8`, `spaceMd = 12`, `spaceLg = 16`, `spaceXl = 24`. Rationale: this change exists to enforce a grid; literals scattered through five files is how the drift happened. Only touched call sites migrate to the constants — repo-wide literal sweep is explicitly out of scope.
2. **ScreenHeader gets the grid built-in**: default padding becomes `EdgeInsets.fromLTRB(16, 12, 16, 0)` with the following element owning its own 16px top gap; title→subtitle stays 4px (typographic leading). The brief's "16dp between title and subtitle/search bar" is interpreted as header-block → next-component distance = 16px; intra-header leading of 16px would look broken. Callers currently passing custom paddings are updated to drop them so all three tabs inherit the default. Alternative (per-caller explicit values) rejected — it recreates drift.
3. **Block separation via wrapper, not magic gaps**: Explore feed children get wrapped so each standalone block ends with `SizedBox(height: spaceXl)`; banners drop their asymmetric margins (`(20,4,20,0)` → horizontal handled by grid, vertical by the block separator). InviteEarnBanner keeps its own trailing margin but normalizes to the same constants.
4. **Category tiles: width 96px + `FittedBox(scaleDown)` on the label**, keeping `maxLines: 1` centered. "Aircon Repair" measures ~78px at labelSmall, fitting inside 96px without scaling; longer names scale down instead of clipping. Separator fixed to exactly `spaceMd` (12px) for both real and skeleton lists; icon→label `SizedBox(height: 6)` kept and made exact.
5. **Proximity cards: width 220 → 240 and price drops to 15px** (titleSmall.override fontSize 15). Combined headroom (~30px wider cell minus narrower glyphs) clears "Starting ₱450" even beside a long distance string. Inter-card gap already 12px — expressed as `spaceMd`.
6. **Bookings empty states: a pure function resolver on the model**, `(String heading, String description) emptyStateCopy(BookingsFilter filter, bool hasSearchQuery)`, returning the brief's four pairs verbatim plus the existing search-no-match variant taking precedence when a query is active. Widget-side, only rendering changes (radius normalized to 16px profile).
7. **Messages**: search field and segment container both normalize to radius 16 and 16px horizontal padding (container height 68 stays; internal 6px inset stays). Empty-state illustration switches to `AppThemeData.successTeal.withValues(alpha: 0.12)` background with `successTeal` glyph — matching the tinted-icon language already shipped on Profile/Settings — chat bubble (`mark_chat_unread_rounded`) vs handset (`call_end_rounded`). Empty card radius 28 → 16. Section-label capsule untouched (already teal, already dynamic).
8. **Radius normalization scope**: only elements this change touches adopt the 16px profile (banner interior images keep 16, CTA button keeps its own smaller radius as a nested control). No repo-wide radius migration.

## Risks / Trade-offs

- [Wider proximity cards show fewer cards per viewport] → 240px still fits ~1.6 cards on small phones, preserving the peek affordance; accepted.
- [FittedBox can shrink labels illegibly if a category name is extreme] → Scale floor guarded by maxLines:1 + center alignment; worst case matches today's clipping but never worse.
- [ScreenHeader default change affects Home/Profile too] → Both already sit on the same intended grid; visual delta is limited to 4–2px shifts, verified in the spacing audit task.
- [Empty-state copy is English-only strings in code] → Matches current practice (no l10n pipeline for these surfaces); noted for future l10n work.

## Migration Plan

Three independent slices, each analyze-green: (1) spacing constants + ScreenHeader default + banner/proximity components; (2) Explore screen wiring; (3) Bookings + Messages empty states. Rollback = revert slice commits individually.

## Open Questions

None blocking — interpretation of the 16dp title gap is recorded in Decision 2.
