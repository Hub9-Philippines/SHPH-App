# Change Proposal: Fix Messages Page, Call History, and Remove Verify Identity Skip Button (`fix-messages-call-history-ui-and-api`)

## Summary
Fix the messages list, chat item details, and call history tab in `shph-app` and `serbisyo-api`. This ensures participant names, avatars, roles, message snippets, unread counters, and call history entries are accurately retrieved and rendered in the UI. Additionally, remove the "Skip for now" header button on the "Verify Your Identity" page to enforce identity verification completion.

## Why
1. **Messages Page (Chat Tab):** Users currently cannot easily identify the service provider or client because participant profile fields (name, avatar, role, last message snippet, unread badge count) are either unmapped, displaying generic fallbacks, or missing from API payload mapping.
2. **Call History Tab:** The call history tab shows an empty state even after users make 1-on-1 audio or video calls, because the call history endpoint (`GET /api/v1/calls/history`) and Flutter call history models/controllers are not fully wired up.
3. **Verify Identity Page:** The "Skip for now" header button permits users to bypass identity verification, which conflicts with platform trust and safety requirements.

## Proposed Changes

### Backend (`serbisyo-api`)
1. **Chat Conversations & DRF Compatibility Enhancement (`src/routes/chat.ts` & `src/routes/compat.ts`):**
   - Ensure `GET /api/v1/chat/conversations` and `/api/chat/` return complete participant profiles (`id`, `name`, `avatar_url`, `role`, `phone_number`), last message snippet, timestamp, and accurate unread count.
2. **Call History Endpoint (`src/routes/calls.ts`):**
   - Add `GET /api/v1/calls/history` to return user's past 1-on-1 call sessions with caller/receiver details, call type, duration, status, and timestamp.

### Mobile App (`shph-app`)
1. **Messages Page & Chat Tab Widgets (`lib/main/messages/` & `lib/pages/chat/`):**
   - Update `MessagesWidget` / `ChatListWidget` to map participant name, avatar URL, provider badge, last message text, and unread badge properly.
2. **Call History Tab Widget (`lib/main/messages/` / Call History Tab):**
   - Wire `GET /api/v1/calls/history` to load and render past audio/video calls with caller/receiver name, avatar, call type icon (audio/video), status pill (accepted/missed/ended), and formatted timestamp.
3. **Verify Identity Header (`lib/pages/kyc/` / `verify_identity_widget.dart`):**
   - Remove the "Skip for now" text button from the header bar.

## Success Criteria
- Chat list in the messages page displays the other participant's correct name, avatar, role, last message text, and unread count.
- Call history tab populates with past call sessions showing participant details, call type, status, and duration.
- "Skip for now" button is completely removed from the header of the "Verify Your Identity" page.
- `flutter analyze` passes with 0 errors.
