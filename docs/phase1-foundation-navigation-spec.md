# Phase 1 — Foundation & Navigation: Implementation Spec

**Status:** Pre-execution | **Effort:** ~2 weeks | **Dependencies:** None
**Reference:** Web app at `C:\Users\Administrator\dev\shph-web`

---

## 1.1 Design Tokens — `lib/theme/app_theme.dart`

### 1.1.1 Web App Colors (Source of Truth)

The web app (`src/theme/variables.css`) defines these tokens:

```css
--shph-primary: #63cbd6;         /* BINI Teal */
--shph-primary-dark: #49b8c4;
--shph-primary-text: #0d6d78;    /* dark teal for text on white (AA >=5.6:1) */
--shph-primary-light: #d4f0ef;
--shph-gradient-hero: linear-gradient(125deg, #0d6d78, #63cbd6);
--shph-gradient-cta: linear-gradient(180deg, #63cbd6, #49b8c4);
--shph-gradient-profile-hero: linear-gradient(135deg, #0f8a6c, #17b890 55%, #73d8b4);
--shph-success: #249689;
--shph-warning: #f9cf58;
--shph-error: #dc2626;
--shph-bg-primary: #ffffff;
--shph-bg-secondary: #f1f5f9;
--shph-bg-page: #f8fafc;
--shph-text-primary: #0f172a;
--shph-text-secondary: #64748b;
--shph-text-hint: #94a3b8;
--shph-border: #e2e8f0;
--shph-radius-card: 24px;
--shph-shadow-card: 0 8px 24px rgba(16, 24, 40, 0.08);
```

**Figma/Design Note:** The Flutter app's existing green (`#0F8A6C`) matches the web's `--shph-gradient-profile-hero` green family. The web's primary (`#63cbd6`) is a lighter teal. For consistency, adopt web's primary teal while keeping existing green as a secondary/accent. The gradient hero from web (`#0d6d78 → #63cbd6`) should be used in the Flutter Home header.

### 1.1.2 New AppThemeData Fields

```dart
// ---- Add after existing color fields ----
final Color success;            // #249689
final Color warning;            // #f9cf58
final Color primaryLight;       // #d4f0ef
final Color primaryDark;        // #49b8c4
final Color primaryText;        // #0d6d78 (teal text for AA contrast)
final Color surfaceAlt;         // #f1f5f9 (--shph-bg-secondary)
final Color border;             // #e2e8f0
final Color textTertiary;       // #94a3b8 (--shph-text-hint)
```

### 1.1.3 Factory Constructor Values

```dart
success: const Color(0xFF249689),
warning: const Color(0xFFF9CF58),
primaryLight: const Color(0xFFD4F0EF),
primaryDark: const Color(0xFF49B8C4),
primaryText: const Color(0xFF0D6D78),
surfaceAlt: const Color(0xFFF1F5F9),
border: const Color(0xFFE2E8F0),
textTertiary: const Color(0xFF94A3B8),
```

### 1.1.4 Standardized Shadows

```dart
static const List<BoxShadow> cardShadow = [
  BoxShadow(
    color: Color(0x140F1828),   // rgba(16,24,40,0.08)
    blurRadius: 24,
    offset: Offset(0, 8),
  ),
];

static const List<BoxShadow> softShadow = [
  BoxShadow(
    color: Color(0x0F10264A),   // rgba(16,38,74,0.06)
    blurRadius: 6,
    offset: Offset(0, 1),
  ),
];

static const List<BoxShadow> elevatedShadow = [
  BoxShadow(
    color: Color(0x2E11264A),   // rgba(17,38,74,0.18)
    blurRadius: 26,
    offset: Offset(0, 10),
  ),
];
```

### 1.1.5 Border Radius Constants

```dart
static const double radiusSm = 10;
static const double radiusMd = 14;
static const double radiusLg = 16;
static const double radiusCard = 24;
static const double radiusPill = 9999;
```

### 1.1.6 Container Width Constants

```dart
static const double containerNarrow = 560;
static const double containerReadable = 760;
static const double containerWide = 1100;
static const double containerDashboard = 1200;
```

### 1.1.7 Status Pill Colors (from web)

```dart
// Status colors matching web --shph-status-* tokens
static const Color statusConfirmed = Color(0xFF0D6D78);
static const Color statusConfirmedBg = Color(0xFFD4F0EF);
static const Color statusActive = Color(0xFF166534);
static const Color statusActiveBg = Color(0xFFE7F6EC);
static const Color statusCompleted = Color(0xFF475569);
static const Color statusCompletedBg = Color(0xFFEEF1F5);
static const Color statusCancelled = Color(0xFFB91C1C);
static const Color statusCancelledBg = Color(0xFFFDE9E9);
static const Color statusPending = Color(0xFF92400E);
static const Color statusPendingBg = Color(0xFFFDF0DD);
```

---

## 1.2 ScreenHeader — `lib/components/screen_header.dart`

### 1.2.1 Web Reference (`src/components/ScreenHeader.vue`)

The web component is a simple header with title + optional subtitle + optional action slot. The action renders as a "chip" — a 46×46 rounded container with shadow and icon. No built-in back button.

```
┌──────────────────────────────────────┐
│  Title               [ 🎛️ ]         │
│  subtitle                             │
└──────────────────────────────────────┘
```

Title: 24px, w700, color `--shph-text-heading` (#0f172a).  
Subtitle: 13px, color `--shph-text-secondary` (#64748b).  
Chip: 46×46, border-radius 16px, bg white, shadow `--shph-shadow-card`, icon 22px, color `--shph-primary-text`.

### 1.2.2 Flutter Implementation

```dart
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,        // optional widget rendered in the chip slot
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 18),
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry padding;
}
```

### 1.2.3 Layout

```dart
Padding(
  padding: padding,
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: headlineSmall override w700, color: #0F172A),
            if (subtitle != null)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(subtitle!, style: bodySmall, color: #64748B),
              ),
          ],
        ),
      ),
      if (action != null)
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.cardShadow,
          ),
          child: action,
        ),
    ],
  ),
)
```

### 1.2.4 Usage

```dart
// Messages page
ScreenHeader(
  title: 'Messages',
  subtitle: 'Stay close to providers, updates, and support.',
  action: IconButton(
    onPressed: () => context.pushNamed(MyNotificationsWidget.routeName),
    icon: Icon(Icons.tune_rounded, color: AppTheme.of(context).primaryText),
  ),
)
```

---

## 1.3 SectionHeader — `lib/components/section_header.dart`

### 1.3.1 Web Reference (`src/components/SectionHeader.vue`)

```
┌──────────────────────────────────────┐
│  Title               See all  →      │
└──────────────────────────────────────┘
```

Title: 15px, w600, color `--shph-text-primary` (#0f172a).  
See all: 12px, w600, color `--shph-primary-text` (#0d6d78). Optional `router-link` or button with `@see-all` emit.

### 1.3.2 Flutter Implementation

```dart
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.seeAllRoute,     // push named route on "See all" tap
    this.onSeeAll,        // override with custom callback
    this.padding,
  });
}
```

### 1.3.3 Usage

```dart
SectionHeader(
  title: 'Explore Services',
  seeAllRoute: '/categories',
)
```

---

## 1.4 ContentContainer — `lib/components/content_container.dart`

### 1.4.1 Web Reference (`src/components/layout/ContentContainer.vue`)

Props: `variant` (narrow|readable|wide|dashboard|full), `padded` (bool), `center` (bool).

Max widths:
- narrow: 560px
- readable: 760px
- wide: 1100px
- dashboard: 1200px

Padding when `padded`: 16px horizontal.

### 1.4.2 Flutter Implementation

```dart
class ContentContainer extends StatelessWidget {
  const ContentContainer({
    super.key,
    required this.child,
    this.variant = ContentVariant.wide,
    this.padded = false,
    this.center = false,
  });

  final Widget child;
  final ContentVariant variant;
  final bool padded;
  final bool center;
}

enum ContentVariant { narrow, readable, wide, dashboard, full }
```

### 1.4.3 Layout

```dart
Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: _maxWidth),
    child: padding != null || center
      ? Align(
          alignment: Alignment.topCenter,
          child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
        )
      : child,
  ),
)
```

Where `_maxWidth` maps from `ContentVariant`:
- narrow → 560
- readable → 760
- wide → 1100
- dashboard → 1200
- full → double.infinity

---

## 1.5 NavBar Alignment — `lib/main.dart`

### 1.5.1 Web Tab Structure (`src/views/shared/TabsLayout.vue`)

The web uses Ionic tabs with 5 tabs. Icons from `ionicons`:

| Tab | Web Icon | Flutter Icon | Notes |
|-----|----------|-------------|-------|
| Home | `homeOutline` | `Icons.home_outlined` | ✅ Keep |
| Categories | `gridOutline` | `Icons.grid_view_outlined` | Rename from "Category" → "Explore" |
| Bookings | `calendarOutline` | `Icons.content_paste_rounded` | Consider changing to `calendar_month_outlined` |
| Messages | `chatbubbleOutline` | `Icons.chat_outlined` | ✅ Keep with badge (already implemented) |
| Profile | `personOutline` | `Icons.person` | ✅ Keep |

### 1.5.2 Role-Aware Tabs (Phase 1 MVP — Flag Only)

Web conditionally switches tabs for providers. Add `isProvider` to `FFAppState` but defer full role-aware nav to Phase 7.

```dart
// FFAppState
bool _isProvider = false;
bool get isProvider => _isProvider;
set isProvider(bool value) {
  _isProvider = value;
  notifyListeners();
}
```

### 1.5.3 Badge Position (Match Web Style)

Web badge CSS positions the badge at `top: 2px; left: 50%; transform: translateX(10px)`. Update Flutter NavBar badge position to match:

```dart
Positioned(
  top: -2,
  right: -8,     // was -6, adjusted for web alignment
  child: Container(...),
)
```

---

## 1.6 Explore Page — `lib/main/explore/`

### 1.6.1 Web Reference (`src/views/tabs/ExplorePage.vue`)

Template structure:
```
ScreenHeader("Explore", subtitle: "Find and book trusted local pros")
Search bar (ion-searchbar)
SectionHeader("Categories") — "See All" link to /categories
Horizontal scrolling category pills
  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐
  │ icon  │ │ icon  │ │ icon  │ │ icon  │  ← horizontal scroll
  │ name  │ │ name  │ │ name  │ │ name  │
  └──────┘ └──────┘ └──────┘ └──────┘
View toggle: List | Map (ion-segment)
Listings (ServiceCard) or Map (ExploreMapView)
Infinite scroll pagination
```

**Key differences from Home page:** Explore has category pills (horizontal, NOT grid), a list/map view toggle, and infinite-scroll paginated listings.

### 1.6.2 New Files

```
lib/main/explore/
├── explore_widget.dart
└── explore_model.dart
```

### 1.6.3 ExploreModel

```dart
class ExploreModel extends FlutterFlowModel<ExploreWidget> {
  bool isLoading = true;
  int selectedCategoryId = 0;
  String searchQuery = '';
  List<CategoryPillData> categories = [];
  List<ServiceListingTile> listings = [];
  bool hasMore = true;
  int page = 1;

  Future<void> loadCategories() async { /* ... */ }
  Future<void> loadListings({bool refresh = false}) async { /* ... */ }
  void onCategoryPill(int catId) { /* toggle filter */ }
  void onSearch(String query) { /* filter results */ }
}
```

### 1.6.4 Category Pill Widget

```dart
class CategoryPill extends StatelessWidget {
  const CategoryPill({
    required this.name,
    this.icon,
    this.emoji,
    this.image,
    this.isActive = false,
    this.onTap,
  });
}
```

Rendered as horizontal button with icon/emoji + name. Active state has colored background.

### 1.6.5 Seed Categories (10 from web)

```dart
// Match web nav order + emoji mapping from web's categoryEmoji()
```

---

## 1.7 Home Page Header Redesign — `lib/main/home/home_widget.dart`

### 1.7.1 Web Reference (`src/views/tabs/HomePage.vue`)

The web home page header has:

```
┌──────────────────────────────────────────┐
│  [S] serbisyo     🔔 [avatar]            │
│  📍 Novaliches, Quezon City ▾            │
│                                          │
│  Good afternoon! 👋                      │
│  Find a trusted professional instantly   │
│                                          │
│  ┌──────────────────────────────────┐    │
│  │ 🔍 Try "tulo sa sink"...     🎤 │    │
│  └──────────────────────────────────┘    │
└──────────────────────────────────────────┘
  Warm aurora gradient background (#0d6d78 → #63cbd6)
```

### 1.7.2 Implementation Plan

1. Replace existing header with warm aurora gradient banner
2. Add brand logo "S" + "serbisyo" text
3. Add notification bell + user avatar (right-aligned)
4. Add location badge (tappable → address picker modal)
5. Add greeting ("Good morning/afternoon/evening")
6. Add headline text
7. Add search bar (tappable → navigate to search page)

### 1.7.3 Gradient Header Container

```dart
Container(
  width: double.infinity,
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0D6D78), Color(0xFF63CBD6)],
    ),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(24),
      bottomRight: Radius.circular(24),
    ),
  ),
  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
  child: Column(children: [/* header content */]),
)
```

---

## 1.8 Pull-to-Refresh Standardization

### 1.8.1 Shared Mixin

```dart
mixin RefreshablePage<T extends StatefulWidget> on State<T> {
  Future<void> onRefresh();

  Widget wrapWithRefresh({required Widget child}) {
    return RefreshIndicator(
      color: AppTheme.of(context).primary,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
```

### 1.8.2 Pages Audit

| Page | Has Refresh | Action |
|------|-----------|--------|
| Home | Partial | ✅ Integrate with new gradient header |
| Explore | New | ✅ Add (web has `ion-refresher`) |
| Messages | ✅ Already has | Keep |
| Bookings | Check | Add if missing |

---

## 1.9 File Change Inventory

| File | Action | Description |
|------|--------|-------------|
| `lib/theme/app_theme.dart` | **Edit** | Add success, warning, primaryLight, primaryDark, primaryText, surfaceAlt, border, textTertiary tokens; add shadow constants; add border radius constants; add container width constants; add status pill colors |
| `lib/app_state.dart` | **Edit** | Add `isProvider` field for future role-aware nav |
| `lib/components/screen_header.dart` | **Create** | New shared component |
| `lib/components/section_header.dart` | **Create** | New shared component |
| `lib/components/content_container.dart` | **Create** | New shared component |
| `lib/components/category_pill.dart` | **Create** | Horizontal pill component for Explore |
| `lib/main.dart` | **Edit** | Rename "Category" tab → "Explore", update badge position, update tab icons order |
| `lib/main/explore/explore_widget.dart` | **Create** | New tab page (category pills + listings) |
| `lib/main/explore/explore_model.dart` | **Create** | New model |
| `lib/main/home/home_widget.dart` | **Edit** | Redesign header with warm aurora gradient, greeting, search bar, location badge |
| `lib/main/home/home_model.dart` | **Edit** | Add greeting computation, search handler |
| `lib/index.dart` | **Edit** | Export ExploreWidget |
| `lib/router/app_router.dart` | **Edit** | Register Explore route |

---

## 1.10 Web Improvements (Fixing Web Inconsistencies)

While replicating the web design, improve these inconsistencies noticed in the web app:

| Issue | Web Behavior | Flutter Improvement |
|-------|-------------|-------------------|
| Category colors | Inconsistent icon bg colors per category | Use consistent primaryLight bg for all |
| Header spacing | Search bar overflows on small screens | Use proper padding + ConstrainedBox |
| Tab icons | mixed icon styles (outlined + filled) | Use outlined consistently |
| Card shadows | Multiple shadow tokens (`shadow-sm/md/lg/card`) | Standardize to 3 tiers (soft/card/elevated) |
| Dark mode colors | Not all tokens have dark variants | Add complete dark mode overrides upfront |
| Status pill contrast | Some status text colors fail AA contrast | Ensure min 4.5:1 contrast ratio |
| Loading states | Inconsistent skeleton patterns | Use single `SkeletonLoadingWidget` everywhere |

---

## 1.11 Acceptance Criteria

- [ ] `AppThemeData` exposes all 8 new color tokens matching web hex values
- [ ] Standardized shadows and border radius constants available on `AppTheme`
- [ ] `ScreenHeader` renders title + optional subtitle + optional action chip
- [ ] `SectionHeader` renders title + optional "See all" link/button
- [ ] `ContentContainer` renders with correct max-width per variant
- [ ] NavBar shows "Explore" tab in position 2 (was "Category")
- [ ] Messages badge position matches web alignment
- [ ] Explore page loads horizontal category pills + listing cards
- [ ] Home page has warm aurora gradient header with greeting, search, location badge
- [ ] Pull-to-refresh works on all list pages
- [ ] All new tokens added without removing existing ones (backward compatible)
- [ ] Web inconsistencies documented and fixed in Flutter implementation
