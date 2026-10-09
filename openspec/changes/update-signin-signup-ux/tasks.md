# Tasks: Update Sign In and Sign Up Pages (`update-signin-signup-ux`)

## 1. Sign In Screen Alignment (`lib/pages/signin/`)

- [x] 1.1 Update `SigninWidget` and `SigninModel` (`lib/pages/signin/signin_widget.dart` and `signin_model.dart`) to accept optional pre-filled `email` parameter passed from `UnifiedAuthWidget`.
- [x] 1.2 Embed `AnimatedProgressStepper(currentStep: 1, totalSteps: 2)` at the top of `SigninWidget` and align styling (brand logo, social buttons, theme tokens) with `UnifiedAuthWidget`.
- [x] 1.3 Add quick-toggle action for Phone OTP login and clear back-button navigation returning to `UnifiedAuthWidget`.

## 2. Sign Up Screen Alignment (`lib/pages/signup/`)

- [x] 2.1 Embed `AnimatedProgressStepper(currentStep: 1, totalSteps: 2)` at the top of `SignupWidget` (`lib/pages/signup/signup_widget.dart`) and align header presentation.
- [x] 2.2 Enforce real-time PH phone number sanitization (`09...` → `+639...`) and client-side validation in `SignupModel` before calling `createAccountWithEmail()`.
- [x] 2.3 Wire Sign-Up submit action to initiate edge registration staging without creating premature database rows and navigate directly to `PhoneVerifyUserWidget` (Step 2 Verification Pass).

## 3. Router & Navigation Integration (`shph-app`)

- [x] 3.1 Update `AppRouter` (`lib/router/app_router.dart`) to pass `email` query parameter to `SigninWidget` and ensure smooth back-link navigation to `/unifiedAuth`.

## 4. Analysis & Verification (`shph-app`)

- [x] 4.1 Run `flutter analyze` in `shph-app` and confirm 0 errors.
- [x] 4.2 Commit and push git changes in `shph-app` repository.
