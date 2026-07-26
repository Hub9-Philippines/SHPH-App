# Phase 3 — Messages, Settings & Dark Mode Audit: Implementation Spec

**Status:** Pre-execution | **Effort:** ~1 week | **Dependencies:** Phase 1 + 2 (design tokens, shared components, role-aware nav)
**Reference:** Web app at `C:\Users\Administrator\dev\shph-web`

---

## 3.1 Messages Page Refresh — `lib/main/messages/`

### 3.1.1 Current State

`MessagesWidget` has pull-to-refresh, a segment toggle (Chats / History), and a CustomScrollView. Uses hardcoded hex values for title/description colors.

### 3.1.2 Target

- Apply `ScreenHeader` to replace the manual top section (title + notification bell)
- Apply `ContentContainer` for content layout
- Replace hex text colors (`#16202A`, `#6F7B86`) with `AppTheme.of(context).primaryText` / `textTertiary`
- Apply `AppThemeData.border` for card borders
- Keep existing pull-to-refresh and tab switching logic

### 3.1.3 Files Changed

| File | Change |
|------|--------|
| `lib/main/messages/messages_widget.dart` | Add ScreenHeader, ContentContainer, replace hex → tokens |
| `lib/main/messages/messages_model.dart` | Minor if needed |

---

## 3.2 Settings & Preferences Pages

### 3.2.1 Scope

Four sub-pages that share a similar pattern (list of items with icons):

| Page | File | Lines |
|------|------|-------|
| Settings | `lib/pages/settings/settings_widget.dart` | ~200 |
| Addresses | `lib/pages/addresses/addresses_widget.dart` | ~700 |
| Payment Methods | `lib/main/payment_methods/payment_methods_widget.dart` | ~200 |
| My Notifications | `lib/pages/my_notifications/my_notifications_widget.dart` | ~500 |

### 3.2.2 Target (all four)

- Apply `ScreenHeader` for page title + subtitle
- Apply `ContentContainer` for responsive layout
- Replace hardcoded `Colors.white` with `AppTheme.of(context).primaryBackground`
- Replace hex text colors with `primaryText`, `textTertiary`, `secondaryText`
- Add `AppThemeData.border` to card containers

### 3.2.3 Files Changed

| File | Change |
|------|--------|
| `lib/pages/settings/settings_widget.dart` | ScreenHeader, tokens |
| `lib/pages/addresses/addresses_widget.dart` | ScreenHeader, tokens |
| `lib/main/payment_methods/payment_methods_widget.dart` | ScreenHeader, tokens |
| `lib/pages/my_notifications/my_notifications_widget.dart` | ScreenHeader, tokens |

---

## 3.3 Search Page Refresh — `lib/pages/search_page/`

### 3.3.1 Current State

Search page with text field and results list. Uses hardcoded colors.

### 3.3.2 Target

- Apply `CategoryPill` for filter chips (replacing any manual chip rendering)
- Apply `ContentContainer` for results layout
- Replace hex colors with theme tokens
- Add `ScreenHeader` or integrate search bar with new design tokens

### 3.3.3 Files Changed

| File | Change |
|------|--------|
| `lib/pages/search_page/search_page_widget.dart` | CategoryPill, ContentContainer, tokens |

---

## 3.4 Full Dark Mode Audit

### 3.4.1 Scope

A systematic sweep across remaining pages to replace hardcoded light-mode colors:

| Pattern | Replacement |
|---------|-------------|
| `Colors.white` as card/container background | `AppTheme.of(context).primaryBackground` |
| `Color(0xFFF5F7FA)` as scaffold background | `AppTheme.of(context).secondaryBackground` |
| `Color(0xFF16202A)` as title text | `AppTheme.of(context).primaryText` |
| `Color(0xFF6F7B86)` / `#64748B` as body text | `AppTheme.of(context).secondaryText` |
| `Color(0xFF8A97A4)` as hint/tertiary text | `AppTheme.of(context).textTertiary` |
| `Color(0xFFE2E8F0)` as border | `AppTheme.of(context).border` |
| Custom box shadows | `AppThemeData.shadowCard` / `shadowSoft` / `shadowElevated` |

### 3.4.2 Pages to Audit

| Page | File | Priority |
|------|------|----------|
| Favorites | `lib/pages/favorites/favorites_widget.dart` | Medium |
| My Reviews | `lib/pages/my_reviews/my_reviews_widget.dart` | Medium |
| Help | `lib/pages/help/help_page.dart` | Low |
| Chat | `lib/pages/chat_page/chat_page_widget.dart` | Low |
| Create Profile | `lib/pages/create_profile/create_profile_widget.dart` | Low |
| Edit Profile | `lib/pages/edit_profile/edit_profile_widget.dart` | Low |
| Security Settings | `lib/pages/security_settings/security_settings_widget.dart` | Low |

---

## 3.5 File Change Inventory

| File | Action | Description |
|------|--------|-------------|
| `lib/main/messages/messages_widget.dart` | **Edit** | ScreenHeader, ContentContainer, hex → tokens |
| `lib/pages/settings/settings_widget.dart` | **Edit** | ScreenHeader, ContentContainer, tokens |
| `lib/pages/addresses/addresses_widget.dart` | **Edit** | ScreenHeader, ContentContainer, tokens |
| `lib/main/payment_methods/payment_methods_widget.dart` | **Edit** | ScreenHeader, ContentContainer, tokens |
| `lib/pages/my_notifications/my_notifications_widget.dart` | **Edit** | ScreenHeader, ContentContainer, tokens |
| `lib/pages/search_page/search_page_widget.dart` | **Edit** | CategoryPill, ContentContainer, tokens |
| `lib/pages/favorites/favorites_widget.dart` | **Edit** | Dark mode tokens |
| `lib/pages/my_reviews/my_reviews_widget.dart` | **Edit** | Dark mode tokens |

---

## 3.6 Dependencies

- Phase 1: `AppThemeData` tokens, `ContentContainer`, `ScreenHeader`, `CategoryPill`
- Phase 2: none

---

## 3.7 Non-Goals

- TM flow screens (already functional — visual polish deferred)
- Booking funnel redesign (deferred to later phase)
- Pro dashboard sub-pages (already touched in Phase 2)
- AI recommendations or search engine changes (Phase 4+ scope)

---

## 3.8 Acceptance Criteria

- [ ] Messages page uses ScreenHeader, ContentContainer, and theme tokens
- [ ] Settings, Addresses, Payment Methods, Notifications pages use ScreenHeader, ContentContainer, and theme tokens
- [ ] Search page uses CategoryPill for filter chips and theme tokens
- [ ] All audited pages render correctly in dark mode
- [ ] No hardcoded `Colors.white` card backgrounds remain in touched pages
- [ ] No regression in page functionality (favorites, reviews, help, chat still work)
