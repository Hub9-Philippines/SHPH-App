## 1. Direct chat thread fix

- [x] 1.1 Add `ShphChatApi.getOrCreateDirectThread(int providerId)` posting to `/api/chat/threads/direct/` with `{'provider_id': providerId}`
- [x] 1.2 Update `ChatService.getOrCreateDirectThread` to parse the provider id to `int` and call the new endpoint (instead of posting to the booking endpoint with an empty id); keep null-on-error behavior

## 2. Contact action sheet combined mode

- [x] 2.1 Add a combined `ContactActionKind` (e.g. `all`) to `contact_action_sheet.dart` that shows "Chat in app", "Call using the app", and — when `phoneAvailable` — "Text via SMS" and "Call by number", disabling number rows with an explanatory subtitle otherwise
- [x] 2.2 Verify sheet still uses `AppTheme.of(context)` tokens only (no hardcoded hex) and returns the existing `ContactActionChoice` values

## 3. Service page contact actions

- [x] 3.1 Replace `_openContactProvider()` on the service page with a handler that opens the combined contact action sheet
- [x] 3.2 Wire `inAppChat` → ensure direct thread via `ChatService.getOrCreateDirectThread`, then `context.pushNamed(ChatPageWidget.routeName, pathParameters: {'roomId': roomId}, extra: {providerName, providerPhoto})` with SnackBar on null thread
- [x] 3.3 Wire `inAppCall` → `CallAcceptPermissionSheet.show(context, callType: CallType.audio)` then `ShphChatApi.instance.initiateCall({thread_id, callee_id, media_type: 'audio'})`, creating the thread first if needed, with SnackBar fallback
- [x] 3.4 Wire `callByNumber` → `launchURL('tel:...')` and `textSms` → `launchURL('sms:...')`
- [x] 3.5 Resolve the provider phone once after provider profile load via `ShphProvidersApi.instance.getProvider(providerId)`, storing `phone_number` for the sheet's `phoneAvailable` state (leave null on failure)

## 4. Service page button label sizing

- [x] 4.1 Shrink the bottom-bar Contact/Book now `FFButtonWidget` `textStyle` from `titleSmall` to a smaller style (e.g. `labelLarge`) so labels render fully on one line with no clipped descenders
- [x] 4.2 Apply the same one-line fitting to the provider-card Contact/Book now buttons if any label clips

## 5. Real microphone/camera permission request

- [x] 5.1 In `call_accept_permission_sheet.dart`, make the allow handler request the real OS permission via `permission_handler` (microphone for audio; camera + microphone for video) with a brief loading state
- [x] 5.2 Show the granted banner only when the OS returns `granted`/`limited`; show denial banner and skip `onPermissionGranted` for `denied`
- [x] 5.3 For `permanentlyDenied`, show the denial banner plus an "Open settings" action (`permission_handler.openAppSettings()`); add any new l10n keys to `lib/l10n/app_*.arb` and run `flutter gen-l10n`

## 6. Verification

- [x] 6.1 Run `flutter analyze` and confirm 0 errors (no new errors/warnings in changed files)
- [ ] 6.2 On a device: service page Contact shows chat/call (+SMS/call-by-number when a number resolves), "Chat in app" opens a real room, mic permission prompt reflects the real OS result, and Contact/Book now labels fit their buttons