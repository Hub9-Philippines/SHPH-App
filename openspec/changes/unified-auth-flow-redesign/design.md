# Design

## Context

See `proposal.md` for motivation. The Flutter mobile app (`shph-app`) currently has `UnifiedAuthWidget`, `SigninWidget`, and `SignupWidget`. Previous implementations added an `AnimatedProgressStepper` and top back buttons on the landing auth gateway, which created visual confusion. We are redesigning the Unified Auth gateway into a streamlined screen and aligning state transitions.

## Goals / Non-Goals

**Goals:**
- Strip out `AnimatedProgressStepper` and top back buttons from the Unified Auth Screen (`UnifiedAuthWidget`).
- Present a clean, unified authentication gateway layout matching the exact design reference:
  - App Logo at top.
  - Social authentication buttons ("Continue with Google" & "Continue with Apple").
  - "- OR -" divider.
  - Single text field ("Email or Mobile Number").
  - Modern "Continue" CTA button (enabled when input matches valid email or PH phone format).
- Provide real-time intent parsing (Email vs PH Mobile) in `UnifiedAuthModel`.
- Support pre-populated query parameters when transitioning to `SigninWidget`, `SignupWidget`, or `PhoneVerifyUserWidget`.
- Guarantee all successful auth completions redirect straight to `Home`.

**Non-Goals:**
- Modifying backend Cloudflare Worker endpoints in `serbisyo-api` (already live and verified with KV edge staging, OTP verification, and account linking).

## Decisions

### 1. Unified Gateway Layout Cleanup
- **Choice**: Remove `PreferredSize(child: CupertinoPageHeader(leading: BackButtonWidget()))` and `AnimatedProgressStepper` from `UnifiedAuthWidget`.
- **Rationale**: The landing gateway is the initial entry point of the app; it should not display a back button or multi-step progress bar.

### 2. Smart Single Input Field Parsing
- **Choice**: Implement a single `TextFormField` controller in `UnifiedAuthModel` with real-time regex parsing:
  - **Email Parsing**: Matches `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`.
  - **PH Mobile Parsing**: Matches `^(09|\+?639)\d{9}$`. If input starts with `09`, it is sanitized to `+639XXXXXXXXX`.
- **Rationale**: Eliminates separate text boxes and simplifies the initial entry point.

### 3. Account Status Check & Pre-Populated Onboarding Flow
- **Email Intent**:
  - Calls `AuthService.instance.authApi.checkAccount(email)`.
  - **Existing User**: Navigates to `SigninWidget` with pre-populated `email`.
  - **New User**: Navigates to `SignupWidget` with pre-populated `email`. User inputs first name, last name, and password -> proceeds to Email verification page -> redirects to `Home`.
- **Mobile Intent**:
  - Calls `AuthService.instance.authApi.checkAccount(phone)`.
  - **Existing User**: Navigates to `PhoneVerifyUserWidget` for OTP verification.
  - **New User**: Navigates to Mobile Sign-Up screen with pre-populated `phoneNumber` -> user inputs first name and last name -> proceeds to Mobile OTP verification -> redirects to `Home`.
- **Social OAuth (Google / Apple)**:
  - Extracts email from OAuth identity payload.
  - If existing account -> merges/authenticates -> redirects to `Home`.
  - If new user -> completes account sub-step for first name and last name -> redirects to `Home`.

## Risks / Trade-offs

- **[Risk]**: Inputting phone numbers without country code might cause parsing failure.
  - *Mitigation*: Automatically sanitize any number starting with `09` or `639` to standard `+639...` format before dispatching payloads.
