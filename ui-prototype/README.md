# Serbisyo — UI Prototype (HTML/Flutter reference)

This folder contains the **HTML prototype** of the unified Serbisyo client UI
(Home / Bookings / Messages / Profile), modeled as a mobile-first phone mockup
(`412×892`) built with **Tailwind CSS** (CDN), **Font Awesome** icons, and the
**Plus Jakarta Sans** typeface.

The work here mirrors the Flutter client in `E:\Dev\SHPH` (`lib/**/*_widget.dart`)
and the web app in `E:\Dev\shph-web`. Flutter is the **primary visual reference**.

## Files

| File | Purpose |
| --- | --- |
| `flutter_reference.html` | Single-file prototype containing all four views + bottom-nav switching (SPA-style). Open directly in a browser. |
| `README.md` | This overview. |
| `UI_STRUCTURE.md` | Detailed guide to every view, key selector, data attribute, and JS behavior — so the markup doesn't have to be re-read repeatedly. |

## How to run

There are no build steps or dependencies — it's a static HTML file:

- **Double‑click** `flutter_reference.html` in a file explorer, or
- Serve it locally (optional), e.g. `python -m http.server 8000` from this
  folder and open `http://localhost:8000/flutter_reference.html`.

Tailwind, Font Awesome, and fonts load from CDN, so an internet connection is
normally required.

## View status

| View | Status |
| --- | --- |
| Home | ✓ Header compact-on-scroll, quick account menu; emergency banner, horizontal-scroll Explore Services, Bayanihan pool, seasonal offer, trending/recommended pros, referral card |
| Bookings | ✓ Search, filter chips, booking cards with action rows, empty + refresh states |
| Messages | ✓ Segmented **Chats / Calls**, search, chat room cards, call history cards, empty states |
| Profile | ✓ Hero gradient card, KYC verification section, grouped menu tiles (Account / Preferences & Utilities / System Access), provider toggle |

## Design tokens

| Token | Value | Used for |
| --- | --- | --- |
| `brand` | `#1E3A8A` | Primary navy (buttons, active chips, icon accents) |
| `ink` | `#0F172A` | Headings / primary text |
| `canvas` | `#F8FAFC` | App background |
| Hero gradient | `#1E3A8A → #274FB5 → #3B62D9` | Royal-blue profile hero card (matches Flutter `_heroGradient`) |
| Accent icons | see `UI_STRUCTURE.md` | Tinted square icon wells in profile tiles |

See `UI_STRUCTURE.md` for the full selector map and behavior notes.