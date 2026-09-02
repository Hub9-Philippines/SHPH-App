## Purpose

Adds full Filipino (fil) localization to the app and narrows the advertised locales to exactly English and Filipino, so language switching is coherent and reflects instantly.

## ADDED Requirements

### Requirement: Filipino locale is fully supported
The app SHALL support the `fil` locale for every localizable string present in the English template, SHALL advertise exactly `en` and `fil` as supported locales, and SHALL render the chosen language across the whole app.

#### Scenario: Filipino strings render
- **WHEN** the active locale is `fil`
- **THEN** localizable app strings render in Filipino

#### Scenario: Supported locales are en and fil only
- **WHEN** the app exposes its supported locales to the framework
- **THEN** exactly English and Filipino (`en`, `fil`) are advertised and centralized language pickers offer only these two

### Requirement: Locale switch reflects in real time
Changing the active locale SHALL update the currently visible UI to the new language without a restart or re-login.

#### Scenario: Switching from English to Filipino
- **WHEN** a user changes the locale to Filipino while the app is running
- **THEN** the active screen's localizable strings update immediately

#### Scenario: Switching back to English
- **WHEN** a user changes the locale back to English while the app is running
- **THEN** the active screen's localizable strings update immediately to English