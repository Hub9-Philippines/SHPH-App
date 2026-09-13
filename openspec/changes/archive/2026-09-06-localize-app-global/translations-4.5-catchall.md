# Task 4.5 — Re-audit Remaining Display Literals (DRAFT)

Consolidated from 3 explore agents + services/auth gap check. User decisions applied:
- tm_catalog 15 titles → LOCALIZE
- search_page quick chips → LOCALIZE (reuse `hmCat*` keys from 4.2)
- payment labels → LOCALIZE 'Card'/'COD'/'Cash on Completion'; EXCLUDE brand names (GCash, Visa, Mastercard, Maya)
- booking_success calendar → LOCALIZE
- dispatch/tm_repo fallbacks → LOCALIZE at render site (widget layer)

---

## A. Confirmed NEW keys needed (append to both ARBs)

| key | EN | FIL (Taglish) | Notes |
|---|---|---|---|
| **Bookings empty states** |
| `bkEmptySearchTitle` | No bookings matched | Walang nahanap na booking |
| `bkEmptySearchDesc` | Try another keyword or switch the status filter. | Subukan ibang keyword o palitan ang filter. |
| `bkEmptyAllTitle` | No bookings found | Walang booking |
| `bkEmptyAllDesc` | You haven't scheduled any services yet. Find a pro to get started! | Wala pa kayong naka-schedule. Humanap ng pro! |
| `bkEmptyPendingTitle` | No pending jobs | Walang pending |
| `bkEmptyPendingDesc` | Any service requests waiting for provider approval will appear here. | Dito lalabas ang requests na nangangailangan ng approval. |
| `bkEmptyCompletedTitle` | No completed visits yet | Walang tapos pa |
| `bkEmptyCompletedDesc` | Once a service technician finishes a job, your history will show up here. | Kapag tapos na ng teknisyan, dito lalabas ang history. |
| `bkEmptyCanceledTitle` | No canceled bookings | Walang cancelled |
| `bkEmptyCanceledDesc` | Great! You don't have any canceled or interrupted service requests. | Good! Walang cancelled o interrupted request. |
| **Bookings status labels** (rendered in StatusPill on booking cards) |
| `bkStatusUnknown` | Unknown | Hindi alam |
| `bkStatusPending` | Pending | Pending |
| `bkStatusConfirmed` | Confirmed | Confirmed |
| `bkStatusInProgress` | In Progress | Ongoing |
| `bkStatusCompleted` | Completed | Tapos na |
| `bkStatusCancelled` | Cancelled | Cancelled |
| **Bookings fallbacks** |
| `bkFallbackUnknownService` | Unknown Service | Unknown Service |
| `bkFallbackService` | Service | Serbisyo |
| **Edit address** |
| `adSelectAddress` | Select address | Pumili ng address |
| **Reset link sent** |
| `rlsTitle` | Reset link sent! | Naipadala na ang reset link! |
| `rlsBody` | We've sent a password reset link to your email address. Please check your inbox and follow the instructions to reset your password. | Naipadala namin ang password reset link sa inyong email. Check inbox ninyo at sundin ang instructions. |
| **TM catalog titles** (displayed in tm_sub_category_screen & estimate screen) |
| `tmSubHomeLockout` | Home Lockout | Home Lockout |
| `tmSubLockRepair` | Lock Repair | Lock Repair |
| `tmSubLockReplace` | Lock Replacement | Lock Replacement |
| `tmSubPipeLeak` | Pipe Leak Repair | Pipe Leak Repair |
| `tmSubFaucetValve` | Faucet / Valve Issue | Faucet / Valve Issue |
| `tmSubDrainClog` | Drain Clog Clearing | Drain Clog Clearing |
| `tmSubOutletSwitch` | Outlet / Switch Issue | Outlet / Switch Issue |
| `tmSubBreakerTrip` | Breaker Trip Investigation | Breaker Trip Investigation |
| `tmSubLightingRepair` | Lighting Repair | Lighting Repair |
| `tmSubWasherDryer` | Washer / Dryer Issue | Washer / Dryer Issue |
| `tmSubRefrigerator` | Refrigerator Issue | Refrigerator Issue |
| `tmSubSmallAppliance` | Small Appliance Repair | Small Appliance Repair |
| `tmSubQuickRepair` | Quick Repair Visit | Quick Repair Visit |
| `tmSubDiagnostic` | Diagnostic Visit | Diagnostic Visit |
| `tmSubUrgent` | Urgent Assistance | Urgent Assistance |
| **TM active job chrome** |
| `tmTabMap` | Map | Mapa |
| `tmTabChat` | Chat | Chat |
| `tmTabProvider` | Provider | Provider |
| `tmDispatchServer` | Dispatch path: server-authoritative | Dispatch: server |
| `tmDispatchFallback` | Dispatch path: fallback matcher | Dispatch: fallback |
| `tmDispatchPending` | Dispatch path: pending | Dispatch: pending |
| `tmEtaFormat` | ETA {min} min | ETA {min} min |
| **TM broadcast chrome** |
| `tmRadiusLabel` | {km} km radius | {km} km radius |
| `tmTimedOut` | Timed out | Natapos ang oras |
| `tmModeServer` | Server dispatch | Server dispatch |
| `tmModeFallback` | Fallback dispatch | Fallback dispatch |
| `tmModePending` | Dispatch pending | Pending dispatch |
| **TM payment labels** (tm_payment_screen) |
| `tmPmtCard` | Card | Card |
| `tmPmtCashCompletion` | Cash on Completion | Cash on Completion |
| `tmPmtCardDesc` | Visa, Mastercard, and debit cards | Visa, Mastercard, at debit cards |
| **Live matching meta rows** |
| `lmRoute` | Route | Ruta |
| `lmReference` | Reference | Reference |
| **Product page** |
| `ppContact` | Contact | Contact |
| `ppBookNow` | Book Now | Book Now |
| `ppFallbackCustomer` | Customer | Customer |
| **Chat detail** |
| `ckPlaceholder` | Type a message... | Mag-type ng mensahe... |
| **Search page** |
| `spBookingRefPrefix` | Booking # | Booking # |
| **Booking fallbacks** (booking_payment_widget + booking_widget) |
| `bkFallbackService` | Service | Serbisyo |
| **My notifications / chat timestamps** |
| `msJustNow` | Just now | Kakalang |
| **Booking success calendar** |
| `bsCalTitle` | Serbisyo booking | Serbisyo booking |
| `bsCalDesc` | Booking {id} via Serbisyo | Booking {id} via Serbisyo |
| **Dispatch/TM repo fallbacks at render site** |
| `tmHwTitle` | Hardware Parts Required | Hardware Parts Required |
| `tmProviderDefault` | Service Provider | Service Provider |
| `tmVehicleNearby` | Nearby service unit | Malapit na unit |
| `tmVehicleExpanded` | Expanded-area service unit | Malawak na unit |
| `tmProviderFallback` | Provider | Provider |
| `tmVehicleFallback` | Service unit | Service unit |

---

## B. Reused EXISTING keys (no new key)

| Existing key | Where reused |
|---|---|
| `hmCatCleaning` | search_page quick chips (4 chips) |
| `hmCatPlumbing` | search_page quick chips |
| `hmCatElectrical` | search_page quick chips |
| `hmCatPainting` | search_page quick chips |
| `msJustNow` | my_notifications_widget 'Just now', chat_page_model 'Just now' |
| `adDefault`, `adAddNewAddress`, `adNoAddressesYet` | already in ARB |
| `ccDismiss`, `ccOK`, `ccConfirm`, `ccCancel`, `ccSomethingWrong` | shared |

---

## C. Exclusions (per prior decisions / recorded policy)

| String | File | Reason |
|---|---|---|
| Onboarding marketing copy (6 strings) | onboarding_widget.dart | 3.17 decision: kept English |
| Help/FAQ Q&A (18 strings) | help_page.dart | 3.16 decision: kept English |
| Chatbot greeting/error (4 strings) | chatbot_page.dart | 3.16 decision: kept English |
| Terms of Service body (7 paragraphs) | terms_of_service_widget.dart | 3.16 decision: kept English |
| Privacy Policy body (6 paragraphs) | privacy_policy_widget.dart | 3.16 decision: kept English |
| AI composer detail labels (6) | ai_booking_composer_widget.dart | 3.17 decision: kept English |
| Project create dropdown (4) | project_create_widget.dart | 3.15 decision: English loanwords |
| 'GCash'/'Maya'/'Visa'/'Mastercard' | checkout, tm_payment | Brand proper nouns |
| 'Just now' / 'm ago' / 'h ago' formats | chat_page_model._formatTime | 3.18: D3-excluded format templates |
| booking_models 'Choose a service' | booking_models.dart | Dead code (never called) |
| geographic_selection_model getTitle | geographic_selection_model.dart | Dead code (widget uses _getTitle with l10n) |
| tm_controller fallback strings | tm_controller.dart | Nullable-l10n backstop pattern (no live callers) |
| face_verification_auth_flow snackbar | face_verification_auth_flow.dart | Dead code (no callers) |
| uploading_widget, categoriesgrid, password_validation_item | components/ | Dead components (never instantiated) |
| Currency/format templates ('₱', 'PHP', 'km', etc.) | various | D3 exclude |

---

## D. Wiring plan (key files)

### 1. `lib/main/bookings/bookings_model.dart`
- Empty states (lines 94-117): replace hardcoded title/description with `_l10n.bkEmpty*`
- `errorMessage` line 206: prefix → `_l10n.bkErrorPrefix` (reuse `ehGenericError`?) + `$e` localized; actually agent found `errorMessage` at line 206 = `Failed to load bookings: $e` displayed verbatim at bookings_widget:572. Replace with localized error: `_l10n.bkErrorLoadBookings`
- `_formatStatus` (lines 218-230): return `_l10n.bkStatus*` instead of hardcoded English
- Fallback fields (190-191): `_l10n.bkFallbackUnknownService` / `bkFallbackService`
- Note: `bookings_model` currently has no `_l10n` getter — add `AppLocalizations? get _l10n => AppLocalizations.of(context);` (but model doesn't have context; need to pass l10n from widget). Wait — bookings_model is used by bookings_widget which has `_l10n`. The model could be passed `l10n` in methods, or empty states could be localized at widget level. Actually the model returns the strings to the widget. Option A: model methods take `l10n` param. Option B: widget localizes the model's fallback keys. The cleanest: model returns enum/key, widget does l10n. But that's a refactor. For minimal change: add `l10n` param to `_buildEmptyState`, `_formatStatus`, error getter. The `bookings_model` already receives `context` in some methods? Check. I'll wire by adding `l10n` to the model's `errorMessage` getter and empty state builders, called from widget with `_l10n`.

### 2. `lib/main/bookings/bookings_widget.dart`
- Line 572: `errorMessage` displayed in ErrorState → model returns localized error (pass `_l10n` to model's errorMessage getter).
- Pass `_l10n` to model where needed.

### 3. `lib/components/edit_address/edit_address_widget.dart:112`
- Bottom sheet title `Select address` → `_l10n.adSelectAddress` (State has `_l10n` getter added in 4.4)

### 4. `lib/components/reset_link_sent/reset_link_sent_widget.dart`
- Line 64: `Reset link sent!` → `_l10n.rlsTitle`
- Line 84: long body → `_l10n.rlsBody`
- This is a StatelessWidget → add build-local `_l10n`

### 5. `lib/main/services/tm_catalog.dart`
- `TMSubCategoryOption.title` fields (lines 19,27,35,48,56,64,77,85,93,106,114,122,134,142,150) → these are const data. Options:
  - Keep const data, localize at render site (tm_sub_category_screen)
  - Add l10n to model and replace with key
  - The tm_catalog is a data file; render site is tm_sub_category_screen. Thread l10n there and map titles to keys.
  - Simpler: change tm_catalog titles to use key constants (e.g. `titleKey: 'tmSubHomeLockout'`), then tm_sub_category_screen does `_l10n.tmSubHomeLockout`. I'll do this.

### 6. `lib/pages/tm_flow/tm_sub_category_screen.dart`
- Where titles are rendered (around line 188 per agent) → use `_l10n` mapping.

### 7. `lib/pages/tm_flow/tm_active_job_screen.dart`
- TabBar labels (125-127) → `_l10n.tmTabMap`/`tmTabChat`/`tmTabProvider`
- Dispatch path pills (199-201) → map `_l10n.tmDispatch*`
- ETA format (353) → `_l10n.tmEtaFormat` (format string)
- Hardware request dialog title (236) shows `hardwareRequest.title` → map via localized fallback
- Provider info (353) uses `${provider.specialty} • ETA ${provider.etaMinutes} min` → if specialty is repo fallback, map; else API data (exclude). Repo fallback 'Service Provider' → `_l10n.tmProviderDefault`

### 8. `lib/pages/tm_flow/tm_broadcast_screen.dart`
- Radius badge (303) → `_l10n.tmRadiusLabel`
- Timed out (317) → `_l10n.tmTimedOut`
- Dispatch mode chips (532-534) → `_l10n.tmMode*`

### 9. `lib/pages/tm_flow/tm_payment_screen.dart`
- Payment choice labels (77, 88, 99) → `_l10n.tmPmtCard`, `tmPmtCashCompletion`, and 'GCash' EXCLUDE
- Subtitle (89) → `_l10n.tmPmtCardDesc` (Visa/Mastercard are brands, but descriptive text localizable)

### 10. `lib/pages/live_matching/live_matching_screen.dart`
- Lines 1344, 1360: `_MetaRow` labels 'Route'/'Reference' → `_l10n.lmRoute`/`lmReference`

### 11. `lib/pages/product_page/product_page_widget.dart`
- Line 1007: CTA 'Contact' → `_l10n.ppContact`
- Line 1027: CTA 'Book Now' → `_l10n.ppBookNow`
- Line 904: 'Customer' fallback → `_l10n.ppFallbackCustomer`

### 12. `lib/pages/chat_detail/chat_detail_widget.dart:163`
- Placeholder 'Type a message...' → `_l10n.ckPlaceholder`

### 13. `lib/pages/search_page/search_page_widget.dart`
- Quick category chips (492,497,502,507) → reuse `_l10n.hmCatCleaning`/`hmCatPlumbing`/`hmCatElectrical`/`hmCatPainting`
- Booking reference prefix (769) `'Booking #${...}'` → `_l10n.spBookingRefPrefix`

### 14. `lib/pages/booking_funnel/booking_payment_widget.dart:403` + `booking_widget.dart:326,337`
- `widget.category ?? 'Service'` → `widget.category ?? _l10n.bkFallbackService`
- `widget.serviceName ?? 'Service'` → same fallback or add `bkFallbackServiceName`

### 15. `lib/main/bookings/checkout_screen.dart`
- Payment pills (433,440,447): 'GCash' EXCLUDE; 'Card' → `_l10n.tmPmtCard`; 'COD' → need key `bkPmtCOD` (add new? or reuse `tmPmtCashCompletion`? COD = Cash on Delivery, different. Add `bkPmtCOD`).

Wait — checkout_screen uses 'COD' as abbreviation. Let me add `bkPmtCOD`. And 'Card' reuse `tmPmtCard`.

### 16. `lib/pages/booking_success/booking_success_screen.dart`
- Calendar event title (51) → `_l10n.bsCalTitle`
- Calendar details (60) → `_l10n.bsCalDesc`

### 17. `lib/pages/tm_flow/tm_controller.dart`
- The English backstops in `l10n?.tmErrorApproveHardware ?? 'Could not approve...'` etc. → leave as-is (INFO, backstop pattern). No action.

### 18. `lib/pages/my_notifications/my_notifications_widget.dart:751`
- 'Just now' → `_l10n.msJustNow` (reuse from 4.2 messages)

### 19. `lib/services/dispatch_repository.dart` / `tm_repository.dart` + `tm_active_job_screen.dart`
- `TMHardwareRequest.title` 'Hardware Parts Required' displayed in dialog → tm_active_job_screen maps to `_l10n.tmHwTitle`
- `provider.specialty` fallback 'Service Provider' → `_l10n.tmProviderDefault`
- `vehicleLabel` 'Nearby service unit'/'Expanded-area service unit' → `_l10n.tmVehicleNearby`/`tmVehicleExpanded`
- provider name fallback 'Provider' → `_l10n.tmProviderFallback`
- vehicleLabel fallback 'Service unit' → `_l10n.tmVehicleFallback`
- These are rendered in tm_active_job_screen; wire by mapping there (widget has `_l10n`).

### 20. `lib/services/chat_detail_service.dart` — logging only, no action.

---

## E. Open verification items

- `bookings_model` threading: needs `l10n` param in methods called from widget; check if model has context access or needs explicit pass.
- `tm_catalog` const data → render-site localization in `tm_sub_category_screen` (need to verify that screen has `_l10n` and is the sole consumer).
- `tm_controller` backstops: confirm no action needed (they're backstops for nullable l10n).
- `checkout_screen` 'COD' → new key `bkPmtCOD` or reuse?
- `tm_payment_screen` 'Cash on Completion' vs checkout 'COD' — same concept? Different UI. Separate keys fine.
- `tmEtaFormat` placeholder `{min}` — need to verify parameterization works in ARB (yes, standard `{min}`).
- `tmRadiusLabel` placeholder `{km}` — same.
- Ensure `flutter gen-l10n` clean + `flutter analyze` 0 errors after wiring.

---

## F. Summary count

- **New keys**: ~65 (including tm_catalog 15, bookings 19, tm flow chrome 14, product 3, etc.)
- **Reused keys**: 4 (hmCat* ×4, msJustNow, adDefault, adAddNewAddress, adNoAddressesYet)
- **Files to edit**: ~20 files
- **Excluded by prior decision**: 40+ strings (onboarding, legal, FAQ, chatbot, AI composer, project dropdown, currency, brands)