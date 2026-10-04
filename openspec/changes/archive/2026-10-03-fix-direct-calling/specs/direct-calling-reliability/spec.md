## Purpose

Makes 1:1 audio/video calling dependable on mobile by closing the gap between the ported WebRTC engine and the surfaces that trigger it: media is acquired through a permission gate before any call starts, unanswered calls end on both sides, failures are visible instead of silent, the realtime socket survives backgrounding, and audio routes to the speaker as the UI claims.

## ADDED Requirements

### Requirement: Every outgoing call passes the media permission gate
Each in-app call entry point (chat room, product page, booking details, contact provider) SHALL route through the media permission sheet before the call service starts, and the sheet SHALL pre-acquire the local media stream and hand it to the call. A video call SHALL NOT start unless a video track was actually acquired; a videoless acquisition SHALL be treated as denied and re-prompt, not silently downgraded to audio.

#### Scenario: First call requests OS permissions
- **WHEN** the user starts or accepts a call without prior mic/camera permission
- **THEN** the permission sheet requests the OS permissions and only proceeds to the call flow after both the OS grant and a successful media acquisition

#### Scenario: Video call without camera
- **WHEN** a video call is requested but the camera cannot be acquired (permission denied or device busy)
- **THEN** the call does not start and the user sees an explicit camera-required message instead of a video call with an empty local tile

### Requirement: Unanswered calls end on a bounded timer
The caller's call SHALL end with a no-answer outcome if the callee does not accept within 45 seconds, and an incoming call SHALL auto-decline after 45 seconds if the user does not respond. Both timeouts SHALL clean up via the existing REST + signaling paths (end/reject) and reset the session so the next call works immediately.

#### Scenario: Callee never accepts
- **WHEN** the caller waits past 45 seconds in the outgoing/connecting state with no accept signal
- **THEN** the caller's UI shows a no-answer outcome, the call record is ended via REST, a `call_end` signal is sent, and the session resets

#### Scenario: Callee ignores the ring
- **WHEN** the incoming-call banner is shown for 45 seconds without user action
- **THEN** the banner dismisses itself, the call is rejected via REST and `call_reject` signal, and the session resets

### Requirement: Media and connection failures surface honestly
When local media acquisition fails on the accept path, or the peer connection fails, the call UI SHALL show an explicit failed state with a localized message and SHALL reset the session so the user can retry — it SHALL NOT remain in an indefinite connecting spinner.

#### Scenario: Accept with revoked media permission
- **WHEN** the user accepts an incoming call but media acquisition fails
- **THEN** the accept is aborted, the call is rejected via REST, the UI shows a failure message, and the session resets

#### Scenario: Peer connection fails mid-call
- **WHEN** the WebRTC connection enters a failed state during a call
- **THEN** the UI reports the call as failed rather than showing an endless reconnect spinner, and the session resets for a fresh call

### Requirement: Realtime socket recovers on app resume
When the app returns to the foreground, the websocket client SHALL verify the connection is live and reconnect immediately when it is stale or closed, so incoming call signals are not missed after backgrounding. While connected and in the foreground, the existing heartbeat keeps the socket alive.

#### Scenario: Return to foreground with a dead socket
- **WHEN** the app resumes and the underlying socket has been closed or has exceeded the silence window
- **THEN** the client reconnects immediately instead of waiting for the next heartbeat-triggered reconnect

#### Scenario: Return to foreground with a healthy socket
- **WHEN** the app resumes while the socket is still connected and responding
- **THEN** no reconnect churn occurs and the existing connection is reused

### Requirement: Audio routes to the speaker as the UI indicates
When a video call connects, the app SHALL route audio to the loudspeaker by default; toggling the speaker control SHALL apply the change to the device audio stack, and the UI state SHALL reflect the actual routing.

#### Scenario: Video call connects
- **WHEN** a video call reaches the connected state
- **THEN** audio plays through the loudspeaker without the user having to toggle anything

#### Scenario: Speaker toggle during a call
- **WHEN** the user taps the speaker control
- **THEN** the requested routing is applied to the device and the control reflects the resulting state
