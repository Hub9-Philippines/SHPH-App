# Spec Delta

## ADDED Requirements

### Requirement: Unified Auth Gateway layout without Stepper or Back Button
The Unified Auth Screen SHALL serve as the primary landing gateway without rendering a progress stepper or top back button. It SHALL render an App Logo placeholder at the top, dual social authentication buttons ("Continue with Google" and "Continue with Apple"), a "- OR -" horizontal divider, a single input field labeled "Email or Mobile Number", and a "Continue" action button that remains disabled until valid Email or PH Mobile input format is entered.

#### Scenario: Unified Auth gateway layout rendering
- **WHEN** an unauthenticated user opens the application landing gateway
- **THEN** the screen renders the brand logo, Google and Apple social buttons, "- OR -" divider, single "Email or Mobile Number" text field, and "Continue" button, with no top back button and no step progress indicator

### Requirement: Smart Input Discrimination and Pre-Populated Onboarding
The Unified Auth Screen SHALL perform client-side regex parsing on the single input field to discriminate input type in real time. Entering a valid email string containing '@' and a domain SHALL set email mode, taking existing users to password sign-in or taking new users to Email Sign-Up with the email address pre-populated. Entering a PH mobile number starting with '09', '639', or '+639' SHALL sanitize the input to '+639...' format, taking existing users to Mobile OTP login or taking new users to Mobile Sign-Up with the mobile number pre-populated.

#### Scenario: User enters email address on Unified Auth Screen
- **WHEN** a user enters a valid email address and clicks "Continue"
- **THEN** the app transitions to the email authentication path, pre-populating the email field on the Sign-Up screen if the user is not yet registered

#### Scenario: User enters PH mobile number on Unified Auth Screen
- **WHEN** a user enters '09171234567' and clicks "Continue"
- **THEN** the app sanitizes the input to '+639171234567' and transitions to the mobile OTP path, pre-populating the mobile number field on the Mobile Sign-Up screen if the user is not yet registered

### Requirement: Unified Post-Authentication Home Redirection
All successful authentication flows—including Google OAuth, Apple OAuth, Email/Password login, Email Sign-Up with OTP verification, and Mobile OTP sign-in/registration—SHALL immediately log the user into the primary application state and navigate directly to the `Home` page upon completion.

#### Scenario: Existing or newly verified user completes authentication
- **WHEN** a user completes authentication or finishes required profile setup via any supported auth method (Google, Apple, Email, or Mobile)
- **THEN** the app navigates directly to `Home`
