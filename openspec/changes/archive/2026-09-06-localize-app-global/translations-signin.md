# Sign In - Filipino (Taglish) Strings

Screen: `lib/pages/signin/`

Batch status: **approved & wired** (Task 3.6 done, `flutter analyze` = 0 errors)

All strings below are present in both `app_en.arb` and `app_fil.arb` (keys prefixed `si*`) and wired through `AppLocalizations`.

## Header / tabs

| Key | English | Approved Taglish |
|-----|---------|------------------|
| siWelcome | Welcome to Serbisyo | Welcome to Serbisyo (brand, kept as-is) |
| siWelcomeSubtitle | Sign in to continue with your home services. | Mag-sign in para magpatuloy sa iyong home services. |
| siPhone | Phone | Phone (kept) |
| siEmail | Email | Email (kept) |

## Phone tab

| Key | English | Approved Taglish |
|-----|---------|------------------|
| siMobileNumber | Mobile number | Mobile number (kept) |
| siPhoneNumberRequired | Phone Number is required and has to start with +. | Kailangan ang phone number at dapat magsimula sa +. |

## Email tab

| Key | English | Approved Taglish |
|-----|---------|------------------|
| siEmailAddress | Email address | Email address (kept) |
| siInvalidEmail | Invalid email | Invalid na email |
| siPassword | Password | Password (kept) |
| siEnterPassword | Enter your password | I-enter ang password mo |
| siInvalidEmailOrPassword | Invalid email or password | Mali ang email o password |

## Buttons / links / social

| Key | English | Approved Taglish |
|-----|---------|------------------|
| siSignIn | Sign In | Sign In (kept) |
| siSigningIn | Signing In... | Nagse-sign in... |
| siForgotPassword | Forgot password | Nakalimutan ang password? |
| siNoAccountYet | Don't have an account yet? | Wala ka pang account? |
| siSignUp | Sign Up | Sign Up (kept) |
| siOrContinueWith | or continue with | o magpatuloy gamit ang |
| siContinueWithGoogle | Continue with Google | Magpatuloy gamit ang Google |
| siContinueWithApple | Continue with Apple | Magpatuloy gamit ang Apple |
| siGoogleComingSoon | Google sign-in coming soon | Malapit na ang Google sign-in |
| siAppleComingSoon | Apple sign-in coming soon | Malapit na ang Apple sign-in |

## Notes
- **Wiring:** `_l10n` State getter (`AppLocalizations.of(context)!`); the `_OrDivider` stateless widget reads via `AppLocalizations.of(context)` in its own build. `si*` snackbars were de-const'd (l10n values aren't compile-time constants).
- **Exclusions (D3):** `+63` country-code prefix, phone hint `9123456789`, email hint `you@example.com`, and password mask `••••••••` are input format templates and stay as-is. Inline error strings from the async handlers (`ErrorHandler.describeError(e)`) are backend/exception messages, covered by the D2/D3 service layer, not this page.
- Shared phone-tab vs email-tab rows (social buttons, "Sign In", "forgot password", sign-up links) are the same l10n keys in both tabs — no duplicates.
- `flutter analyze` = 0 errors; remaining signin-file lints (unused `base_auth_user_provider` import, `directives_ordering`, `always_put_control_body_on_new_line`, `prefer_expression_function_bodies`, `use_build_context_synchronously`) are pre-existing FlutterFlow baseline and excluded.