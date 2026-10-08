# Proposal: Unified Auth & Lazy Onboarding Flow (`unified-auth-and-lazy-onboarding`)

## Why
Currently, account creation occurs immediately when a user submits initial registration details, causing premature database insertion of active user rows prior to SMS verification. Furthermore, users lack a single intelligent gateway screen for both Email and PH Phone login, and duplicate user profiles can be created when signing in with Google/Apple using an email address that already exists in the system.

Introducing a Unified Auth Screen (Gateway Screen) with real-time input parsing, a two-step lazy onboarding experience, Cloudflare Worker KV edge staging, and backend account linking will resolve premature account creation, prevent duplicate user accounts, and maximize onboarding conversion.

## What Changes
- **Unified Auth Screen (Flutter):** Implement a single gateway auth screen featuring brand logo placeholder, Google & Apple sign-in buttons, "- OR -" divider, and an intelligent "Email or Mobile Number" single input field.
- **Client-Side Real-Time Parsing (Flutter):** Dynamically detect input mode as the user types: `@` + domain toggles `AuthMode.email` (proceeds to password screen), while valid PH phone formats (`09...`, `639...`, `+639...`) toggle `AuthMode.phone` with auto-sanitization to `+639...` before triggering SMS OTP.
- **Lazy Onboarding Flow (Flutter):** Implement a 2-step onboarding layout (`Step 1: Authentication Gate`, `Step 2: The Verification Pass`). Phone/Email logins transition directly to SMS OTP verification. Google/Apple logins missing a verified phone number transition to a clean mobile prompt followed immediately by SMS OTP. No unnecessary middle names, addresses, or billing files are required.
- **Cloudflare Worker Edge Staging (`serbisyo-api`):** Store initial registration payloads in Cloudflare KV (300-second TTL) or edge staging keyed by phone number/UUID without writing active rows into the production database until OTP verification succeeds.
- **Backend OTP Verification (`serbisyo-api`):** Implement `/api/v1/auth/verify-otp` to validate matching OTPs, extract edge-staged registration data, insert the user into the production database, and clear the KV cache.
- **OAuth Account Linking Middleware (`serbisyo-api`):** Intercept Google/Apple sign-in requests, check if the OAuth email matches an existing account, merge the OAuth identity into the existing user row if found, or provision a fresh user profile if new.

## Capabilities

### Modified Capabilities
- `user-auth`: Adds Unified Auth Screen parsing, Lazy Onboarding workflow, Edge Staging in KV, and OAuth Account Linking.

## Impact
- **Mobile Client (`shph-app`):** New `UnifiedAuthWidget`, `AnimatedProgressStepper`, updated `SigninWidget`, `SignupWidget`, `ShphAuthApi`, and auth state management.
- **Backend API (`serbisyo-api`):** Refactored `/api/v1/auth/register/initiate`, `/api/v1/auth/verify-otp`, Google/Apple OAuth account linking middleware in `src/routes/auth.ts`, and KV binding usage.
