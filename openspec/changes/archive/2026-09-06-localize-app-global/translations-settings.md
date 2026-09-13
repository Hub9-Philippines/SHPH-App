# Task 3.8 — `settings` + `theme_settings` + `language_settings` + `notification_preferences`

Status: **Done** (verified `flutter analyze` 0 errors; 699 total = baseline ~699 noise)

## Screens & keys
- `settings_widget.dart` → `se*` (27)
- `theme_settings_widget.dart` → `th*` (7)
- `language_settings_widget.dart` → `lg*` (5, incl. `lgChanged{language}`)
- `notification_preferences_widget.dart` → `np*` (2)

39 keys added to both `app_en.arb` and `app_fil.arb` (parity maintained). `flutter gen-l10n` clean (only the stale `es` untranslated warning — acceptable).

## User-approved Taglish batch (authoritative wording)
| Key | English | Taglish |
|-----|---------|---------|
| seTitle | Settings | Settings |
| seSubtitle | Manage preferences, account, and support options. | I-manage ang preferences, account, at support options. |
| seHeroTitle | Control your app experience | Kontrolin ang app experience mo |
| seHeroSubtitle | Appearance, security, notifications, and support all live here. | Nandito lahat ang appearance, security, notifications, at support. |
| seGeneralSection | General & Account Configuration | General at Account Configuration |
| seLanguage | Language | Language |
| seLanguageSubtitle | Choose the language used across the app | Piliin ang wika na gagamitin sa app |
| seNotifications | Notifications | Notifications |
| seNotificationsSubtitle | Review booking, message, and payment updates | I-check ang booking, message, at payment updates |
| seSecurity | Security | Security |
| seSecuritySubtitle | Password, login protection, and 2FA settings | Password, login protection, at 2FA settings |
| seEditProfile | Edit profile | I-edit ang profile |
| seEditProfileSubtitle | Update your personal registration information | I-update ang personal registration info mo |
| seLegalSection | Legal & Feedback | Legal at Feedback |
| seSendFeedback | Send feedback | Magpadala ng feedback |
| seSendFeedbackSubtitle | Open an email draft to share product feedback | Magbukas ng email draft para mag-share ng feedback |
| seTermsTitle | Terms of Service | Terms of Service |
| seTermsSubtitle | Read the terms governing your use of Serbisyo | Basahin ang terms sa paggamit ng Serbisyo |
| sePrivacyTitle | Privacy Policy | Privacy Policy |
| sePrivacySubtitle | Understand how we collect and use your data | Alamin kung paano namin kinokolekta at ginagamit ang data mo |
| seLogOut | Log out | Mag-log out |
| seLogOutConfirm | Are you sure you want to log out? | Sigurado ka bang gusto mong mag-log out? |
| seCancel | Cancel | Cancel |
| seSignOutSubtitle | Sign out of your account on this device | Mag-sign out sa account mo sa device na ito |
| seCouldNotLaunchUrl | Could not launch URL | Hindi mabuksan ang URL |
| thTitle | Appearance | Appearance |
| thTheme | Theme | Theme |
| thLight | Light | Light |
| thDark | Dark | Dark |
| thSystemDefault | System Default | System Default |
| thLightSubtitle | Always use light mode | Laging gamitin ang light mode |
| thDarkSubtitle | Always use dark mode | Laging gamitin ang dark mode |
| thSystemSubtitle | Follow device settings | Sundin ang settings ng device |
| lgTitle | Language | Language |
| lgSubtitle | Choose the preferred language for your app experience. | Piliin ang preferred language para sa app experience mo. |
| lgCurrent | Current language | Kasalukuyang language |
| lgChanged | Language changed to {language} | Napalitan ang language sa {language} |
| npTitle | Notification Settings | Notification Settings |
| npPush | Push Notifications | Push Notifications |

## Notes
- `seCancel` stays English (user-kept). Interpolated key `lgChanged` got `"@lgChanged": {"placeholders": {"language": {}}}` metadata.
- **Excluded (D3):** notification category display labels in `notification_preferences` (`Bookings`, `Messages`, `Payments`, `Recommendations`, `Promotions`, `System`, `Reviews`, `Earnings`, `Disputes`) — the tuple's first element is the backend/stored pref key (`bookings_enabled`, etc.), so these category names double as storage/match values and are left as-is (consistent with earlier exclusions).
- Language option display names (`English`/`Filipino`, flags `EN`/`FIL`) in `language_settings` are user-facing selectors tied to `FFAppState().locale` codes — left hardcoded (locale-code driven, not translation strings).
- Wiring pattern: `_l10n` State getter (`AppLocalizations.of(context)!`); `_saveLanguage` in `language_settings` calls `_l10n.lgChanged(language)` inside the post-setState SnackBar (user-triggered, context valid).
