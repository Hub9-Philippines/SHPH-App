# Implementation Tasks: Fix Messages Page, Call History, and Remove Verify Identity Skip Button (`fix-messages-call-history-ui-and-api`)

## 1. Backend Call History Endpoint & Chat Response Enhancements (`serbisyo-api`)
- [x] Add `GET /api/v1/calls/history` in `src/routes/calls.ts` returning formatted call history items with participant profile details.
- [x] Add Block 16 test in `test-bookings-e2e.mjs` verifying call history API.
- [x] Deploy updated backend worker via `npx wrangler deploy`.

## 2. Flutter Calls API Resource (`shph-app`)
- [x] Create `lib/api/resources/calls_api.dart` with `getCallHistory()` method calling `/api/v1/calls/history`.

## 3. Messages Page Chat Tab Fixes (`shph-app`)
- [x] Update chat list item widgets in `lib/main/messages/` to correctly map and render the service provider's / client's name, avatar image, role tag, last message snippet, timestamp, and unread badge.

## 4. Call History Tab Fixes (`shph-app`)
- [x] Wire `ShphCallsApi.instance.getCallHistory()` to load call sessions into the Call History tab list widget.
- [x] Render call type icon (audio/video), participant name & avatar, call status, duration, and timestamp.

## 5. Remove "Skip for now" Button from Verify Identity Header (`shph-app`)
- [x] Locate the "Verify Your Identity" header widget in `lib/pages/` and remove the "Skip for now" text button.

## 6. Analysis & Verification (`shph-app`)
- [x] Run `flutter analyze` and confirm 0 errors.
- [x] Commit and push git changes in both repositories.
