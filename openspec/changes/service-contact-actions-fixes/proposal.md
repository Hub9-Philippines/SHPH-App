## Why

On the service (product) page the Contact button silently jumps to the legacy contact hub instead of offering direct choices, and the large button labels cause the last character of "Contact"/"Book now" to clip at the bottom edge, degrading the UI. The in-app call permission sheet reports "Access granted" without ever requesting the OS permission, and choosing "Chat in app" from the messaging chooser fails ("Could not open chat right now") because the shared direct-thread helper calls the wrong endpoint.

## What Changes

- The service page Contact button (both the provider card outlined button and the bottom bar) opens a chooser instead of navigating directly to the legacy contact hub. The chooser always shows **Chat in app** and **Call using the app**; when the provider's phone number is resolvable it additionally shows **Text via SMS** and **Call by number**.
- The service page Contact and Book now button labels are shrunk so they fit on a single line without their last character clipping below the button edge.
- The "allow microphone/camera" bottom sheet actually requests the OS permission (microphone for audio calls; microphone + camera for video calls) and only reports "Access granted" when the OS grants it; a permanent denial offers a path to open app settings instead of faking success.
- The shared direct chat-thread resolver (`ChatService.getOrCreateDirectThread`) is switched to the correct `POST /api/chat/threads/direct/` endpoint (with `provider_id`) instead of posting to the booking endpoint with an empty booking id, so "Chat in app" actually opens a room from the service page, booking details, and the legacy contact hub alike.

## Capabilities

### New Capabilities
- `service-contact-actions`: How the service page presents provider contact options (chat vs call, plus SMS/call-by-number when a phone number is available) and how the Contact / Book now button labels are sized.
- `call-permission-request`: How the in-app call permission sheet requests the real OS microphone/camera permissions and reflects the true grant/deny result.
- `chat-direct-thread`: How the app gets or creates a direct chat thread with a provider so "chat in app" opens a real room.

### Modified Capabilities
<!-- No existing main-spec requirements change; the booking-contact-actions delta is unchanged. -->

## Impact

- `lib/pages/product_page/product_page_widget.dart` — Contact handler (`_openContactProvider`) and bottom-bar / provider-card button styling.
- `lib/components/contact_action_sheet.dart` — extend the reusable chooser to a combined mode showing all applicable options (chat, call, SMS, call-by-number) used by the service page.
- `lib/components/call_accept_permission_sheet.dart` — real `permission_handler` microphone/camera requests with accurate grant/deny states.
- `lib/services/chat_service.dart` + `lib/api/resources/chat_api.dart` — direct-thread get-or-create via `POST /api/chat/threads/direct/`.
- `lib/l10n/app_*.arb` — any new strings (e.g., open-settings action, combined sheet title).
- Reuses existing patterns from the booking-details contact chooser; `permission_handler` already a dependency.