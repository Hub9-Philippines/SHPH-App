---
description: Port the WebRTC video call system from the web app to Flutter mobile
---

# Skill: Port Video Calls System (WebRTC)

Port the full video call system — 1-on-1 video/audio calls via WebRTC with signaling through WebSocket — from the web app to the Flutter mobile app.

---

## What the Web App Has

### Frontend (Vue — `shph-app/src/`)

**WebRTC Service** (`services/webrtcService.ts` — 39KB, 1314 lines):
- `WebRTCService` class — singleton managing all call lifecycle
- Call states: idle, ringing, outgoing, connecting, connected, ended
- Signaling via WebSocket messages: `call_initiate`, `call_accept`, `call_reject`, `call_end`, `webrtc_offer`, `webrtc_answer`, `ice_candidate`
- ICE servers: STUN (Google) + optional TURN (configurable via env)
- Perfect negotiation pattern (polite/impolite, makingOffer, ignoreOffer flags)
- Camera switching (front/back: `user`/`environment`)
- Network quality monitoring via `getStats()` (good/fair/poor)
- Callbacks: statusCallback, streamCallback, participantCallback, incomingCallCallback, networkQualityCallback
- Local/remote stream management
- Pending ICE candidates buffer (for candidates arriving before connection)

**WebRTC Store** (`stores/webrtc.ts` — 7.7KB):
- Pinia store: callStatus, localStream, remoteStream, participant, callDuration
- Incoming call handling: auto-show incoming call UI
- Call timer (duration tracking)
- Missed call handling

**Chat Components**:
- `components/chat/IncomingCallNotification.vue` — Incoming call banner with accept/reject
- `components/chat/VideoCallOverlay.vue` — Full-screen video call UI with:
  - Local/remote video views
  - Mute toggle, camera toggle, camera switch
  - End call button
  - Call duration timer
  - Network quality indicator
- `components/chat/OnlineIndicator.vue` — Shows if user is online

**API Integration** (`services/api.ts`):
- `chatApi.initiateCall(threadId, targetUserId)` — Creates call record
- `chatApi.endCall(callId)` — Ends call record
- `chatApi.getCallHistory(threadId)` — Call history

### Backend (Django — `shph-api/src/shph/chat/`)

- `VideoCall` model (MongoDB via Djongo): thread, caller, callee, status (ringing/connected/missed/ended), started_at, ended_at, duration
- WebSocket consumer handles signaling messages
- Call records stored in MongoDB

---

## What the Mobile App Needs

### 1. Flutter Packages

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_webrtc: ^0.10.0  # WebRTC for Flutter
  flutter_ringtone_player: ^4.0.0  # Ringtone for incoming calls
```

### 2. Flutter Service

Create `lib/services/webrtc_service.dart`:

Key components:
- `WebRTCService` class (singleton)
- Signaling via Supabase Realtime (replace WebSocket):
  - Use Supabase Realtime channel for signaling messages
  - Message types: `call_initiate`, `call_accept`, `call_reject`, `call_end`, `webrtc_offer`, `webrtc_answer`, `ice_candidate`
- `RTCPeerConnection` management via `flutter_webrtc`
- Local stream: `MediaStream` from `getUserMedia` (audio + video)
- Remote stream: from `onTrack` callback
- ICE candidate handling: `onIceCandidate` → send via Supabase Realtime
- Camera switching: `helper.switchCamera()`
- Mute/unmute: `MediaStreamTrack.setEnabled()`
- Call states: idle, ringing, outgoing, connecting, connected, ended

**Signaling via Supabase Realtime** (replaces WebSocket):
```dart
// Subscribe to signaling channel
supabase.channel('webrtc_signaling_$threadId')
  .onBroadcast(
    event: 'signal',
    callback: (payload) {
      final signal = payload['signal'];
      switch (signal['type']) {
        case 'call_initiate': _handleIncomingCall(signal);
        case 'call_accept': _handleCallAccepted(signal);
        case 'call_reject': _handleCallRejected(signal);
        case 'call_end': _handleCallEnded(signal);
        case 'webrtc_offer': _handleOffer(signal);
        case 'webrtc_answer': _handleAnswer(signal);
        case 'ice_candidate': _handleIceCandidate(signal);
      }
    },
  )
  .subscribe();

// Send signaling message
void sendSignal(String type, Map<String, dynamic> data) {
  supabase.channel('webrtc_signaling_$threadId').sendBroadcastMessage(
    event: 'signal',
    payload: {'type': type, ...data},
  );
}
```

### 3. Supabase Table

Create `database/create_video_calls_table.sql`:

```sql
CREATE TABLE IF NOT EXISTS video_calls (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
  caller_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  callee_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'ringing', -- ringing, connected, missed, ended
  started_at TIMESTAMPTZ,
  ended_at TIMESTAMPTZ,
  duration_seconds INTEGER,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_videocalls_room ON video_calls(chat_room_id);
CREATE INDEX idx_videocalls_caller ON video_calls(caller_id);
CREATE INDEX idx_videocalls_callee ON video_calls(callee_id);
CREATE INDEX idx_videocalls_status ON video_calls(status);

ALTER TABLE video_calls ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Call participants can view calls" ON video_calls
  FOR SELECT USING (auth.uid() IN (caller_id, callee_id));

CREATE POLICY "Users can create calls" ON video_calls
  FOR INSERT WITH CHECK (auth.uid() = caller_id);

CREATE POLICY "Call participants can update calls" ON video_calls
  FOR UPDATE USING (auth.uid() IN (caller_id, callee_id));
```

### 4. Flutter UI

Components to create:
- `lib/components/chat/incoming_call_notification.dart` — Incoming call banner:
  - Caller name + avatar
  - Accept (green) / Reject (red) buttons
  - Ringtone playback
- `lib/components/chat/video_call_overlay.dart` — Full-screen video call:
  - Remote video (full screen)
  - Local video (picture-in-picture, draggable)
  - Controls bar: mute, camera toggle, camera switch, end call
  - Call duration timer
  - Connecting animation
- `lib/components/chat/call_ended_overlay.dart` — Call summary:
  - Duration
  - "Call ended" message
  - Dismiss button

### 5. Integration with Chat

- Add "Video Call" button in `lib/pages/chat_page/`
- On call initiate: insert `video_calls` record, send `call_initiate` signal
- On call end: update `video_calls` record with ended_at + duration
- Show call records in chat message history (as special message type)

### 6. ICE Server Configuration

Add to environment config:
```
TURN_USERNAME=your_turn_username
TURN_CREDENTIAL=your_turn_password
TURN_SERVER=turn:your-turn-server.com:3478
```

Default ICE servers:
- STUN: `stun:stun.l.google.com:19302`, `stun:stun1.l.google.com:19302`
- TURN: optional, configurable via env

---

## Web Source Files to Reference

| File | Purpose |
|------|---------|
| `shph-app/src/services/webrtcService.ts` | Full WebRTC service (1314 lines, 39KB) |
| `shph-app/src/stores/webrtc.ts` | WebRTC Pinia store (7.7KB) |
| `shph-app/src/components/chat/IncomingCallNotification.vue` | Incoming call UI |
| `shph-app/src/components/chat/VideoCallOverlay.vue` | Video call overlay UI |
| `shph-app/src/components/chat/OnlineIndicator.vue` | Online status indicator |
| `shph-app/src/services/websocketService.ts` | WebSocket signaling (20KB) |
| `shph-app/src/services/api.ts` | chatApi call endpoints |

## Key Differences for Flutter

- Web uses browser's native `RTCPeerConnection`; mobile uses `flutter_webrtc` package
- Web uses WebSocket for signaling; mobile should use Supabase Realtime broadcast
- Web uses `MediaStream` from browser; mobile uses `flutter_webrtc`'s `MediaStream`
- Web uses `getUserMedia()`; mobile uses `flutter_webrtc`'s `createLocalMediaStream()`
- Web stores call records in MongoDB; mobile stores in Supabase Postgres
- Web has perfect negotiation pattern; mobile should implement same (flutter_webrtc supports it)
- Camera switching: web uses `facingMode` constraint; mobile uses `helper.switchCamera()`
- Web uses CSS for video rendering; mobile uses `RTCVideoRenderer` widget
