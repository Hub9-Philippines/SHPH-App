## Purpose

Defines the behavior contract for this repository as the dedicated Serbisyo client app: every account created or signed in here is treated as a client, the navigation surface is exclusively client-facing, provider-only screens are unreachable, and users with provider accounts are directed to the Provider app.

### Requirement: Client-only account creation
The signup flow SHALL offer only client accounts; it MUST NOT present a role selection for "service provider" at signup, onboarding, or profile creation.

#### Scenario: New user signs up
- **WHEN** a new user completes signup through any entry point (email/password, phone/OTP)
- **THEN** the resulting account is registered as a client without any provider role choice being offered

#### Scenario: Profile creation after signup
- **WHEN** a newly signed-up user creates their profile
- **THEN** no provider-specific profile fields (business info, service categories offered) are requested

### Requirement: Fixed client tab set
The main navigation SHALL always display exactly the five client tabs — Home, Explore, Bookings, Messages, Profile — regardless of account flags returned by the backend.

#### Scenario: Client signs in
- **WHEN** an authenticated client reaches the main app shell
- **THEN** the bottom navigation shows only Home, Explore, Bookings, Messages, and Profile

#### Scenario: Backend reports provider flag on a client-app session
- **WHEN** the signed-in user's backend profile contains a provider capability flag
- **THEN** the app shell still renders the client tab set and never switches to provider tabs

### Requirement: Provider-only routes are unreachable
The router SHALL NOT expose routes for provider-only experiences (provider dashboard/jobs/schedule/earnings, service management, availability calendar, provider bids/analytics, provider KYC/eKYC verification, dispatch). Deep links to such paths SHALL resolve to the client home screen rather than an error or a provider screen.

#### Scenario: Deep link to removed provider route
- **WHEN** the app is opened via a deep link to a former provider-only path
- **THEN** the user lands on the client home screen with no crash, blank page, or provider UI

### Requirement: Provider account sign-in guidance
When an account that has provider capabilities signs in to the client app, the app SHALL show an explanatory notice directing the user to the Serbisyo Provider app instead of rendering provider features.

#### Scenario: Existing provider signs in on the client app
- **WHEN** sign-in succeeds for an account whose backend role includes provider capabilities
- **THEN** the app displays a notice explaining that provider tools live in the separate Provider app and does not enter the client booking shell as a provider

#### Scenario: Mixed-capability account chooses to continue as client
- **WHEN** an account with both client and provider capabilities acknowledges the notice
- **THEN** the app proceeds into the standard client experience

### Requirement: Client-shared surfaces remain intact
Client-facing interactions with providers SHALL continue to work unchanged: browsing services, viewing a provider's public profile, the booking funnel, chat/calls with providers, reviews, wallet/payment methods, and the client's on-demand job requests list.

#### Scenario: Client books a service end-to-end
- **WHEN** a client selects a service from Explore and completes the booking funnel
- **THEN** booking creation, payment, tracking, and review flows behave as before the split

#### Scenario: Client opens a provider's public profile
- **WHEN** a client taps a provider from search results or a booking record
- **THEN** the provider's public profile (services, ratings, reviews) renders normally
