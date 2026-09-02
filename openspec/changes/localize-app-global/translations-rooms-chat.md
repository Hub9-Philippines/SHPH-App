# Task 3.14 — `room_create` + `room_detail` + `room_join` + `room_list` + `chat_page` Localization (Final CSV)

User-approved Taglish values. Keys appended to both `app_en.arb` and `app_fil.arb` after `plNoLocation` (last keys: `ckSent`).

## `room_create` — `rc*`

| Key | English (final) | Filipino/Taglish (final) |
|-----|-----------------|--------------------------|
| rcTitle | Create Room | Gumawa ng Room |
| rcLabelTitle | Title | Title |
| rcLabelDescription | Description | Description |
| rcLabelMenuService | Menu / Service | Menu / Service |
| rcLabelEventDate | Event Date | Event Date |
| rcLabelEventTime | Event Time | Event Time |
| rcTapToSelect | Tap to select | I-tap para pumili |
| rcLabelLocation | Location | Location |
| rcHeadsRequired | Heads Required | Kailangang Heads |
| rcPricePerHead | Price per Head | Presyo per Head |
| rcFailedCreate | Failed to create room | Hindi na-create ang room |

The `Create Room` submit button reuses `rcTitle`.

## `room_detail` — `rd*`

| Key | English (final) | Filipino/Taglish (final) |
|-----|-----------------|--------------------------|
| rdTitle | Room Details | Room Details |
| rdRoomNotFound | Room not found | Hindi nahanap ang room |
| rdParticipants | Participants | Mga Kasali |
| rdJoinCodeCopied | Join code copied | Na-copy ang join code |
| rdShareJoinCode | Share Join Code | I-share ang Join Code |
| rdRoomLocked | Room locked | Naka-lock ang room |
| rdFailed | Failed | Nabigo |
| rdLockRoom | Lock Room | I-lock ang Room |
| rdCancelRoom | Cancel Room | I-cancel ang Room |
| rdLeaveRoom | Leave Room | Umalis sa Room |
| rdJoined | {count}/{head} joined | {count}/{head} ang nakasali |

## `room_list` — `rl*` (incl. shared status labels)

| Key | English (final) | Filipino/Taglish (final) |
|-----|-----------------|--------------------------|
| rlRooms | Rooms | Rooms |
| rlNoRoomsYet | No rooms yet | Wala pang rooms |
| rlCreateRoom | Create Room | Gumawa ng Room |
| rlSeats | {seats}/{heads} seats | {seats}/{heads} seats |
| rlStatusOpen | Open | Open |
| rlStatusLocked | Locked | Naka-lock |
| rlStatusSettled | Settled | Settled |
| rlStatusCancelled | Cancelled | Cancelled |
| rlStatusExpired | Expired | Expired |

The `rlStatus*` keys are reused by `room_detail`'s `_statusLabel` too.

## `room_join` — `rj*`

| Key | English (final) | Filipino/Taglish (final) |
|-----|-----------------|--------------------------|
| rjTitle | Join Room | Sumali sa Room |
| rjEnterJoinCode | Enter Join Code | I-enter ang Join Code |
| rjJoinCodePlaceholder | Join code | Join code |
| rjLookUp | Look Up | I-search |
| rjRoomNotFound | Room not found or link expired. | Hindi nahanap ang room o expired na ang link. |
| rjSeats | Seats: {seats}/{heads} | Seats: {seats}/{heads} |
| rjFailedJoin | Failed to join room | Hindi nakasali sa room |
| rjJoinRoom | Join Room | Sumali sa Room |
| rjCannotJoin | Cannot Join | Hindi Makasali |

## `chat_page` — `ck*`

| Key | English (final) | Filipino/Taglish (final) |
|-----|-----------------|--------------------------|
| ckConversation | Conversation | Conversation |
| ckStartConversation | Start the conversation | Simulan ang conversation |
| ckConnected | Connected to this thread | Konektado sa thread na ito |
| ckChat | Chat | Chat |
| ckNoMessages | No messages yet | Wala pang messages |
| ckEmptySubtitle | Send the first message to coordinate service details, arrival timing, or updates. | Magpadala ng unang message para mag-coordinate sa service details, timing, o updates. |
| ckContact | Contact | I-contact |
| ckWriteMessage | Write a message... | Mag-type ng message... |
| ckSending | Sending... | Ipinapadala... |
| ckFailed | Failed | Failed |
| ckSent | Sent | Naisend |

## Notes
- Widgets wired: `room_create_widget.dart`, `room_detail_widget.dart`, `room_list_widget.dart`, `room_join_widget.dart`, `chat_page_widget.dart`.
- D2: `RoomJoinModel.lookup()` now takes an `AppLocalizations` parameter so the "room not found" error (`rjRoomNotFound`) is set locally; call sites updated. The initState call to `lookup()` was moved into `WidgetsBinding.instance.addPostFrameCallback` to avoid the `AppLocalizations.of(context)` initState trap.
- Placeholder methods used: `rdJoined(count, head)`, `rlSeats(seats, heads)`, `rjSeats(seats, heads)`.
- Status labels (`rlStatus*`) are reused across room_list + room_detail.
- Excluded per D3: `$X/head` price templates, raw server status codes/route names.

## Verification
- `flutter gen-l10n`: clean (853 es untranslated — expected)
- `flutter analyze`: 0 errors
