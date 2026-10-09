# Design: Update Sign In and Sign Up Pages Architecture (`update-signin-signup-ux`)

## Context
See [`proposal.md`](file:///C:/Users/Administrator/dev/shph-app/openspec/changes/update-signin-signup-ux/proposal.md) and [`specs/user-auth/spec.md`](file:///C:/Users/Administrator/dev/shph-app/openspec/changes/update-signin-signup-ux/specs/user-auth/spec.md).

Following the implementation of `UnifiedAuthWidget` and Cloudflare Worker KV staging, `SigninWidget` and `SignupWidget` must be updated to align visually and architecturally with the 2-step onboarding flow.

## Goals / Non-Goals

**Goals:**
- Update `SigninWidget` to accept pre-filled `email` query parameters passed from `UnifiedAuthWidget`.
- Include `AnimatedProgressStepper(currentStep: 1, totalSteps: 2)` across both `SigninWidget` and `SignupWidget`.
- Ensure `SignupWidget` triggers edge registration staging and routes directly to `PhoneVerifyUserWidget` (Step 2 Verification Pass).
- Align typography, theme tokens (`AppTheme.of(context)`), and back-navigation buttons across auth screens.

**Non-Goals:**
- Modifying backend Cloudflare Worker endpoints (backend staging is already deployed and verified).

## Decisions

### 1. Pre-Filled Parameter Pass to `SigninWidget`
- **Choice:** Add optional `email` constructor/query parameter to `SigninWidget`:
  ```dart
  final String? email;
  ```
  In `_SigninWidgetState.initState()`, if `widget.email` is non-null and non-empty, populate `_model.emailTextController.text = widget.email!`.
- **Rationale:** Eliminates redundant typing for users entering their email on `UnifiedAuthWidget`.

### 2. Stepper Header Embedding
- **Choice:** Render `AnimatedProgressStepper(currentStep: 1, totalSteps: 2)` directly beneath the app bar on both `SigninWidget` and `SignupWidget`.
- **Rationale:** Visually reinforces the 2-step onboarding pass (`Step 1: Auth Gate`, `Step 2: Verification Pass`).

### 3. Pre-Verification Sign-Up Execution
- **Choice:** `SignupWidget` calls `(authManager as ShphAuthManager).createAccountWithEmail(...)` which invokes `/api/v1/auth/register/initiate`. Upon success, navigates directly to `PhoneVerifyUserWidget`.
- **Rationale:** Ensures zero premature active user row creation in production D1 database.

## Risks / Trade-offs

- **[Risk] Deep link navigation skipping gateway:** Users opening `/signin` directly won't have a pre-filled email.
  - *Mitigation:* `SigninWidget` handles empty email parameter gracefully by focusing the email input field.
