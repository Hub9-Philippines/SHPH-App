# Spec Delta: `user-auth`

## ADDED Requirements

### Requirement: Sign-In Screen Gateway Alignment
The system SHALL align the Sign-In page (`SigninWidget`) with the Unified Auth gateway UI, supporting pre-filled `email` or `phone` parameters passed from `UnifiedAuthWidget`. The Sign-In screen MUST render the `AnimatedProgressStepper(currentStep: 1, totalSteps: 2)` header, allow input of password credentials or single-click toggle to phone OTP login, and provide a clear back-link to the gateway screen.

#### Scenario: Navigating to Sign-In with pre-filled email from gateway
- **WHEN** the user enters an email on `UnifiedAuthWidget` and clicks Continue
- **THEN** `SigninWidget` opens with the email pre-filled in the email field and the password field focused

#### Scenario: Toggling from Sign-In to Phone OTP login
- **WHEN** the user selects the Phone OTP option on `SigninWidget`
- **THEN** the system triggers SMS OTP dispatch to their mobile number and navigates to the OTP verification screen

### Requirement: Sign-Up Screen Edge Staging Alignment
The system SHALL align the Sign-Up page (`SignupWidget`) with the 2-step onboarding workflow, rendering `AnimatedProgressStepper(currentStep: 1, totalSteps: 2)` at the top. The Sign-Up form MUST capture First Name, Last Name, Email, Mobile Number (`+639...` sanitization format), Password, and Confirm Password with client-side validation. Upon form submission, the system MUST call `ShphAuthApi.instance.registerInitiate()` to stage the payload in edge cache without creating an active production user row, and immediately transition the user to `PhoneVerifyUserWidget`.

#### Scenario: Submitting Sign-Up form stages payload and opens OTP screen
- **WHEN** the user fills out valid registration details on `SignupWidget` and clicks Sign Up
- **THEN** the system calls `registerInitiate()`, receives success response, and navigates to `PhoneVerifyUserWidget` for Step 2 verification
