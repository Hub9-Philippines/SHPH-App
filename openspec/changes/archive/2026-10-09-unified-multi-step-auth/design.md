# Design

## Context

The app currently uses direct REST auth API calls without native Google/Apple account picker integration, and lacks dedicated Step 2 onboarding forms for each registration method and dedicated Step 3 Email vs. SMS verification pages.

## Goals / Non-Goals

**Goals:**
- Integrate native Google Sign-In (`google_sign_in`) and Apple Sign-In (`sign_in_with_apple`) modal account prompts without requiring Firebase.
- Provide dedicated Step 2 onboarding screens:
  - `Google/Apple`: Pre-filled Email + First Name + Last Name fields.
  - `Email`: Pre-filled Email + First Name + Last Name + Password fields.
  - `Mobile`: Pre-filled Mobile Number + First Name + Last Name + optional Email + Password fields.
- Provide dedicated Step 3 verification screens:
  - `Email / Google / Apple`: Email OTP Verification screen (`EmailVerifyWidget`).
  - `Mobile`: Mobile SMS OTP Verification screen (`PhoneVerifyUserWidget`).
- Implement `/api/v1/auth/otp/send-email` and `/api/v1/auth/otp/verify-email` in `serbisyo-api`.

**Non-Goals:**
- Adding Firebase Auth SDKs or Firebase Console dependencies.

## Decisions

1. **Native OAuth without Firebase**:
   - Use `google_sign_in` plugin configured with Google Client ID (no `google-services.json` or Firebase project needed for REST backend authentication).
   - Use `sign_in_with_apple` plugin for iOS / Apple Sign-In.
   - Extract email and display name from native credentials, then execute account check (`/api/v1/auth/check-account`).

2. **3-Step Auth Architecture**:
   - **Step 1 Gateway (`UnifiedAuthWidget`)**: Smart Single Input + Google/Apple native buttons.
   - **Step 2 Onboarding (`SignupWidget` with method modes)**:
     - Pre-fills email/phone based on method.
     - Captures `first_name` and `last_name` explicitly on all forms.
   - **Step 3 Verification**:
     - Email-based routes (Google, Apple, Email Sign Up) $\rightarrow$ `EmailVerifyWidget` (Email OTP code via `/api/v1/auth/otp/send-email`).
     - Phone-based routes (Mobile Sign Up) $\rightarrow$ `PhoneVerifyUserWidget` (SMS OTP pin via `/api/v1/auth/otp/send-pin`).

## Risks / Trade-offs

- [Risk] Email OTP delivery requires email sending service on Cloudflare Worker.
  - Mitigation: Configure Cloudflare Worker email sending or Resend/Mailgun API key, with fallback to dev verification code for testing.
