# Tasks: Unified Auth Screen Redesign (`unified-auth-flow-redesign`)

## 1. Unified Auth Gateway UI/UX Cleanup (`lib/pages/unified_auth/`)

- [x] 1.1 Remove top back button (`BackButtonWidget`) and progress indicator (`AnimatedProgressStepper`) from `UnifiedAuthWidget` (`lib/pages/unified_auth/unified_auth_widget.dart`).
- [x] 1.2 Align gateway layout matching reference design: render App Logo at top, Google & Apple social buttons, "- OR -" divider, single input field labeled "Email or Mobile Number", and modern "Continue" button.

## 2. Smart Input Discrimination & Routing (`lib/pages/unified_auth/` & `lib/router/`)

- [x] 2.1 Update `UnifiedAuthModel` (`lib/pages/unified_auth/unified_auth_model.dart`) with real-time intent parsing: detect Email (`@`) vs PH Mobile (`09`, `639`, `+639`) and sanitize phone input to `+639...` format.
- [x] 2.2 Wire "Continue" action to check account status: route existing users to login/verify, and route new users to pre-populated Sign-Up pages (`email` or `phoneNumber`).
- [x] 2.3 Ensure all completed authentication flows (Google OAuth, Apple OAuth, Email login/register, Mobile OTP) navigate directly to `Home`.

## 3. Pre-Populated Onboarding Alignment (`lib/pages/signin/`, `lib/pages/signup/`, `lib/pages/phone_verify_user/`)

- [x] 3.1 Update `SigninWidget` and `SignupWidget` to accept pre-populated parameters seamlessly without landing stepper clutter.
- [x] 3.2 Ensure OTP verification screens (`PhoneVerifyUserWidget` and email OTP verification) redirect to `Home` upon successful verification.

## 4. Verification & Testing (`shph-app`)

- [x] 4.1 Run `flutter analyze` in `shph-app` and confirm 0 errors.
- [x] 4.2 Commit and push git changes in `shph-app` repository.
