# Booking Details - Filipino (Taglish) Strings

Screen: `lib/pages/booking_details/`

Batch status: **approved & wired** (Task 3.4 done, `flutter analyze` = 0 errors)

All strings below are present in both `app_en.arb` and `app_fil.arb` (keys prefixed `bd*`) and wired through `AppLocalizations`. `{e}` marks an interpolated error placeholder.

## Errors / views

| Key | English | Approved Taglish |
|-----|---------|------------------|
| bdBookingIdRequired | Booking ID is required | Kailangan ang Booking ID |
| bdBookingNotFound | Booking not found | Hindi nahanap ang booking |
| bdFailedLoadBooking | Failed to load booking: {e} | Nabigong i-load ang booking: {e} |
| bdCouldNotLoadBooking | Could not load booking | Hindi ma-load ang booking |
| bdRetry | Retry | Subukan muli |
| bdNoBookingData | No booking data | Walang booking data |
| bdBookingUnavailable | This booking could not be found or is no longer available. | Hindi mahanap ang booking na ito o wala na ito. |
| bdGoBack | Go back | Bumalik |

## Cancel dialog / toasts

| Key | English | Approved Taglish |
|-----|---------|------------------|
| bdCancelBooking | Cancel Booking | I-cancel ang Booking |
| bdCancelConfirm | Are you sure you want to cancel this booking? | Sigurado ka bang gusto mong i-cancel ang booking na ito? |
| bdNo | No | Hindi |
| bdYes | Yes | Oo |
| bdCancelledSuccessfully | Booking cancelled successfully | Matagumpay na na-cancel ang booking |
| bdFailedCancelBooking | Failed to cancel booking | Nabigong i-cancel ang booking |

## Provider summary / tooltips

| Key | English | Approved Taglish |
|-----|---------|------------------|
| bdAssignedProvider | Assigned Provider | Assigned Provider |
| bdYourBooking | Your booking | Ang booking mo |
| bdNew | New | Bago |
| bdServiceProfessional | Service professional | Service professional |
| bdCallProvider | Call provider | Tawagan ang provider |
| bdMessageProvider | Message provider | Mag-message sa provider |

## Progress card

| Key | English | Approved Taglish |
|-----|---------|------------------|
| bdServiceProgress | Service progress | Progress ng service |
| bdThisBookingCancelled | This booking was cancelled. | Na-cancel ang booking na ito. |
| bdBookingPlaced | Booking placed | Naayos ang booking |
| bdProviderConfirmed | Provider confirmed | Kinumpirma ng provider |
| bdArrivedOnSite | Arrived on site | Dumating sa site |
| bdServiceInProgress | Service in progress | In progress ang service |
| bdCompleted | Completed | Completed |

## Info section

| Key | English | Approved Taglish |
|-----|---------|------------------|
| bdBookingInformation | Booking information | Impormasyon ng booking |
| bdInfoSubtitle | Core scheduling, payment, and location details. | Mga core na detalye sa schedule, payment, at location. |
| bdBookingId | Booking ID | Booking ID |
| bdDateAndTime | Date & Time | Petsa at Oras |
| bdStatus | Status | Status |
| bdPaymentStatus | Payment status | Status ng payment |
| bdPending | Pending | Pending |
| bdServiceLocation | Service location | Location ng service |
| bdSharedAfterAssignment | Shared with your provider after assignment | Ibabahagi sa provider mo pagkatapos ma-assign |
| bdNotes | Notes | Notes |
| bdNotesSubtitle | Special instructions attached to this booking. | Mga espesyal na instruksyon na naka-attach sa booking na ito. |

## Header / footer

| Key | English | Approved Taglish |
|-----|---------|------------------|
| bdBookingDetails | Booking Details | Booking Details |
| bdHeaderSubtitle | Review progress, schedule, and payment state. | Tingnan ang progress, schedule, at estado ng payment. |
| bdTrackOnMap | Track on Map | I-track sa Map |

## Status labels (`_formatStatus`)

| Key | English | Approved Taglish |
|-----|---------|------------------|
| bdUnknown | Unknown | Unknown |
| bdPending | Pending | Pending |
| bdConfirmed | Confirmed | Confirmed |
| bdInProgress | In Progress | In Progress |
| bdCompleted | Completed | Completed |
| bdCancelled | Cancelled | Cancelled |

## Notes
- **Exclusions (D3):** raw server `booking.status` shown by `_StatusBadge` stays as-is (wire/enum status); the `'Address: ...'` regex template in `_serviceLocationLine`, `PM/AM` + time formats, and the Notes body `_model.booking!.notes!` (backend/stored data) all stay untranslated.
- `bdCancelBooking` is reused for both the footer button and the confirm dialog title (same wording).
- The `bookingId == null` error path uses a post-frame callback (`WidgetsBinding...addPostFrameCallback`) since `AppLocalizations.of(context)` cannot be resolved during `initState`.