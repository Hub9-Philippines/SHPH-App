# Technical Design: Fix Messages Page, Call History, and Remove Verify Identity Skip Button (`fix-messages-call-history-ui-and-api`)

## Context
`shph-app` features a Messages page (`lib/main/messages/`) with two primary tabs: Messages (chat threads) and Call History. Users currently face missing participant details on chat cards and empty call history logs. Additionally, identity verification (`lib/pages/kyc/` or `lib/pages/verify_identity/`) includes a "Skip for now" header text button that needs removal.

## Backend Extensions (`serbisyo-api`)
1. **`GET /api/v1/calls/history` (`src/routes/calls.ts`):**
   - Query `call_sessions` where `caller_id = ? OR receiver_id = ?`, joining `users` to fetch participant name and avatar.
   - Return paginated array of call records:
     ```json
     {
       "id": "call-123",
       "booking_id": "booking-456",
       "participant": {
         "id": "usr-789",
         "name": "Juan Dela Cruz",
         "avatar_url": "https://...",
         "role": "provider"
       },
       "is_caller": true,
       "call_type": "video",
       "status": "accepted",
       "duration_seconds": 180,
       "created_at": "2026-10-08T18:00:00Z"
     }
     ```
2. **Chat Conversations (`src/routes/chat.ts`):**
   - Ensure `participant` object includes `id`, `name`, `avatar_url`, `role`, `phone_number`.

## Mobile App Implementation (`shph-app`)
1. **API Client Resource Addition (`lib/api/resources/calls_api.dart`):**
   - Add `ShphCallsApi` with `getCallHistory()`.
2. **Messages Screen (`lib/main/messages/`):**
   - **Messages Tab:** Update `ConversationCard` widget to render participant `name`, `avatar_url` (with fallback initial avatar), `role` badge ("Service Provider" / "Client"), `last_message_text`, `sent_at`, and `unread_count` badge.
   - **Call History Tab:** Update `CallHistoryList` widget to fetch and display call sessions from `ShphCallsApi.instance.getCallHistory()`.
3. **Verify Identity Header (`lib/pages/`):**
   - Locate header text button "Skip for now" in the identity verification widget/page and remove it.
