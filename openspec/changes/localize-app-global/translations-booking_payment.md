# Task 3.9 — `booking_payment` + `booking_success` + `booking`

Status: **Done** (verified `flutter analyze` 0 errors; 699 total = baseline)

## Screens & keys
- `booking_payment_widget.dart` → `bp*` (27)
- `booking_success_widget.dart` → `bs*` (8)
- `booking_widget.dart` → `bk*` (22)

57 keys added to both `app_en.arb` and `app_fil.arb` (parity maintained). No interpolated keys. `flutter gen-l10n` clean (only stale `es` warning).

## User-approved wording (authoritative — final edits applied)
The user supplied a corrected CSV; values below reflect their final Taglish (key → English → Taglish):

| Key | English | Taglish |
|-----|---------|---------|
| bpSelectPayment | Select Payment | Pumili ng Payment |
| bpSelectPaymentSubtitle | Review the booking and choose how you want to pay. | I-review ang booking at piliin kung paano ka magbabayad. |
| bpChooseHowToPay | Choose how you want to pay | Piliin kung paano mo gustong magbayad |
| bpEscrowSubtitle | Card, wallet, and QR payments are protected through escrow until the job is completed. | Protektado sa escrow ang card, wallet, at QR payments hanggang matapos ang trabaho. |
| bpCard | Credit / Debit Card | Credit / Debit Card |
| bpCardSub | Visa, Mastercard | Visa, Mastercard |
| bpEwallet | E-Wallets | E-Wallets |
| bpEwalletSub | GCash, Maya | GCash, Maya |
| bpQr | QR Ph Code | QR Ph Code |
| bpQrSub | Standard Philippine digital QR | Standard Philippine digital QR |
| bpCash | Cash on Completion | Cash on Completion |
| bpCashSub | Pay the pro directly after the job | Bayaran nang direkta ang pro pagkatapos ng trabaho |
| bpSummaryTitle | Booking summary | Booking summary |
| bpDate | Date | Petsa |
| bpTime | Time | Oras |
| bpNotes | Notes | Notes |
| bpNotSet | Not set | Wala pa |
| bpTotal | Total | Total |
| bpProcessing | Processing... | Nagpoproseso... |
| bpConfirm | Confirm Payment | I-confirm ang Payment |
| bpSelectMethod | Please select a payment method | Pumili ng payment method |
| bpEscrowNotice | Card, e-wallet, and QR payments are held in escrow. The provider receives the funds only after you confirm the work is done from your bookings page. | Naka-escrow ang card, e-wallet, at QR payments. Matatanggap lang ng provider ang pondo kapag i-confirm mo na tapos na ang trabaho sa bookings page. |
| bpConfirmSlot | You will confirm a slot shortly | Magi-confirm ka ng slot sa ilang sandali |
| bpFailedCreate | Failed to create booking. | Hindi na-create ang booking. |
| bpPaymentFailed | Payment failed | Hindi itinuloy ang payment |
| bsTitle | Booking Confirmed | Confirmed na ang Booking |
| bsSubtitle | Your request has been created successfully and the provider will be notified shortly. | Successfully created ang request mo at manonotify na ang provider. |
| bsNextTitle | What happens next | Ano ang susunod na mangyayari |
| bsNextDesc | You can track the request from your bookings page and we will keep you updated as the status changes. | Maaari mong i-track ang request mula sa bookings page at mabibigyan ka ng update kapag nagbago ang status. |
| bsProtectionTitle | Payment protection | Payment protection |
| bsProtectionDesc | Escrow-enabled payments stay protected until the work is completed and confirmed. | Protektado ang escrow payments hanggang matapos at ma-confirm ang trabaho. |
| bsViewBookings | View Bookings | Tingnan ang Bookings |
| bsBackHome | Back to Home | Bumalik sa Home |
| bkTitle | Book Service | Mag-book ng Service |
| bkSubtitle | Choose your schedule and location before payment. | Piliin ang schedule at lokasyon bago magbayad. |
| bkSelectDate | Select Date | Pumili ng Petsa |
| bkSelectDateSub | Pick the day you want the provider to arrive. | Piliin ang araw kung kailan dadating ang provider. |
| bkSelectTime | Select Time | Pumili ng Oras |
| bkSelectTimeSub | Choose your preferred appointment window. | Piliin ang preferred appointment window mo. |
| bkServiceAddress | Service Address | Service Address |
| bkServiceAddressSub | Tell the provider exactly where the work happens. | Sabihin sa provider kung saan ang eksaktong lokasyon ng trabaho. |
| bkAdditionalNotes | Additional Notes | Karagdagang Notes |
| bkAdditionalNotesSub | Share instructions, landmarks, or preparation details. | Mag-iwan ng instructions, landmark, o details. |
| bkNotesPlaceholder | Add any special instructions... | Magdagdag ng special instructions... |
| bkSelectDateAction | Select a date | Pumili ng petsa |
| bkSelectTimeAction | Select a time | Pumili ng oras |
| bkSelectServiceAddress | Select service address | Pumili ng service address |
| bkSelectedAddress | Selected address | Napiling address |
| bkTotal | Total | Total |
| bkProceed | Proceed to Payment | Magpatuloy sa Payment |
| bkErrServiceId | Service ID is required | Kailangan ng Service ID |
| bkErrSelectDate | Please select a date | Pumili ng petsa |
| bkErrSelectTime | Please select a time | Pumili ng oras |
| bkErrSelectAddress | Please select an address | Pumili ng address |

## Notes
- Payment method brand/sub-labels (`Visa, Mastercard`, `GCash, Maya`, `QR Ph Code`) kept English as brand/proper names.
- `bpNotSet`, `bkSelectServiceAddress`, `bkSelectedAddress`, and the `bkErr*` validation messages are user-facing (in UI/SnackBars) so they are translated (these are shown in `_model.errorMessage` / tile labels, not internal thrown exceptions).
- Escrow notice in `booking_payment` (`_buildEscrowNotice`) uses `bpEscrowNotice`; the section subtitle uses `bpEscrowSubtitle` (two distinct strings).
- Wiring: `_l10n` State getter everywhere; `_scheduledText()`, `_formattedBookingDate`, and `_selectedAddressTitle` (getters) access `_l10n` directly.
- Date month-name arrays (`Jan`...`Dec`) left hardcoded (D3 date/format template exclusion).
