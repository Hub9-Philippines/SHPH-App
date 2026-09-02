# Task 3.16 — `terms_of_service` + `privacy_policy` + `help` + `report_problem` + `disputes` + `reviews` + `my_reviews` + `write_review` + `recommendations` Localization (Final ARB)

User-approved Taglish values (105 keys). Appended to both `app_en.arb` and `app_fil.arb` after `cjStatusCancelled`.

## Scope decision (per user)
- **Legal bodies + FAQ content kept English**: full body paragraphs in Terms of Service & Privacy Policy, all Help FAQ questions/answers, and chatbot bot greeting/error paragraphs are treated as content and NOT localized.
- **Time-ago labels ARE localized** (user explicitly opted in, overriding the earlier D3 date/format-template exclusion where it applies to these).

## Keys added

### `terms_of_service` — `tos*`
`tosTitle`, `tosLastUpdated` (Huling na-update: {date}), `tosAcceptance`, `tosAccounts`, `tosServicesBookings`, `tosProhibited`, `tosPaymentsFees`, `tosLimitation`, `tosContact`.
Note: most section titles kept as clean English legal headers per user (e.g. "User Accounts", "Prohibited Conduct", "Limitation of Liability").

### `privacy_policy` — `priv*`
`privTitle` (Privacy Policy), `privLastUpdated`, `privCollect` (Impormasyong Kinokolekta Namin), `privUse` (Paano Namin Ginagamit ang Info Mo), `privSharing`, `privSecurity` (Data Security), `privRights` (Ang Iyong Mga Karapatan), `privContact`.

### `help` — `hp*`
`hpTitle` (Help & Support), `hpChatWithUs` (Mag-chat sa amin), `hpBooking`, `hpPayment`, `hpAccount`, `hpProviders`. FAQ Q/A content stays English.

### `chatbot` (help dir) — `cb*`
`cbTitle`, `cbOnline`, `cbTyping` (Nagta-type...), `cbHint` (Mag-type ng message...), `cbGettingAnswer`. Bot greeting/error paragraphs stay English (content).

### `report_problem` — `rp*`
`rpTitle` (Mag-report ng Problema), `rpBack`, `rpSubmit` (I-submit ang Ticket), `rpTicketSubmitted` (Na-submit na ang Ticket), `rpWillRespond`, `rpCategory` (Category), `rpCategoryBooking`/`rpCategoryPayment`/`rpCategoryAccount` (Booking/Payment/Account), `rpCategoryOther` (Iba pa), `rpDescribeIssue` (I-describe ang issue mo), `rpPlaceholder`, `rpMinChars` (Maglagay ng kahit 10 characters).
The raw category values (`Booking`/`Payment`/`Account`/`Other`) stay as model/data values; a `_rpCategoryLabel()` method maps them to localized display.

### `disputes` — `dp*`
`dpTitle` (Disputes Ko), `dpNoDisputes`, `dpViewBooking`, `dpStatusOpen` (Open), `dpStatusReview` (Under Review), `dpStatusResolved` (Resolved), `dpStatusRejected`, `dpStatusClosed`, `dpStatusEscalated`. `_statusLabel()` maps raw status to `_l10n`.

### `reviews` — `rv*`
`rvTitle`, `rvError`, `rvRetry`, `rvNoReviews`, `rvBeFirst` (Maging una na mag-review kay {name}), `rvUser`, and time-ago: `rvMinAgo` ({minutes}m ago), `rvHoursAgo` ({hours}h ago), `rvDayAgo` (1d ago), `rvDaysAgo` ({days}d ago), `rvWeeksAgo` ({weeks}w ago), `rvMonthsAgo` ({months}mo ago).
Time-ago kept compact (English-style `{n}h ago`) rather than the `ang nakalipas` form used by earlier `ss`/`pp`/`mn` keys — per user's explicit direction for these pages.

### `my_reviews` — `mr*`
`mrTitle` (Reviews Ko), `mrSubtitle`, `mrFootprint` (Feedback footprint mo), `mrFootprintSub`, `mrReviews`, `mrAverage`, `mr5Stars`, `mrNoReviews`, `mrEmptyBody`, `mrError`, `mrErrorSub`, `mrRetry`, `mrServiceFallback` (Service #{id}), `mrService`, `mrProvider`, `mrJustNow` (Kanina lang), `mrMinAgo`/`mrHoursAgo`/`mrDaysAgo` (compact).

### `write_review` — `wr*`
`wrTitle` (Mag-isulat ng Review), `wrExperience`, `wrTellMore`, `wrPlaceholder`, `wrSubmitted` (Na-submit na ang review!), `wrSubmit` (I-submit ang Review), `wrSelectRating` (Pumili ng rating), `wrFailed` (Hindi na-submit ang review.).
The model's `submitReview()` now takes an `AppLocalizations` param (D2) so model-set errors are localized.

### `recommendations` — `rcm*`
`rcmTitle`, `rcmTrending` (Trending Ngayon), `rcmNearYou` (Malapit sa 'Yo), `rcmPicked` (Para sa 'Yo), `rcmNoRecs`, `rcmBrowse`.

## Notes
- Prefix collisions checked: `priv*` free (pre-existing orphan `privacyPolicy`/`retry` keys unused, not reused — added page-scoped keys instead). `tos/hp/cb/rp/dp/rv/mr/wr/rcm` all free.
- `write_review` success SnackBar de-const'd (`SnackBar(content: Text(_l10n.wrSubmitted))`).
- Placeholder methods: `tosLastUpdated(date)`, `privLastUpdated(date)`, `rvBeFirst(name)`, `mrServiceFallback(id)`, `rvMinAgo`/`rvHoursAgo`/`rvDaysAgo`/`rvWeeksAgo`/`rvMonthsAgo`, `mrMinAgo`/`mrHoursAgo`/`mrDaysAgo`.

## Verification
- `flutter gen-l10n`: clean (es untranslated — expected)
- `flutter analyze`: 0 errors
