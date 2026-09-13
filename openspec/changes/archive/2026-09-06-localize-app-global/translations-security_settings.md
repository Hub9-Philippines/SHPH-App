# Security Settings - Filipino (Taglish) Strings

Screen: `lib/pages/security_settings/`

Batch status: **approved & wired** (Task 3.5 done, `flutter analyze` = 0 errors)

All strings below are present in both `app_en.arb` and `app_fil.arb` (keys prefixed `ss*`) and wired through `AppLocalizations`. `{e}` / `{count}` / `{time}` marks an interpolated placeholder.

## Header / hero

| Key | English | Approved Taglish |
|-----|---------|------------------|
| ssSecurity | Security | Security |
| ssSubtitle | Protect your account, password, and sign-in access. | Protektahan ang account mo, password, at sign-in access. |
| ssHeroTitle | Keep your account protected | Panatilihing protektado ang account mo |
| ssHeroSubtitle | Manage password strength, 2FA, and recent account access in one place. | Pamahalaan ang password strength, 2FA, at mga bagong account access sa isang lugar. |

## Password section

| Key | English | Approved Taglish |
|-----|---------|------------------|
| ssPassword | Password | Password |
| ssCurrentPassword | Current password | Kasalukuyang password |
| ssEnterCurrentPassword | Enter current password | Ilagay ang kasalukuyang password |
| ssCurrentPasswordRequired | Current password is required | Kailangan ang kasalukuyang password |
| ssNewPassword | New password | Bagong password |
| ssEnterNewPassword | Enter new password | Ilagay ang bagong password |
| ssNewPasswordRequired | New password is required | Kailangan ang bagong password |
| ssPasswordMinLength | Password must be at least 8 characters | Dapat hindi bababa sa 8 characters ang password |
| ssConfirmNewPassword | Confirm new password | Kumpirmahin ang bagong password |
| ssReenterNewPassword | Re-enter your new password | Ilagay muli ang bagong password mo |
| ssConfirmPasswordRequired | Please confirm your password | Pakikumpirma ang password mo |
| ssPasswordsDoNotMatch | Passwords do not match | Hindi magkatugma ang passwords |
| ssChangePassword | Change Password | I-change ang Password |
| ssPasswordResetSent | Password reset link sent to your email. Use it to set a new password. | Naipadala sa email mo ang password reset link. Gamitin ito para mag-set ng bagong password. |
| ssErrorPasswordReset | Error changing password: {e} | Error sa pag-change ng password: {e} |

## 2FA section

| Key | English | Approved Taglish |
|-----|---------|------------------|
| ssTwoFactorAuth | Two-Factor Authentication | Two-Factor Authentication |
| ssSecureYourLogin | Secure your login | I-secure ang login mo |
| ssAuthenticatorApp | Use an authenticator app to add a second step during sign in. | Gumamit ng authenticator app para magdagdag ng pangalawang hakbang sa pag-sign in. |
| ss2FAEnrollmentUnavailable | 2FA enrollment is not available yet. | Wala pa ring available na 2FA enrollment. |
| ss2FAManagementUnavailable | 2FA management is not available yet. | Wala pa ring available na 2FA management. |
| ssErrorEnrolling2FA | Error enrolling 2FA: {e} | Error sa pag-enroll ng 2FA: {e} |
| ssErrorDisabling2FA | Error disabling 2FA: {e} | Error sa pag-disable ng 2FA: {e} |

## Login Activity + sessions

| Key | English | Approved Taglish |
|-----|---------|------------------|
| ssLoginActivity | Login Activity | Login Activity |
| ssNoActiveSessions | No active sessions were returned for this account yet. | Wala pang naibalik na active sessions para sa account na ito. |
| ssCurrentDevice | Current device | Kasalukuyang device |
| ssOtherSignIn | Other sign-in | Ibang sign-in |
| ssActiveNow | Active now | Aktibo ngayon |
| ssUnknownDevice | Unknown device | Hindi kilalang device |
| ssLastActive | Last active {time} | Huling aktibo {time} |

## Relative time (`_formatDate`)

| Key | English | Approved Taglish |
|-----|---------|------------------|
| ssJustNow | Just now | Ngayon lang |
| ssMinutesAgo | {count} minutes ago | {count} minuto ang nakalipas |
| ssHoursAgo | {count} hours ago | {count} oras ang nakalipas |
| ssYesterday | Yesterday | Kahapon |
| ssDaysAgo | {count} days ago | {count} araw ang nakalipas |

## Notes
- **Exclusions (D3):** Logging-only messages in `LoggingService.error(...)` calls (`Error changing password`, `Error loading sessions`, `Error enrolling MFA`, `Error disabling MFA`) and the internal exception `Unable to determine account email` (surfaced only inside the localized error snackbar via `{e}`) stay English. The `d/m/yyyy` date format template in `_formatDate` stays as-is.
- Session device/provider names are backend data (untranslated); the `'Unknown device'` fallback is localized.
- `AppLocalizations.of(context)` stays safe here: all snackbars and validators run after the async awaits / during form validation, never in the synchronous `initState` portion.