# Proposal

## Why

The current sign-in and sign-up flow is fragmented and does not provide native Google or Apple account selection modal prompts. Furthermore, users require a structured, dedicated 3-step authentication and registration pipeline where each sign-up method (Google/Apple, Email, and Mobile) pre-populates credential data on a dedicated Step 2 onboarding form, followed by a dedicated Step 3 verification phase (Email Verification Code vs. SMS OTP).

## What Changes

- **Native Social Auth**: Trigger native Google Sign-In account selection and Apple Sign-In prompts to retrieve email and name credentials.
- **Unified Step 1 Entry**: Render single gateway screen with Logo, Google & Apple buttons, `- OR -` divider, and single smart input (Email or Mobile).
- **Dedicated Step 2 Registration Forms**:
  - **Google / Apple Sign Up**: Dedicated onboarding page with pre-populated Email, plus `First Name` and `Last Name` fields.
  - **Email Sign Up**: Dedicated onboarding page with pre-populated Email, `First Name`, `Last Name`, and `Password` fields.
  - **Mobile Sign Up**: Dedicated onboarding page with pre-populated Mobile Number, `First Name`, `Last Name`, optional `Email`, and `Password` fields.
- **Dedicated Step 3 Verification**:
  - **Email / Google / Apple**: Dispatch 6-digit email verification code to user's email address and prompt verification on `EmailVerifyWidget`.
  - **Mobile**: Dispatch SMS OTP to mobile number and prompt verification on `PhoneVerifyUserWidget`.

## Capabilities

### Modified Capabilities
- `user-auth`: Updating user authentication, social login handling, multi-step registration forms, and 3rd-step email/SMS verification requirements.

## Impact

- `shph-app`: `UnifiedAuthWidget`, `SigninWidget`, `SignupWidget`, `EmailVerifyWidget`, `PhoneVerifyUserWidget`, `ShphAuthManager`, `google_sign_in`, `sign_in_with_apple`.
- `serbisyo-api`: `/api/v1/auth/google`, `/api/v1/auth/apple`, `/api/v1/auth/otp/send-email`, `/api/v1/auth/otp/verify-email`.
