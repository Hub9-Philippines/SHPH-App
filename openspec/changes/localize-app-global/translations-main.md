# Task 4.2 — Main/Tab Screens Localization Draft (FOR REVIEW)

Files: `lib/main/**` (10 widgets). This is the DRAFT — not yet applied to ARBs.
Please review/edit the FIL values; your edits override these. Brand names (GCash/Maya/Visa/Mastercard/etc.), raw backend enums (statuses, category IDs sent to routes), currency, proper nouns (Metro Manila, Serbisyo), and example placeholders (`0917...`, `1234...`, `John Doe`) stay English per scope decisions.

Wire value note: Tagalog category/service search is handled separately via `tagalog_service_keywords.dart` (Part A, already wired). Displayed category chips use the keys below; the backend category ID passed to routes stays English.

---

## Services (lib/main/services/services_widget.dart) — `sv*`

| Key | EN | FIL (draft) |
|-----|----|-------------|
| svSubtitle | Find the right pro for the job. | Hanapin ang tamang pro para sa trabaho mo. |
| svNoDispatchPros | No dispatch-ready pros nearby yet. | Wala pang dispatch-ready na pro sa malapit. |
| svSetLocation | Set location | Itakda ang lokasyon |
| svSearchPlaceholder | Search services or categories... | Maghanap ng services o categories... |
| svExploreEveryService | Explore every service | I-explore ang lahat ng services |
| svCountReady | {count} services ready to book | {count} na services ang ready i-book |
| svCountSorted | {count} services sorted by {filter} | {count} na services na ni-sort ayon sa {filter} |
| svSmartRanking | Smart ranking | Smart na ranking |
| svAllCategories | All categories | Lahat ng categories |
| svNoServicesAvailable | No services available | Walang available na services |
| svNoServicesFound | No services found | Walang nahanap na services |
| svNoCategoryListings | That category does not have live listings yet. | Wala pang live listings ang category na ito. |
| svTryBroaderKeyword | Try a broader keyword or clear your filters. | Subukan ang mas malawak na keyword o i-clear ang filters mo. |
| svDistanceUnknown | Distance unknown | Hindi alam ang distansya |
| svStartingFee | Starting Fee | Starting Fee |
| svFilterRecommended | Recommended | Recommended |
| svFilterTopRated | Top rated | Top rated |
| svFilterLowestPrice | Lowest price | Pinakamababang presyo |
| svFilterNearest | Nearest first | Unahin ang pinakamalapit |
| svPinnedAddress | Pinned address | Naka-pin na address |
| svVoiceComingSoon | Voice search coming soon | Voice search — darating pa lang |

**Reuses**: `bfServices` (Services), `spResetFilters` (Reset filters), `ccBookNow` (Book Now), `bfPinnedLocation` (Pinned location). Metro Manila stays as proper noun.

---

## Profile (lib/main/profile/profile_widget.dart) — `pf*`

| Key | EN | FIL (draft) |
|-----|----|-------------|
| pfNotFound | Profile not found | Hindi nahanap ang profile |
| pfAccountGroup | ACCOUNT | ACCOUNT |
| pfMyBookings | My Bookings | Mga Booking |
| pfMyBookingsSub | View past and upcoming jobs | Tingnan ang mga nakaraang at susunod na jobs |
| pfPaymentInvoices | Payment & Invoices | Payment at Invoices |
| pfPaymentInvoicesSub | View history and download invoices | Tingnan ang history at i-download ang invoices |
| pfLanguage | Language Preference | Kagustuhan sa Language |
| pfPrefsGroup | PREFERENCES & UTILITIES | MGA PREFERENCE AT UTILITIES |
| pfFavorites | Favorites | Favorites |
| pfFavoritesSub | Jump back into the services you saved | Balikan ang mga services na ni-save mo |
| pfMyReviews | My Reviews | Mga Review |
| pfMyReviewsSub | See the feedback you have left | Tingnan ang mga feedback na iniwan mo |
| pfReferral | Referral Program | Referral Program |
| pfReferralSub | Share and earn rewards | Mag-share at kumita ng rewards |
| pfNotificationSettings | Notification Settings | Mga Setting ng Notification |
| pfNotificationSettingsSub | Control alerts and reminders | Kontrolin ang alerts at reminders |
| pfHelpCenter | Help Center | Help Center |
| pfHelpCenterSub | FAQs and chat with our support team | Mga FAQ at chat sa support team namin |
| pfSystemAccessGroup | SYSTEM ACCESS | PAG-ACCESS SA SYSTEM |
| pfSecuritySub | Password, login protection, and app security | Password, login protection, at seguridad ng app |
| pfLogOutSub | Sign out of your account on this device | Mag-sign out sa account mo sa device na ito |
| pfSavedPlaces | Saved Places | Mga Naka-save na Lugar |
| pfSet | Set | Itakda |
| pfAdd | Add | Idagdag |
| pfVerificationGroup | VERIFICATION | VERIFICATION |
| pfAreYouProvider | Are you a service provider? | Service provider ka ba? |
| pfSwitchToProvider | Switch to Provider Account | Lumipat sa Provider Account |
| pfProviderDetected | Provider account detected | May nakitang provider account |
| pfProviderAppBody | Service providers use the dedicated Serbisyo Provider app. Open the store to install it, then sign in with the same account. | Gumagamit ang service providers ng dedicated na Serbisyo Provider app. Buksan ang store para i-install, pagkatapos mag-sign in gamit ang parehong account. |
| pfOpenProviderAppStore | Open Provider App Store | Buksan ang Provider App Store |
| pfInviteCopied | Invite link copied — share it to earn rewards! | Na-copy ang invite link — i-share para kumita ng rewards! |
| pfUploadingPhoto | Uploading photo… | Ina-upload ang photo… |
| pfUploadFailed | Could not upload photo. Please try again. | Hindi na-upload ang photo. Subukan muli. |
| pfPhotoUpdated | Profile photo updated! | Na-update ang profile photo! |
| pfUploadError | Upload failed: {error} | Nagsawing mag-upload: {error} |
| pfChooseGallery | Choose from gallery | Pumili mula sa gallery |
| pfTakePhoto | Take a photo | Kumuha ng photo |

**Reuses**: `seEditProfile` (Edit profile), `seSecurity` (Security), `logOut`/`logOutTitle`/`logOutConfirm`/`logOutAction` (logout + dialog). 'English, Filipino' subtitle stays (proper nouns). 'Rims Client' fallback stays.

---

## Payment Methods list (lib/main/payment_methods/payment_methods_widget.dart) — `pm*`

| Key | EN | FIL (draft) |
|-----|----|-------------|
| pmTitle | Payment Methods | Mga Paraan ng Payment |
| pmSubtitle | Manage how you pay for bookings. | Pamahalaan kung paano ka magbabayad sa bookings. |
| pmEndingIn | ending in {lastFour} | nagtatapos sa {lastFour} |
| pmExpires | Expires {month}/{year} | Mag-e-expire sa {month}/{year} |
| pmEwallet | E-Wallet | E-Wallet |
| pmNoPhone | No phone number | Walang phone number |
| pmEmptyTitle | No payment methods yet | Wala pang payment methods |
| pmEmptySubtitle | Add a card or e-wallet so checkout is faster when you book. | Magdagdag ng card o e-wallet para mas mabilis ang checkout kapag nag-book ka. |
| pmErrorLoading | Error loading payment methods | Nag-error sa pag-load ng payment methods |
| pmAddTitle | Add Payment Method | Magdagdag ng Payment Method |
| pmSetDefault | Set as default | Itakda bilang default |
| pmSetDefaultFull | Set as default payment method | Itakda bilang default na payment method |
| pmEdit | Edit | I-edit |
| pmRemove | Remove | Alisin |
| pmRemoved | Payment method removed | Inalis ang payment method |
| pmCreditDebitCard | Credit/Debit Card | Credit/Debit Card |
| pmEwalletOptions | E-Wallet (GCash, Maya) | E-Wallet (GCash, Maya) |
| pmNotAuthenticated | User not authenticated | Hindi pa naka-authenticate ang user |

**Reuses**: `retry` (Try again), `adDefault` (Default), `cancel` (Cancel). 'Card' fallback and 'E-Wallet (GCash, Maya)' brand handles stay.

---

## Add E-Wallet (lib/main/payment_methods/add_ewallet_payment_widget.dart) — `pew*`

| Key | EN | FIL (draft) |
|-----|----|-------------|
| pewUpdated | E-wallet updated successfully | Na-update ang e-wallet |
| pewAdded | E-wallet added successfully | Naidagdag ang e-wallet |
| pewSaveError | Error saving e-wallet: {error} | Nag-error sa pag-save ng e-wallet: {error} |
| pewTitle | Add E-Wallet | Magdagdag ng E-Wallet |
| pewInfoHeader | E-Wallet Information | Impormasyon ng E-Wallet |
| pewProvider | Provider | Provider |
| pewSelectProvider | Please select provider | Pakipili ang provider |
| pewPhoneNumber | Phone Number | Numero ng Telepono |
| pewEnterPhone | Please enter phone number | Pakilagay ang phone number |
| pewValidPhone | Please enter a valid 11-digit phone number | Pakilagay ang valid na 11-digit na phone number |
| pewAccountName | Account Name | Pangalan ng Account |
| pewEnterAccountName | Please enter account name | Pakilagay ang account name |

**Reuses**: `pmSetDefaultFull`, `pmNotAuthenticated`. Brand drop items (GCash/Maya/ShopeePay/GrabPay) stay. Placeholder `0917 123 4567` and `John Doe` stay.

---

## Add Card (lib/main/payment_methods/add_card_payment_widget.dart) — `pca*`

| Key | EN | FIL (draft) |
|-----|----|-------------|
| pcaUpdated | Card updated successfully | Na-update ang card |
| pcaAdded | Card added successfully | Naidagdag ang card |
| pcaSaveError | Error saving card: {error} | Nag-error sa pag-save ng card: {error} |
| pcaTitle | Add Card | Magdagdag ng Card |
| pcaInfoHeader | Card Information | Impormasyon ng Card |
| pcaCardNumber | Card Number | Numero ng Card |
| pcaEnterCardNumber | Please enter card number | Pakilagay ang card number |
| pcaValidCardNumber | Please enter a valid card number | Pakilagay ang valid na card number |
| pcaCardType | Card Type | Uri ng Card |
| pcaSelectCardType | Please select card type | Pakipili ang card type |
| pcaRequired | Required | Kinakailangan |
| pcaInvalidMonth | Invalid month | Hindi valid na buwan |
| pcaInvalidYear | Invalid year | Hindi valid na taon |
| pcaCardholderName | Cardholder Name | Pangalan ng Cardholder |
| pcaEnterCardholderName | Please enter cardholder name | Pakilagay ang cardholder name |

**Reuses**: `pmSetDefaultFull`, `pmNotAuthenticated`. Brand drop items (Visa/Mastercard/American Express) stay. Placeholders `1234 5678 9012 3456`, `MM`, `12`, `YYYY`, `2025`, `John Doe` stay.

---

## Messages (lib/main/messages/messages_widget.dart) — `ms*`

| Key | EN | FIL (draft) |
|-----|----|-------------|
| msTitle | Messages | Messages |
| msSubtitle | Stay close to providers, updates, and support. | Manatiling malapit sa mga provider, updates, at support. |
| msChats | Chats | Mga Chat |
| msCallsHistory | Calls history | Kasaysayan ng mga Tawag |
| msSearchPlaceholder | Search conversations or calls | Maghanap ng conversations o tawag |
| msRecentConversations | Recent conversations | Mga Kamakailang conversations |
| msRecentCalls | Recent calls | Mga Kamakailang tawag |
| msItems | {itemCount} items | {itemCount} na items |
| msNoConversations | No conversations yet | Wala pang conversations |
| msNoConversationsMatch | No conversations matched | Walang naitugmang conversations |
| msEmptyChatsBody | Messages from your providers will show up here once a booking starts. | Lalabas dito ang messages mula sa mga provider mo kapag nagsimula na ang booking. |
| msTryAnotherProvider | Try another provider name or keyword. | Subukan ang ibang provider name o keyword. |
| msNoCalls | No call activity yet | Wala pang call activity |
| msNoCallsMatch | No calls matched | Walang naitugmang tawag |
| msEmptyCallsBody | Your completed and missed calls will appear here when that history is available. | Lalabas dito ang mga natapos at namiss na tawag kapag available na ang history. |
| msTryOtherSearch | Try a different search term. | Subukan ang ibang search term. |
| msNoMessages | No messages yet | Wala pang messages |
| msConversation | Conversation | Conversation |
| msUnreadCount | {unreadCount} unread | {unreadCount} na hindi pa nababasa |
| msJustNow | Just now | Kakalang pa lang |
| msMinutesAgo | {n}m ago | {n}m ang nakalipas |
| msHoursAgo | {n}h ago | {n}h ang nakalipas |
| msDaysAgo | {n}d ago | {n}d ang nakalipas |

**Excluded**: raw backend statuses (`call.status.toUpperCase()`, `call.type`), dynamic names/dates.

---

## Home (lib/main/home/home_widget.dart) — `hm*`

| Key | EN | FIL (draft) |
|-----|----|-------------|
| hmSearchPlaceholder | Search services... | Maghanap ng services... |
| hmMore | More | Higit Pa |
| hmBookingStartsPinned | Booking starts from your pinned location | Magsisimula ang booking mula sa naka-pin mong lokasyon |
| hmPinnedAddress | Pinned address | Naka-pin na address |
| hmCurrentDeviceLocation | Current device location | Kasalukuyang lokasyon ng device |
| hmSelectLocation | Select your location | Pumili ng lokasyon mo |
| hmExitApp | Exit App | Lumabas sa App |
| hmExitConfirm | Are you sure you want to exit the app? | Sigurado ka bang gusto mong lumabas sa app? |
| hmExit | Exit | Lumabas |
| hmChooseLocation | Choose location | Pumili ng lokasyon |
| hmChooseLocationSub | Use your live device location or one of your saved addresses. | Gamitin ang live device location mo o isa sa mga naka-save mong address. |
| hmUseLiveLocation | Use your live phone location on the map | Gamitin ang live phone location mo sa mapa |
| hmEnableLocationServices | Enable location services to use this option | I-enable ang location services para magamit ang option na ito |
| hmSavedAddress | Saved address | Naka-save na address |
| hmWaitingConfirmation | Waiting for provider confirmation | Naghihintay ng confirmation mula sa provider |
| hmProviderConfirmedToday | Provider confirmed for today | Kinumpirma ng provider para ngayong araw |

**Category chips** (display localized, backend param stays English):
| Key | EN (param/label) | FIL (draft label) |
|-----|------------------|---------------------|
| hmCatCleaning | Cleaning | Paglilinis |
| hmCatPlumbing | Plumbing | Pagkukumpuni ng Tubo |
| hmCatElectrical | Electrical | Elektrikal |
| hmCatPainting | Painting | Pagpipinta |

**Reuses**: `bfPinnedLocation` (Pinned location), `adAddNewAddress` (Add new address), `cancel` (Cancel). Metro Manila stays. Mock demo data (Ramon Dela Cruz, 'Home Cleaning', statuses) stays.

---

## Explore (lib/main/explore/explore_widget.dart) — `ex*`

| Key | EN | FIL (draft) |
|-----|----|-------------|
| exTitle | Explore | Explore |
| exSubtitle | Discover top-rated pros and seasonal deals. | Tuklasin ang mga top-rated pros at seasonal deals. |
| exSearchPlaceholder | Search services or providers | Maghanap ng services o providers |
| exVoiceComingSoon | Voice search coming soon | Voice search — darating pa lang |
| exServiceCategory | Service Category | Kategorya ng Serbisyo |
| exViewAll | View All | Tingnan lahat |
| exTopRatedNearYou | Top Rated Near You | Top Rated na Malapit sa Iyo |
| exServiceProviderFallback | Service Provider | Service Provider |
| exRecommendedForYou | Recommended for You | Recommended para sa Iyo |
| exNoRecommendations | No recommendations yet — book a service to personalize this feed. | Wala pang recommendations — mag-book ng service para ma-personalize ang feed na ito. |
| exInviteCopied | Invite link copied — share it with friends! | Na-copy ang invite link — i-share sa mga kaibigan! |

**Excluded**: route strings, category names (backend), invite URL. `Service Provider` fallback is display → included.

---

## Category (lib/main/category/category_widget.dart) — `ctg*`

| Key | EN | FIL (draft) |
|-----|----|-------------|
| ctgSubtitle | Jump into the service type you need most. | Pumasok sa service type na pinaka-kailangan mo. |

**Reuses**: `catgTitle` for the 'Categories' title? `catgTitle` = "All Categories". The header here is 'Categories' — needs its own. Use `ctgTitle` = Categories / Mga Kategorya.

---

## Bookings (lib/main/bookings/bookings_widget.dart) — `bkf*`

| Key | EN | FIL (draft) |
|-----|----|-------------|
| bkfTitle | Bookings | Mga Booking |
| bkfSubtitle | Track active work, completed visits, and next steps. | Subaybayan ang active work, natapos na visits, at mga susunod na hakbang. |
| bkfPending | Pending | Naka-pending |
| bkfCompleted | Completed | Natapos |
| bkfCanceled | Canceled | Kinansela |
| bkfRescheduleSoon | Rescheduling is coming soon. | Darating na ang rescheduling. |

**Reuses**: `exSearchPlaceholder` (search), `spAll` (All), `ccSomethingWrong` (error), `retry` (Try again). Currency `PHP`, date/status raw backend values, AM/PM stay.

---

## New keys total: ~83
Reuses: `bfServices`, `spResetFilters`, `ccBookNow`, `bfPinnedLocation`, `seEditProfile`, `seSecurity`, `logOut` (+3), `retry`, `adDefault`, `cancel`, `adAddNewAddress`, `pmSetDefaultFull`, `pmNotAuthenticated`, `catgTitle`, `exSearchPlaceholder`, `spAll`, `ccSomethingWrong` (reused definitions; no new key lines).

All new keys use placeholder params for interpolated strings ({count}, {filter}, {error}, {lastFour}, {month}, {year}, {itemCount}, {unreadCount}, {n}).