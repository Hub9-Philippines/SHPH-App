## Purpose

Defines the mobile chat room (thread detail) parity contract with the Vue 3 + Ionic web reference: the room exposes the same everyday affordances — header actions (search, audio/video call, overflow menu), a composer with attach/emoji/send, quick replies, and message-list chrome — using the SHPH chat endpoints. Voice notes and live presence are excluded: mobile has no WebSocket chat transport, so real-time online status and audio recording are follow-ups.

## ADDED Requirements

### Requirement: Chat room header actions match web
The chat room header SHALL show, besides the back button, the other participant's avatar and name, and SHALL offer end-aligned actions mirroring the web room: in-thread message search, audio call, video call, and an overflow menu. Direct threads SHALL show the call buttons; the overflow menu SHALL offer view-booking (when the thread carries a booking) and block-user actions. (An online/offline indicator is deferred until the mobile app has a WebSocket chat transport with presence events; the header subtitle SHALL instead show the thread's connected/service context.)

#### Scenario: Header shows participant identity
- **WHEN** the chat room opens on a direct thread
- **THEN** the header shows the other participant's avatar, display name, and a thread-context subtitle

#### Scenario: Audio or video call started from the room
- **WHEN** the user taps the audio or video call button
- **THEN** the app starts the corresponding call with the thread participant using the existing in-app call flow, disabled while a call is already active

#### Scenario: Overflow menu actions
- **WHEN** the user opens the overflow menu
- **THEN** search, view-booking (only when a booking context exists), and block-user actions are available, and each navigates or performs its action

### Requirement: Composer matches web affordances
The chat room composer SHALL provide, in one rounded surface: an attach button that lets the user pick an image and send it as an attachment message, the text input, and an emoji/sticker button opening a picker; a round send button SHALL sit outside the pill and become active only when there is content to send. (Voice notes are deferred — no mobile recording/streaming plumbing; they are a follow-up, not a degraded state.)

#### Scenario: Attach an image
- **WHEN** the user taps attach and selects an image
- **THEN** the image is sent into the thread and appears as an image message bubble

#### Scenario: Emoji or sticker picked
- **WHEN** the user opens the emoji/sticker picker and selects one
- **THEN** the selection is sent into the thread without typing text manually

#### Scenario: Send button state
- **WHEN** the text field is empty and no attachment is pending
- **THEN** the send action is inert; once there is content, tapping send delivers the message and clears the composer

### Requirement: Message list presents web-style chrome
The chat room message list SHALL group messages by day with date separators, show the sender avatar on incoming messages, distinguish incoming and outgoing bubble styling, and render system messages (including call-start notices) as centered non-bubble rows.

#### Scenario: Messages span multiple days
- **WHEN** the thread contains messages from more than one day
- **THEN** a date separator renders between each day's message groups

#### Scenario: Incoming message shows sender
- **WHEN** an incoming message renders
- **THEN** the other participant's avatar is shown alongside the bubble

### Requirement: Quick replies offered when thread is quiet
The chat room SHALL offer the same quick-reply chips as the web room above the composer when there are no messages yet, and tapping one sends that text immediately.

#### Scenario: Empty thread shows quick replies
- **WHEN** the thread has no messages
- **THEN** quick-reply chips appear above the composer and send their text on tap
