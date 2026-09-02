# TM Flow - Filipino (Taglish) Strings

Screen: `lib/pages/tm_flow/`

Batch status: **approved & wired** (Task 3.2 done, `flutter analyze` = 0 errors)

All strings below are now present in both `app_en.arb` and `app_fil.arb` and wired through `AppLocalizations`. Subcategory **titles** stay English; only subtitles are translated. `{...}` marks an interpolated placeholder that stays.

## Headings / screen titles

| Key | English | Proposed Taglish |
|-----|---------|------------------|
| tmChooseJobType | Choose a Job Type | Pumili ng Job Type |
| tmTimeMaterialFlow | Time-Material flow | Time-Material flow |
| tmPickClosestJobType | Pick the closest job type so we can give a tighter estimate before searching for nearby providers. | Pumili ng pinakamalapit na job type para makapagbigay kami ng mas tiyak na estimate bago maghanap ng mga kalapit na provider. |
| tmEstimate | Estimate | Estimate |
| tmEstimatedServiceFee | Estimated service fee | Tinantyang service fee |
| tmFinalChargesMayChange | Final charges may change depending on distance, job complexity, and hardware parts approved during the visit. | Pwedeng magbago ang final charges depende sa distansya, pagiging kumplikado ng trabaho, at hardware parts na inaprubahan sa pagbisita. |
| tmOnDemandDispatch | On-demand dispatch | On-demand dispatch |
| tmSearchNearbyFirst | We will search for nearby providers first before falling back to a wider search radius. | Maghahanap muna kami ng mga kalapit na provider bago lumipat sa mas malawak na search radius. |
| tmTimePlusMaterials | Time + materials | Time + materials |
| tmLaborEstimatedUpfront | Labor is estimated up front. Hardware and parts can be added only if you approve them later. | Tinantya muna ang labor. Ang hardware at parts ay maaari lamang idagdag kung i-approve mo mamaya. |
| tmFindProvider | Find Provider | Maghanap ng Provider |

## Broadcast screen

| Key | English | Proposed Taglish |
|-----|---------|------------------|
| tmExpandedRadiusSearch | Expanded radius search | Pinalawak na search radius |
| tmNoProviderFoundYet | No provider found yet | Wala pang nahanap na provider |
| tmSearchingNearbyProviders | Searching nearby providers | Naghahanap ng mga kalapit na provider |
| tmWidenedSearchRadius | We widened the search radius to reach more active providers. | Pinalawak namin ang search radius para maabot ang mas maraming aktibong provider. |
| tmNearbyExpandedTimedOut | Nearby and expanded searches both timed out. | Naubos na ang oras sa nearby at expanded searches. |
| tmBroadcastingRequest | Broadcasting your request to active providers near your pin. | Ipinapadala ang request mo sa mga aktibong provider malapit sa pin mo. |
| tmLookingForProvider | Looking for a provider | Naghahanap ng provider |
| tmCouldNotSecureProvider | We could not secure a provider from the current search cycle. | Hindi kami nakasecure ng provider sa kasalukuyang search cycle. |
| tmStayOnScreen | Stay on this screen while we keep your request active and visible to nearby providers. | Manatili sa screen na ito habang nananatiling aktibo ang request mo sa mga kalapit na provider. |
| tmCurrentlyScanning | Currently scanning providers within 4-8 km of your pin depending on the current search phase. | Kasalukuyang nag-scan ng mga provider sa loob ng 4-8 km mula sa pin mo depende sa kasalukuyang search phase. |
| tmDynamicFees | Dynamic fees | Dynamic fees |
| tmExpandedMayIncreaseFee | Expanded searches may increase the service fee based on travel distance. | Pwedeng tumaas ang service fee sa expanded searches depende sa layo ng byahe. |
| tmSearchReference | Search reference | Search reference |
| tmCancelSearch | Cancel Search | I-cancel ang Search |
| tmNoProviderFound | No provider found | Walang nahanap na provider |
| tmFinishedSearchWindows | We finished both search windows without a provider match. You can retry, switch to the scheduled flow, or head back home. | Naubos na ang parehong search windows nang walang nahanap na provider. Pwede kang sumubok muli, lumipat sa scheduled flow, o bumalik sa home. |
| tmSearchAgain | Search again | Maghanap muli |
| tmScheduleInstead | Schedule instead | Mag-schedule na lang |
| tmExpandingSearchNotice | Expanding Search... Service Fee may increase by 50-100 per km | Pinapalawak ang Search... Pwedeng tumaas ang Service Fee ng 50-100 kada km |
| tmTimedOut | Timed out | Naubos ang oras |

## Active job screen

| Key | English | Proposed Taglish |
|-----|---------|------------------|
| tmActiveJob | Active Job | Active Job |
| tmOnTheWay | On the way | Papunta na |
| tmLiveJobTracking | Live job tracking | Live job tracking |
| tmHeadingToLocation | {name} is heading to your location. If additional hardware is needed, you will see an approval prompt here. | Papunta na si {name} sa location mo. Kung kailangan ng karagdagang hardware, may lalabas na approval prompt dito. |
| tmApprovedHardware | Approved hardware: Php {amount} | Inaprubahang hardware: Php {amount} |
| tmMarkJobComplete | Mark Job Complete | Markahan bilang Completed |
| tmAdditionalCost | Additional cost: Php {amount} | Karagdagang cost: Php {amount} |
| tmReject | Reject | I-reject |
| tmApprove | Approve | I-approve |
| tmRating | Rating | Rating |
| tmCompletedJobs | Completed jobs | Natapos na jobs |
| tmVehicle | Vehicle | Vehicle |

## Payment screen

| Key | English | Proposed Taglish |
|-----|---------|------------------|
| tmPayForService | Pay for Service | Magbayad para sa Service |
| tmAmountDue | Amount due | Halagang babayaran |
| tmFastMobileWallet | Fast mobile wallet payment | Mabilis na mobile wallet payment |
| tmRecordSettlement | Record settlement after direct payment | I-record ang settlement pagkatapos ng direktang payment |
| tmPayNow | Pay Now | Magbayad Ngayon |

## Invoice screen

| Key | English | Proposed Taglish |
|-----|---------|------------------|
| tmFinalInvoice | Final Invoice | Final Invoice |
| tmBaseLaborFee | Base labor fee | Base labor fee |
| tmApprovedHardwareLabel | Approved hardware | Inaprubahang hardware |
| tmTotalDue | Total due | Kabuuang babayaran |
| tmFinalAmountReflects | Your final amount reflects the labor fee plus any hardware you approved during the active job. | Sinasalamin ng final amount mo ang labor fee kasama ang anumang hardware na inaprubahan mo sa active job. |

## Rating screen

| Key | English | Proposed Taglish |
|-----|---------|------------------|
| tmRateYourService | Rate your service | I-rate ang service mo |
| tmHowWasExperience | How was the time-material service experience with {name}? | Kamusta ang time-material service experience mo kay {name}? |
| tmHowWasExperienceNoName | How was your time-material service experience? | Kamusta naman ang time-material service experience mo? |
| tmSubmitRating | Submit Rating | I-submit ang Rating |

## Controller toasts / errors

| Key | English | Proposed Taglish |
|-----|---------|------------------|
| tmErrorApproveHardware | Could not approve the hardware request right now. | Hindi ma-approve ang hardware request ngayon. |
| tmErrorRejectHardware | Could not reject the hardware request right now. | Hindi ma-reject ang hardware request ngayon. |
| tmErrorMarkComplete | Could not mark the job complete right now. | Hindi ma-markahan bilang Completed ang job ngayon. |
| tmErrorMissingBookingRef | Missing booking reference for this payment. | Kulang ang booking reference para sa payment na ito. |
| tmErrorPaymentFailed | Payment could not be processed right now. | Hindi maproseso ang payment ngayon. |
| tmErrorMissingRatingRef | Missing provider or booking reference for rating. | Kulang ang provider o booking reference para sa rating. |
| tmErrorSubmitRating | Could not submit your rating right now. | Hindi ma-submit ang rating mo ngayon. |
| tmErrorCancelSearch | Could not cancel the search right now. | Hindi ma-cancel ang search ngayon. |

## Catalog subcategory subtitles (titles stay English)

| Key | English (subtitle) | Proposed Taglish |
|-----|--------------------|------------------|
| tmCatHomeLockout | Door unlocking, basic lock access, and urgent entry help. | Pagbubukas ng pinto, basic lock access, at agarang tulong para makapasok. |
| tmCatLockRepair | Minor repairs, stuck cylinders, and latch adjustments. | Minor lock repair, stuck cylinders, at pag-adjust ng latch. |
| tmCatLockReplacement | Replace damaged locks. Hardware cost may be added later. | Pagpapalit ng sirang lock. Maaaring idagdag ang hardware cost mamaya. |
| tmCatPipeLeak | Urgent leak isolation, sealing, and connector replacement. | Agarang pag-isolate ng leak, pag-seal, at pagpapalit ng connector. |
| tmCatFaucetIssue | Loose fittings, weak flow, and valve troubleshooting. | Maluwag na fittings, mahinang tulo ng tubig, at pag-troubleshoot ng valve. |
| tmCatDrainClog | Sink, bathroom, and floor drain unclogging support. | Pagtanggal ng bara sa sink, banyo, at floor drain. |
| tmCatOutletIssue | Fault isolation, rewiring checks, and safe restoration. | Pag-isolate ng sira, rewiring checks, at ligtas na pag-ayos. |
| tmCatBreakerTrip | Short circuit diagnostics and load troubleshooting. | Short circuit diagnostics at pag-troubleshoot ng electrical load. |
| tmCatLighting | Fixture checks, ballast replacement, and rewiring. | Pagsusuri ng fixtures, pagpapalit ng ballast, at rewiring. |
| tmCatWasherDryer | Diagnostics, disassembly, and repair recommendations. | Diagnostics, disassembly, at mga rekomendasyon sa pag-repair. |
| tmCatRefrigerator | Cooling, leakage, or electrical troubleshooting visit. | Pagbisita para sa cooling, leak, o electrical troubleshooting. |
| tmCatSmallAppliance | Inspection and repair of common home appliances. | Inspeksyon at pag-repair ng mga karaniwang home appliances. |
| tmCatQuickRepair | Fast troubleshooting and basic repair support. | Mabilis na troubleshooting at basic repair support. |
| tmCatDiagnostic | Problem isolation before labor and materials are finalized. | Pag-isolate ng problema bago i-finalize ang labor at materials. |
| tmCatUrgentAssistance | Immediate help for time-sensitive home service issues. | Agarang tulong para sa mga urgent na problema sa home service. |

## Notes
- `TMDispatchStatusPill` / dispatch chips (`Server dispatch`, `Fallback dispatch`, `Dispatch pending`, `Dispatch path: ...`) kept English (internal wire/enum status; excluded per D3).
- Tabs `Map` / `Chat` / `Provider` kept English (approved).
- Mock chat messages excluded (D3).
- Payment/brand names (GCash, Visa, Mastercard, Cash on Completion) kept English (D3).
- Third toggle = keyboard D2 wiring (test/extra) left unchanged.
- Rating fallback split: `tmHowWasExperience(name)` uses `kay {name}` when a provider name exists; `tmHowWasExperienceNoName` used when there's no name (avoids the awkward `kay iyong provider`).
