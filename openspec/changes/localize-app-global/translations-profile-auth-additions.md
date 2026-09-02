# Tasks 3.11 + 3.12 — Final Additions (Approved CSV)

User-approved Taglish values for the keys added during completion. Most of 3.11/3.12 was already wired in prior sessions; only these keys were newly added this session. Both `app_en.arb` and `app_fil.arb` remain at exact key parity.

## Task 3.11 additions (`signup` + `create_profile`)

| Key | English (final) | Filipino/Taglish (final) |
|-----|-----------------|--------------------------|
| suPhoneRequired | Phone Number is required and has to start with +. | Kailangan ang phone number at dapat nagsisimula sa +. |
| crUploadProgress | Uploading {percent}% | Ina-upload {percent}% |
| passwordsDoNotMatch (reused) | Passwords do not match | Hindi tugma ang mga password |

- `passwordsDoNotMatch` was already in the ARB (used by security_settings/signin); reused for the signup "Passwords do not match." inline string instead of duplicating.

## Task 3.12 additions (`my_notifications`)

| Key | English (final) | Filipino/Taglish (final) |
|-----|-----------------|--------------------------|
| mnErrorMarkRead | Could not mark notifications as read. | Hindi ma-mark bilang read ang notifications. |
| mnErrorNoDestination | This notification has no linked destination yet. | Ang notification na ito ay walang naka-link na destination. |

## Verification
- `flutter gen-l10n`: clean (es untranslated expected)
- `flutter analyze`: 0 errors (701 baseline info/warnings noise)