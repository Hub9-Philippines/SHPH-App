# in-app-calling Specification

## Purpose

Realtime 1:1 audio/video calling between clients and providers over the SHPH websocket + WebRTC stack, matching the web app's behavior so calls placed from either platform reach the other side.

## Requirements

### Requirement: Outgoing call setup
The system SHALL, when the user taps "Call using app" (after the existing mic/camera permission gate), resolve the direct thread, create the call record via `POST /api/chat/calls/initiate/`, and present an outgoing-call UI with the callee's name/photo while the call is being placed.

#### Scenario: Caller places an audio call from the service page
- **WHEN** the user taps in-app call on the provider profile and grants microphone access
- **THEN** an outgoing-call screen appears showing "Ringing…" with the provider's identity, and a call record is created (201) with the thread id, callee id, and `media_type`

### Requirement: Calls are placed from inside the chat room
Every "Call using the app" action outside a chat room SHALL first navigate to the direct chat room for the resolved thread, then place the call automatically, so the conversation and the call share one context. The call SHALL be placed without waiting for the user to leave the room.

#### Scenario: Caller taps "Call using app" on a booking
- **WHEN** the user taps in-app call on a booking details page and grants microphone access
- **THEN** the app opens the direct chat room for that booking's provider and the call starts automatically, without further user action

#### Scenario: Call action inside a chat room
- **WHEN** the user taps the call control in a chat room's header
- **THEN** the call starts in place; no additional navigation occurs

### Requirement: In-call overlay with minimize to picture-in-picture
The in-call surface SHALL be a global overlay rendered above the router rather than a pushed route, so a call survives navigation. It SHALL offer a minimize control that collapses the call to a picture-in-picture bubble — showing the remote identity and a live duration — which the user can tap to restore the full panel and end from without ending the call. Ending a call, a decline, or a remote hangup SHALL remove the overlay entirely.

#### Scenario: User minimizes to keep chatting
- **WHEN** the user taps minimize on an active call
- **THEN** the full-screen call panel collapses to a picture-in-picture bubble and the underlying screen (e.g. the chat room) becomes interactive again, with the call still connected

#### Scenario: User restores a minimized call
- **WHEN** the user taps the picture-in-picture bubble
- **THEN** the full in-call panel is shown again with live media and controls

#### Scenario: User ends the call while minimized
- **WHEN** the user taps end on the picture-in-picture bubble
- **THEN** the call ends, media is released, and both the bubble and any expanded panel are removed

#### Scenario: A new call is never pre-collapsed
- **WHEN** an incoming call arrives or a new outgoing call is placed while `isMinimized` is set from a previous call
- **THEN** the call is presented expanded

### Requirement: Terminal call outcomes are surfaced
When a call ends without a live connection — declined, no answer, permission denied, or a signaling failure — the overlay SHALL present the reason with a dismiss action, and SHALL return to idle on its own after a grace period so no terminal state is left behind. A failure that occurs while no call is live SHALL be ignored.

#### Scenario: Callee declines an outgoing call
- **WHEN** the callee rejects a call the user placed
- **THEN** the overlay shows the decline reason with a "Done" action, and the overlay disappears back to the chat room once dismissed or after the grace period

#### Scenario: Connection fails mid-setup
- **WHEN** the peer connection or signaling fails before the call is established
- **THEN** the overlay shows the failure reason and auto-dismisses, leaving the controller in `idle` so the next call attempt is not blocked

### Requirement: Call signaling over websocket
The system SHALL maintain a websocket connection to `wss://<api-host>/ws` authenticated via the `shph-auth` subprotocol and exchange call signals (`call_initiate`, `call_accept`, `call_reject`, `call_end`, `webrtc_offer`, `webrtc_answer`, `ice_candidate`) wrapped in `call_signal` envelopes, so the remote party is rung and media can be negotiated.

#### Scenario: Callee is rung while app is open
- **WHEN** a caller sends `call_initiate` for a thread the user participates in
- **THEN** the user's app shows an incoming-call overlay with accept/decline controls without requiring a page refresh

### Requirement: Incoming call handling
The system SHALL show an incoming-call overlay (caller identity, accept/decline) when a `call_initiate` signal arrives, gated by the existing microphone/camera permission sheet before connecting, and SHALL send `call_accept` (after the permission gate + REST accept) or `call_reject` in response.

#### Scenario: Callee accepts an incoming call
- **WHEN** the callee taps accept and grants mic access
- **THEN** the app sends the REST accept and the `call_accept` signal, and both sides progress to the in-call state

#### Scenario: Callee declines
- **WHEN** the callee taps decline
- **THEN** the app persists the rejection via REST, sends `call_reject`, and the caller's UI returns to the previous screen with a "call declined" indication

### Requirement: Media connection and in-call controls
The system SHALL establish a WebRTC peer connection carrying audio (and video for video calls) after offer/answer exchange and SHALL provide mute, speaker toggle (audio calls), camera toggle (video calls), and end-call controls, with a visible duration timer.

#### Scenario: Call connects
- **WHEN** both peers have exchanged offer, answer, and ICE candidates
- **THEN** audio flows between the peers and the in-call UI shows connection state then call duration

#### Scenario: Caller ends the call
- **WHEN** either party taps end
- **THEN** `call_end` is signaled, the REST end is called, media is released, and both sides return to the previous screen; a system message may be posted to the thread (web parity)

### Requirement: Call resilience and cleanup
The system SHALL handle rejection, remote hangup, signaling drop, and permission denial without leaving orphaned call state: media tracks are released, the socket handler is detached, and the UI resets. If the websocket is unavailable when a call is attempted, the system SHALL surface an error and not create a half-open state.

#### Scenario: Websocket unavailable on outgoing call
- **WHEN** the user taps in-app call while the signaling socket cannot connect
- **THEN** the app shows an error (e.g., "Could not place call right now") and no ringing UI appears

#### Scenario: Remote party hangs up mid-call
- **WHEN** `call_end` arrives during an active call
- **THEN** the in-call UI closes, media is released, and the call record is ended via REST
