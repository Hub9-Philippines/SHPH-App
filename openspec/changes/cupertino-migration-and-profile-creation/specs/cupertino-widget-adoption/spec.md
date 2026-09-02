## Purpose

Standardizes the app's user interface on iOS-style Cupertino widgets across both Android and iOS, so every screen reads as a native iOS app while preserving the brand identity, layout grid, and content contracts defined by other specs.

## ADDED Requirements

### Requirement: Whole-app Cupertino widget styling
The application SHALL render its user-facing widgets using iOS-style Cupertino equivalents on BOTH Android and iOS platforms for: primary and secondary action buttons, on/off switches, text fields, alert/dialog confirmations, transient notifications, the bottom tab bar, date and time pickers, activity indicators, navigation bars, list/form sections, and segmented controls. Adopting Cupertino styling MUST NOT change the brand primary-color and typography tokens, the fixed five-tab shell, the 16px/24px layout grid, the empty-state copy mandated by layout specs, or any backend contract.

#### Scenario: Button styling
- **WHEN** the user sees a primary or secondary action control on any screen
- **THEN** it renders in the iOS-style button look (filled/rounded) rather than a Material elevation-styled button

#### Scenario: Switch styling
- **WHEN** a screen shows an on/off setting
- **THEN** it renders as an iOS-style switch

#### Scenario: Text input styling
- **WHEN** the user sees or focuses a text field
- **THEN** it renders as a rounded, borderless iOS-style field consistent across every screen

#### Scenario: Confirmation styling
- **WHEN** a modal confirmation or destructive decision is presented
- **THEN** it uses the iOS alert/action-sheet style, with distinct styling for destructive actions

#### Scenario: Loading styling
- **WHEN** a screen is loading content
- **THEN** progress is shown with the iOS activity spinner

#### Scenario: Icon set preserved
- **WHEN** a glyph decorates a control
- **THEN** it remains drawn from the existing Material glyph set (`Icons.*`) rather than the narrower Cupertino set

### Requirement: iOS page transitions and touch feel
All route transitions SHALL use the iOS slide-from-right page transition on every platform, and touch targets SHALL conform to iOS-sized control proportions without changing the layout grid.

#### Scenario: Transition on Android
- **WHEN** the user pushes a new route on an Android device
- **THEN** the transition slides from the right exactly as on iOS

#### Scenario: Touch target sizing
- **WHEN** the user interacts with any control
- **THEN** its touch target matches iOS sizing guidance while layout spacing remains unchanged

### Requirement: Cupertino tab-bar shell
The app's bottom tab shell SHALL present exactly five targets — Home, Explore, Bookings, Messages, Profile — in an iOS-style tab bar whose active item is highlighted with the theme primary tint and inactive items are muted. The bar SHALL respect safe areas so it stays clear of device notches and the home indicator.

#### Scenario: Five tabs preserved
- **WHEN** the shell renders
- **THEN** exactly the five tab targets appear in order with the active item primary-tinted and inactive items muted

#### Scenario: Safe area handling
- **WHEN** the shell renders on a notched device
- **THEN** the tab bar content avoids the status bar and home indicator

### Requirement: iOS date and time pickers
Date and time selection SHALL be presented with iOS-style pickers (spinner/date-wheel presentation in a modal sheet) instead of Material calendar dialogs.

#### Scenario: Date selection
- **WHEN** the user chooses a date
- **THEN** an iOS-style date picker is presented and returns the chosen date

#### Scenario: Time selection
- **WHEN** the user chooses a time
- **THEN** an iOS-style time picker is presented and returns the chosen time

### Requirement: Brand and content invariants under Cupertino adoption
The Cupertino adoption SHALL preserve the royal-blue primary theme token and Plus Jakarta Sans typography, the five-tab shell, the 16px/24px layout grid, all empty-state copy, the pull-to-refresh reload semantics, and existing backend contracts. Where a Cupertino widget cannot represent a branded component, the existing custom component SHALL be restyled to match the iOS look while keeping its defined tokens and behavior.

#### Scenario: Brand tokens preserved
- **WHEN** any page renders its primary accents
- **THEN** they use the existing theme tokens rather than new colors

#### Scenario: Copy unchanged
- **WHEN** an empty state renders
- **THEN** its copy is identical to the pre-adoption copy