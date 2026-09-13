# Task 3.10 — `product_page` + `contact_provider` Localization (Final CSV)

User-approved Taglish values. Keys appended to both `app_en.arb` and `app_fil.arb` after `bkErrSelectAddress`.

## `product_page` — `pp*`

| Key | English (final) | Filipino/Taglish (final) |
|-----|-----------------|--------------------------|
| ppAddedToFavorites | Added to favorites | Naidagdag sa favorites |
| ppRemovedFromFavorites | Removed from favorites | Naalis sa favorites |
| ppMinAgo | {minutes} min ago | {minutes} min ang nakalipas |
| ppHoursAgo | {hours} hr ago | {hours} hr ang nakalipas |
| ppDayAgo | 1 day ago | 1 araw ang nakalipas |
| ppDaysAgo | {days} days ago | {days} araw ang nakalipas |
| ppWeeksAgo | {weeks} weeks ago | {weeks} linggo ang nakalipas |
| ppMonthsAgo | {months} months ago | {months} buwan ang nakalipas |
| ppRating | {rating}/5 | {rating}/5 |
| ppReviews | {reviews} reviews | {reviews} reviews |
| ppAboutTitle | All you need to know before booking | Lahat ng dapat malaman bago mag-book |
| ppAboutSubtitle | Quick booking | Mabilisang booking |
| ppVerified | Verified | Beripikado |
| ppContact | Contact | I-contact |
| ppBookNow | Book now | Mag-book na |
| ppWhyTitle | Why customers book this | Bakit ito binu-book ng customers |
| ppWhySubtitle | A quick snapshot before the booking flow starts | Mabilisang snapshot bago mag-book |
| ppFastHandoff | Fast handoff | Mula service details diretso sa booking sa isang step |
| ppFastHandoffDesc | Go from service details to booking in one step | May {reviews} reviews para sa listing na ito |
| ppSocialProof | Social proof | I-message muna ang provider para malinaw ang scope o timing |
| ppSocialProofDesc | {reviews} review(s) currently attached to this listing | Kamakailang feedback mula sa customers |
| ppProviderContact | Provider contact | {reviews} reviews available |
| ppProviderContactDesc | Message the provider first if you want to clarify scope or timing | {hours} hr ang nakalipas |
| ppRecentReviews | Recent reviews | 1 araw ang nakalipas |
| ppRecentReviewsSub | Recent customer feedback for this listing | {days} araw ang nakalipas |
| ppSeeAll | See all | {weeks} linggo ang nakalipas |
| ppNoReviews | No reviews yet | {months} buwan ang nakalipas |
| ppReviewsAvailable | {reviews} review(s) available | I-contact ang Provider |
| ppOverviewRating | Overall rating | Mag-reach out kay {name} |
| ppFastBooking | Fast booking | Magpadala ng message |
| ppVerifiedProvider | Verified provider | Direktang papasok ang message mo sa in-app chat thread |
| ppOpenListing | Open listing | Maglagay ng subject |

## `contact_provider` — `cp*`

| Key | English (final) | Filipino/Taglish (final) |
|-----|-----------------|--------------------------|
| cpTitle | Contact Provider | I-contact ang Provider |
| cpSubtitle | Reach out to {name} about service details or availability | Mag-reach out kay {name} |
| cpContactOptions | Contact options | Magpadala ng message |
| cpCall | Call | Direktang papasok ang message mo sa in-app chat thread |
| cpChat | Chat | Maglagay ng subject |
| cpOpening | Opening... | Maglagay ng message |
| cpSendMessageTitle | Send a message | Isulat ang message mo rito... |
| cpSendMessageSub | This sends your message straight into the existing in-app chat thread | Ipadala ang Message |
| cpSubject | Subject | Walang available na phone number |
| cpSubjectPlaceholder | What is this about? | Walang available na mobile number |
| cpSubjectRequired | Please enter a subject | Hindi mabuksan ang phone dialer |
| cpMessage | Message | |
| cpMessagePlaceholder | Write your message here... | |
| cpMessageRequired | Please enter a message | |
| cpSending | Sending... | |
| cpSendMessage | Send Message | |
| cpPhoneUnavailable | Phone number unavailable | |
| cpServiceDetails | Service details | |
| cpCannotContact | This provider cannot be contacted yet | |
| cpCouldNotOpenChat | Could not open chat right now | |
| cpMessageNotSent | Message could not be sent | |
| cpNoMobile | No mobile number available | |
| cpCouldNotOpenDialer | Could not launch phone dialer | |

## Verification
- `flutter gen-l10n`: clean (646 es untranslated — expected)
- `flutter analyze`: 0 errors (699 baseline)