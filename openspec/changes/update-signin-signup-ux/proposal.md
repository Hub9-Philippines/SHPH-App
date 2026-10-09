# Proposal: Update Sign In and Sign Up Pages (`update-signin-signup-ux`)

## Why
With the introduction of the Unified Auth Screen (`UnifiedAuthWidget`), edge registration staging, and 2-step lazy onboarding, the traditional Sign In (`SigninWidget`) and Sign Up (`SignupWidget`) pages need to be aligned with this unified visual language, state architecture, and pre-verification staging workflow.

Updating the Sign In and Sign Up screens ensures visual consistency, seamless pre-filling of email/phone parameters passed from the gateway, integration of the `AnimatedProgressStepper`, and explicit support for lazy onboarding transitions.

## What Changes
- **Sign In Screen Alignment (`SigninWidget`):**
  - Support pre-filled `email` or `phone` query parameters passed from `UnifiedAuthWidget`.
  - Add `AnimatedProgressStepper` step-indicator and align visual styling (logo, social buttons, theme tokens) with `UnifiedAuthWidget`.
  - Provide direct options to toggle between password login and OTP login without UI fragmenting.
- **Sign Up Screen Alignment (`SignupWidget`):**
  - Integrate `AnimatedProgressStepper(currentStep: 1, totalSteps: 2)` to visually communicate the 2-step onboarding pass.
  - Apply phone number sanitization (`09...` → `+639...`) and real-time client-side validation before triggering edge registration staging.
  - Transition immediately to `PhoneVerifyUserWidget` upon initial form submission without inserting premature active records into the production database.
- **Navigation & Gateway Linking:**
  - Update route transitions in `AppRouter` and back-button actions to seamlessly return users to `UnifiedAuthWidget`.

## Capabilities

### Modified Capabilities
- `user-auth`: Aligns Sign In and Sign Up presentation layers with Unified Auth, pre-filled parameters, `AnimatedProgressStepper`, and edge staging verification transitions.

## Impact
- **Mobile Client (`shph-app`):** `SigninWidget`, `SigninModel`, `SignupWidget`, `SignupModel`, and `AppRouter`.
