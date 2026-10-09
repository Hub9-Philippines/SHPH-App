# Proposal

## Why

The current initial sign-in and welcome screens contain confusing UI elements—such as a 2-step progress stepper (`AnimatedProgressStepper`) and a top back button—which dilute the landing gateway experience and create friction for returning and new users. Furthermore, having separate fragmented login and signup routes leads to user confusion when choosing an authentication method.

We are unifying the entry gateway into a single, high-conversion **Unified Auth Screen** (without steppers or back buttons) featuring social authentication (Google & Apple) alongside a smart single input field ("Email or Mobile Number"). The app will dynamically recognize user intent as email vs mobile number, pre-populate parameters for onboarding when new accounts are created, and route straight to Home once authentication or account creation completes.

## What Changes

- **UI/UX Cleanup**: Remove `AnimatedProgressStepper` and top `BackButtonWidget` from the primary Unified Auth entry screen.
- **Unified Auth Gateway Layout**:
  - Top brand logo.
  - Social login section ("Continue with Google", "Continue with Apple").
  - Clean "- OR -" horizontal divider.
  - Smart single input field labeled "Email or Mobile Number".
  - Dynamic "Continue" CTA button (enabled when input matches valid email or PH phone format).
- **Smart Input Discrimination**:
  - Email intent (contains `@` and valid TLD): Navigates to Email auth flow.
  - Mobile intent (starts with `09`, `639`, or `+639`): Sanitizes to `+639...` format and navigates to Mobile OTP auth flow.
- **Unified Auth Account Routing Logic**:
  - **Existing Users**: Directly authenticates and redirects to `Home`.
  - **New Email Users**: Navigates to Email/Password Sign-Up screen with pre-populated email address -> requires first name, last name, and password -> proceeds to Email OTP verification page -> redirects to `Home`.
  - **New Mobile Users**: Navigates to Mobile Sign-Up screen with pre-populated mobile number -> requires first name and last name -> proceeds to Mobile OTP verification page -> redirects to `Home`.
  - **New Social Users (Google / Apple)**: Extracts email address from OAuth payload -> navigates to Complete Profile sub-step for first name and last name -> redirects to `Home`.

## Capabilities

### Modified Capabilities
- `user-auth`: Modify user authentication gateway UI to remove stepper/back-button affordances, introduce single smart input routing for email/phone, pre-populate email/mobile parameters into secondary sign-up/verification screens, and ensure all successful authentication branches redirect directly to `Home`.

## Impact

- **Frontend (`shph-app`)**:
  - `lib/pages/unified_auth/unified_auth_widget.dart` & `unified_auth_model.dart`
  - `lib/pages/signin/signin_widget.dart`
  - `lib/pages/signup/signup_widget.dart`
  - `lib/pages/phone_verify_user/phone_verify_user_widget.dart`
  - `lib/router/app_router.dart`
- **Backend (`serbisyo-api`)**: Existing Cloudflare Worker auth endpoints (`/api/v1/auth/*`) fully support edge staging, OTP verification, and account linking.
