# UI Structure & Behavior Reference

This document is the cheat-sheet for `flutter_reference.html`. It maps the
markup hooks (IDs, data attributes, classes) to their JavaScript behaviors and
to the equivalent Flutter source, so you don't need to re-parse the whole file
every time.

---

## Overall layout

```
<body class="min-h-screen bg-slate-900 font-jakarta ...">          <- phone stage
  <main class="h-[892px] w-[412px] ... bg-canvas ...">
    <div class="flex h-full min-h-0 flex-col">
      <div> status bar (9:41 / signal / wifi / battery) </div>
      <header id="appHeader">        <- Home-only header (gradient) + account menu
      <section id="homeScroll">      <- Home view (scroll container)
      <section id="bookingsView">    <- Bookings view (hidden by default)
      <section id="messagesView">    <- Messages view (hidden by default)
      <section id="profileView">     <- Profile view (hidden by default)
      <nav>  bottom tab bar (data-view buttons) </nav>
    </div>
  <script> ... app JS ... </script>
```

**View switching** (kept minimal):

- `nav [data-view]` buttons with values `home | bookings | messages | profile`.
- `showView(view)` toggles `hidden` on each `#…View` section (and on
  `#appHeader`, which only shows for Home), and updates the active tab classes.
- Home header compacts (hides greeting + shrinks search) on scroll
  (`scrollTop > 28`).

---

## Shared conventions

| Pattern | Meaning |
| --- | --- |
| `hidden` class | Element is not shown on the current tab/view |
| `data-*` attributes | Filter / search keys (booking status, chat name, etc.) |
| `showToast(msg)` | Global demo toast for non-wired actions / feedback |
| `fa-*` classes | Font Awesome icons |
| `text-[10px]…text-[15px]` | Tailwind arbitrary sizes used for this mock scale |

---

## Home view (`#homeScroll`)

Mirrors the web `HomePage.vue` + Flutter explore sections. Order of content:

1. **YOUR BOOKINGS** — two active booking cards (Lockout Assistance "On the way" w/ Mario Santos; Deep Cleaning "In progress" w/ Ana Cruz), each with **Track Service** + message button (demo toasts via `data-callout`).
2. **Need help right now?** — single emergency banner (`data-callout="Emergency help"` → "Get help").
3. **Explore Services** — `.cat-scroll` gradient category cards in a **horizontal scroll** (8 categories) with `data-cat`, On-demand/Project badges, and "from ₱x" prices.
4. **Bayanihan Pool** — shared-neighborhood booking promo card.
5. **Seasonal offer** — navy gradient promo banner.
6. **Trending near you** — horizontal pro cards.
7. **Recommended for you** — stacked pro list.
8. **Referral aside** — purple gradient, share code.

### JS hooks (home)
| Selector | Action |
| --- | --- |
| `.cat-scroll` | Toast "browse <data-cat>" |
| `[data-callout]` | Generic toast for "Bookings only" / "Browse all" / "See all" / "View profile" / "View" / "Book now" / "Bayanihan Pool" / "Emergency help" / "Track booking" / "Message … pro" / "View all bookings" buttons |

Note: the legacy CSS rule `#homeScroll>div:nth-of-type(n+4){display:none}` was **removed** so all sections render.

---

## Messages view (`#messagesView`)

### Key hooks

| Selector | Purpose |
| --- | --- |
| `#messagesSegments [data-msg-tab]` | Segmented buttons: `data-msg-tab="0"` (Chats), `"1"` (Calls history) |
| `#messagesChatTab` | Container of chat cards |
| `#messagesCallTab` | Container of call cards (initially `hidden`) |
| `[data-chat]` | Chat room card; `data-name`, `data-snippet` drive search |
| `[data-call]` | Call entry card; `data-name` drives search |
| `#messagesSearch` / `#messagesSearchClear` | Search input + clear button |
| `#messagesSectionLabel h2` | Section heading ("Recent conversations" / "Call history") |
| `#messagesItemCount` | Live count pill ("N items") |
| `#messagesEmpty` (+ `messagesEmptyIcon/Title/Desc`) | Empty / no-results card |

### JS behavior

- `setMsgTab(index)` toggles the active chip styling and shows the matching
  container, then re-runs the active search filter.
- `filterMessages()`:
  - Reads `#messagesSearch` text (lowercased).
  - For each visible card, matches against `data-name` and `data-snippet`.
  - Updates count; when `0` results, reveals `#messagesEmpty` with tab-appropriate
    heading/description.
- Chat cards show a "Demo: open chat with `<name>`" toast on click.

### Flutter reference
`lib/pages/messages/…` + web `MessagesPage` — segmented Chats/Calls, searchable
chat rooms and call history.

---

## Bookings view (`#bookingsView`)

### Key hooks

| Selector | Purpose |
| --- | --- |
| `#bookingsSearch` / `#bookingsSearchClear` | Search input + clear button |
| `#bookingsChips [data-b-filter]` | Filter chips: `all | pending | completed | canceled` |
| `#bookingsList [data-booking]` | Booking cards with `data-status`, `data-title`, `data-provider`, `data-date` |
| `[data-b-action]` | Card action buttons (`track`, `reschedule`, `review`, `bookAgain`, `viewDetails`) |
| `#bookingsEmpty` (+ `bookingsEmptyIcon/Title/Desc`) | Empty / no-results card |
| `#bookingsRefresh` | Refresh button (shows "Refreshing…" then "up to date" toast) |

### JS behavior

- `styleBookingChips()` re-applies the active/inactive chip classes for the
  selected filter.
- `filterBookings()` combines the selected chip (`data-status` match) **and**
  the search text (`data-title` + `data-provider`), hiding non-matching cards.
  When `0` cards remain it shows `#bookingsEmpty` with a contextual
  heading/description.
- `[data-b-action]` buttons show a "Demo: <label>" toast.

### Flutter reference
`lib/pages/bookings/…` + web `BookingsPage` — filterable, searchable booking
history with per-status actions and empty/error states.
---

## Profile view (`#profileView`)

Layout: sticky header → **hero card** → **verification** → **grouped menu
tiles** → **system access**.

### 1. Hero card (royal-blue gradient)

- Container: `bg-gradient-to-br from-[#1E3A8A] via-[#274FB5] to-[#3B62D9]`.
- Avatar `76×76` with white ring + camera affordance (`#editProfileBtn` area).
- Identity row: name + `fa-circle-check` (verified badge) + location / member
  since + star rating row.
- `#savedPlacesTile` row ("Saved Places · 2 set").
- Stat grid: **Jobs / Rating / Rewards**.

### 2. Verification (KYC) section

- `[data-verify-section]`, heading `VERIFICATION`.
- `#verifyNowBtn` → "Demo: identity verification flow" toast.
- Mirrors Flutter `_buildVerificationSection` (hidden when already verified in
  the real app; shown here in a "Not started" demo state).

### 3. Grouped menu tiles (`[data-menu]`)

Each tile is a full-width button: tinted square icon well (46px) + title +
subtitle + chevron. `[data-menu]` value is used by the demo toast.

| Group (`data-group`) | Tiles | Icon / accent |
| --- | --- | --- |
| **Account** | My Bookings · Payment & Invoices · Language Preference | navy / sky / purple |
| **Preferences & Utilities** | Favorites · My Reviews · Referral Program · Notification Settings · Help Center | pink / orange / indigo / amber / blue |
| **System Access** | Security · provider switch (`#providerToggle`) · Log out (crimson text) | navy / navy / crimson |

### Provider toggle

`#providerToggle` (`role="switch"`, `aria-checked`) toggles `bg-brand` +
`translate-x-5` on the knob and shows a toast.

### Flutter reference

`lib/main/profile/profile_widget.dart` — `_heroGradient` (same three stops),
`_buildHeroCard`, `_buildVerificationSection`, `_buildGroup` with
`TintedMenuTile`. Accent colors used by tile icons (also see `lib/theme/`):

| Token | Hex |
| --- | --- |
| accentNavy | `#1E3A8A` |
| accentSky | `#0EA5E9` |
| accentPurple | `#7C5CFC` |
| accentPink | `#EC4899` |
| accentOrange | `#F97316` |
| accentIndigo | `#6366F1` |
| accentYellow | `#F59E0B` |
| accentBlue | `#2563EB` |
| destructiveCrimson | `#E11D48` |

---

## Maintenance tips

- Any element referenced by JS **must keep its `id`**; `data-*` values are the
  contract for filtering — keep them stable when changing copy.
- Toast is injected once at runtime (`#appToast`); no markup needed.
- To add a new filter chip, add a `<button data-b-filter="X">` and extend
  `bookingLabels` in the script.
- To add a new verification status, update the `#verify*` elements + script.