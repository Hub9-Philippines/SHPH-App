## 1. Contact actions sheet component

- [x] 1.1 Create `lib/components/contact_action_sheet.dart` with `showContactActionSheet` exposing a themed bottom sheet for `ContactActionKind.call` and `ContactActionKind.message`, each with the two options and returning the chosen `ContactActionChoice` via `Navigator.pop`
- [x] 1.2 Style the sheet with `AppTheme.of(context)` tokens only (no hardcoded hex), reusing `ScreenHeader`-style spacing and existing radius tokens
- [x] 1.3 Support a disabled state: when the phone number is unavailable, the "call by number" / "text via SMS" options are disabled with an explanatory subtitle

## 2. Provider phone resolution

- [x] 2.1 Add `providerPhone` field to `BookingDetailsModel` (default null)
- [x] 2.2 In `_loadBookingDetails()`, after the listing resolves with a `provider_id`, call `ShphProvidersApi.instance.getProvider(providerId)` and store `phone_number` (or `phone`) into `_model.providerPhone`; leave it null on failure so the sheet degrades gracefully

## 3. Booking details actions

- [x] 3.1 Replace both `_openContact` floating-button handlers with `_onCallPressed()` and `_onMessagePressed()` that open the contact action sheet
- [x] 3.2 Wire `callByNumber` → `launchURL('tel:$_model.providerPhone')`
- [x] 3.3 Wire `sms` → `launchURL('sms:$_model.providerPhone')`
- [x] 3.4 Wire `inAppChat` → ensure direct thread via `ChatService.getOrCreateDirectThread`, then `context.pushNamed(ChatPageWidget.routeName, pathParameters: {'roomId': roomId}, extra: {providerName, providerPhoto})` with SnackBar on null thread
- [x] 3.5 Wire `inAppCall` → `CallAcceptPermissionSheet.show(context, callType: CallType.audio)` followed by `ShphChatApi.instance.initiateCall({thread_id, callee_id, media_type: 'audio'})`, creating the thread first if needed, with SnackBar fallback on failure
- [x] 3.6 Remove the now-unused `_openContact` method (or keep only if still referenced)

## 4. Verification

- [x] 4.1 Run `flutter analyze` and confirm 0 errors (no new warnings/errors in changed files)
- [ ] 4.2 Tap Call and Message on the booking details screen on a device: both dialer/SMS and in-app chat/call paths behave per spec; no path opens the legacy contact hub