## Why

On the booking details page the Call and Message floating buttons both silently open the legacy contact hub (`ContactProviderWidget`), giving users no direct path to a plain phone call, a text (SMS), or the app's in-app chat room. Tapping Call while the provider's number exists should let the user choose between dialing the number and calling through the app's communication system; tapping Message should offer SMS versus the in-app chat room.

## What Changes

- Booking details Call button opens a chooser with two options: **Call by phone number** (launches the OS dialer with the provider's number) and **Call using the app** (in-app audio call via the app's call/communication system).
- Booking details Message button opens a chooser with two options: **Text via SMS** (launches the OS SMS app with the provider's number) and **Chat in app** (opens the in-app chat room for the provider).
- Booking details gains a way to resolve the provider's phone number and provider id (from the loaded booking listing / provider profile API) so the dialer and SMS options are actionable.
- The direct "call by number" / "text via SMS" actions work without navigating through `ContactProviderWidget`.

## Capabilities

### New Capabilities
- `booking-contact-actions`: How the booking details page presents contact options (call by number vs in-app call, SMS vs in-app chat) and resolves the provider contact details needed to act.

### Modified Capabilities
- `booking-lifecycle-ui`: The booking details page currently routes both Call and Message actions to the legacy contact hub; its REQUIREMENTS change so those actions present the two-option chooser instead.

## Impact

- `lib/pages/booking_details/booking_details_widget.dart` — Call/Message floating buttons and their tap handlers.
- `lib/api/resources/chat_api.dart` / `lib/services/call_service.dart` — in-app call initiation path (already exists, `POST /api/chat/calls/initiate/`).
- `lib/services/chat_service.dart` + `lib/pages/chat_page/chat_page_widget.dart` — in-app chat room entry (already exists).
- `lib/api/resources/providers_api.dart` — provider profile fetch (phone number source).
- New shared contact-actions component (bottom sheet/chooser) under `lib/components/` reusing theme tokens.