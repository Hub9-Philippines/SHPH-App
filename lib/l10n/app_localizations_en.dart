// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Serbisyo';

  @override
  String get settings => 'Settings';

  @override
  String get settingsSubtitle =>
      'Manage preferences, account, and support options.';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Choose the language used across the app';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle =>
      'Review booking, message, and payment updates';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeSubtitle => 'Switch between light and dark appearance';

  @override
  String get account => 'Account';

  @override
  String get security => 'Security';

  @override
  String get securitySubtitle => 'Password, login activity, and 2FA settings';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get editProfileSubtitle => 'Update your personal information';

  @override
  String get support => 'Support';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get sendFeedbackSubtitle =>
      'Open an email draft to share product feedback';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsOfServiceSubtitle => 'Read our terms and conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'Read our privacy policy';

  @override
  String get logOut => 'Log Out';

  @override
  String get logOutTitle => 'Log out';

  @override
  String get logOutConfirm => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get logOutAction => 'Log out';

  @override
  String get currentLanguage => 'Current language';

  @override
  String get chooseLanguage =>
      'Choose the preferred language for your app experience.';

  @override
  String get notificationsPageTitle => 'Notifications';

  @override
  String get notificationsPageSubtitle =>
      'Updates about bookings, messages, and payments.';

  @override
  String get errorLoadingNotifications => 'Error loading notifications';

  @override
  String get errorLoadingSubtitle =>
      'Something went wrong while fetching your updates.';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noNotificationsSubtitle => 'You are all caught up right now.';

  @override
  String get justNow => 'Just now';

  @override
  String get securityPageTitle => 'Security';

  @override
  String get securityPageSubtitle =>
      'Protect your account, password, and sign-in access.';

  @override
  String get password => 'Password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get enterCurrentPassword => 'Enter current password';

  @override
  String get newPassword => 'New password';

  @override
  String get enterNewPassword => 'Enter new password';

  @override
  String get confirmPassword => 'Confirm new password';

  @override
  String get reEnterPassword => 'Re-enter your new password';

  @override
  String get changePassword => 'Change Password';

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String get errorChangingPassword => 'Error changing password: ';

  @override
  String get currentPasswordRequired => 'Current password is required';

  @override
  String get newPasswordRequired => 'New password is required';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get twoFactorAuth => 'Two-Factor Authentication';

  @override
  String get secureYourLogin => 'Secure your login';

  @override
  String get secureYourLoginSubtitle =>
      'Use an authenticator app to add a second step during sign in.';

  @override
  String get setup2FA => 'Setup 2FA';

  @override
  String get scanQRCode =>
      'Scan this QR code with your authenticator app, then enter the 6-digit code to finish setup.';

  @override
  String get verificationCode => 'Verification code';

  @override
  String get verifyAndEnable => 'Verify & Enable';

  @override
  String get enterCode => 'Please enter the verification code';

  @override
  String get invalidCode => 'Invalid verification code: ';

  @override
  String get twoFAEnabled => '2FA enabled successfully';

  @override
  String get twoFADisabled => '2FA disabled successfully';

  @override
  String get errorEnrolling2FA => 'Error enrolling 2FA: ';

  @override
  String get loginActivity => 'Login Activity';

  @override
  String get currentDevice => 'Current device';

  @override
  String get otherSignIn => 'Other sign-in';

  @override
  String get activeNow => 'Active now';

  @override
  String get lastActive => 'Last active ';

  @override
  String get noSessions =>
      'No active sessions were returned for this account yet.';

  @override
  String get keepAccountProtected => 'Keep your account protected';

  @override
  String get keepAccountProtectedSubtitle =>
      'Manage password strength, 2FA, and recent account access in one place.';

  @override
  String get providerInbox => 'Provider inbox';

  @override
  String get pendingRequests => 'pending request';

  @override
  String get pendingRequests_plural => 'pending requests';

  @override
  String get newServiceRequests =>
      'New service requests will appear here as soon as customers book you.';

  @override
  String get quickReplies =>
      'Quick replies help you convert more requests into confirmed jobs.';

  @override
  String get dispatchMatch => 'Dispatch match';

  @override
  String get newOffer => 'New offer available';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get offerAccepted => 'Offer accepted — job confirmed';

  @override
  String get offerDeclined => 'Offer declined';

  @override
  String get acceptFailed => 'Failed to accept offer';

  @override
  String get declineFailed => 'Failed to decline offer';

  @override
  String get dispatchUnavailable => 'Dispatch unavailable';

  @override
  String get couldNotLoadRequests => 'Could not load requests';

  @override
  String get retry => 'Try Again';

  @override
  String get noJobRequests => 'No job requests yet';

  @override
  String get noJobRequestsSubtitle =>
      'When a client books one of your services, the request will appear here for review.';

  @override
  String get jobAccepted => 'Job accepted successfully';

  @override
  String get jobDeclined => 'Job declined';

  @override
  String get acceptJobFailed => 'Failed to accept job';

  @override
  String get declineJobFailed => 'Failed to decline job';

  @override
  String get jobRequests => 'Job Requests';

  @override
  String get jobRequestsSubtitle =>
      'Review and respond to new customer bookings fast.';

  @override
  String get timeMaterial => 'TIME-MATERIAL';

  @override
  String get scheduled => 'SCHEDULED';

  @override
  String get controlYourExperience => 'Control your app experience';

  @override
  String get controlYourExperienceSubtitle =>
      'Appearance, security, notifications, and support all live here.';

  @override
  String get completionTitle => 'Almost done!';

  @override
  String get completionSubtitle =>
      'Tell the Serbisyo team what to call you. You can add a photo and bio — or skip straight home.';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get firstNamePlaceholder => 'What should we call you?';

  @override
  String get lastNamePlaceholder => 'Your family name';

  @override
  String get bioOptionalLabel => 'Bio (optional)';

  @override
  String get bioPlaceholder => 'Tell clients a bit about yourself…';

  @override
  String progressComplete(Object percent) {
    return '$percent% complete';
  }

  @override
  String get finish => 'Finish';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get saveProfileFailed =>
      'Could not save your profile. Please try again.';

  @override
  String get completeYourProfile => 'Complete your profile';

  @override
  String get verifyNow => 'Verify now';

  @override
  String get chooseYourLanguage => 'Choose your language';

  @override
  String get chooseYourLanguageSubtitle =>
      'This language is used across the app.';

  @override
  String get kycIntroTitle => 'Verify your identity';

  @override
  String get kycIntroSubtitle =>
      'Help us keep Serbisyo safe. You\'ll need a valid government ID and a live selfie.';

  @override
  String get kycStartVerification => 'Start verification';

  @override
  String get kycWhatYouNeed => 'What you\'ll need:';

  @override
  String get kycMinutesLabel => 'Takes only a few minutes';

  @override
  String get kycIdFrontLabel => 'ID front';

  @override
  String get kycIdBackLabel => 'ID back';

  @override
  String get kycSelfieLabel => 'Selfie';

  @override
  String get kycCapture => 'Capture';

  @override
  String get kycRetake => 'Retake';

  @override
  String get kycContinue => 'Continue';

  @override
  String get kycLivenessTitle => 'Face verification';

  @override
  String get kycLivenessSubtitle =>
      'Center your face in the frame and follow the instructions.';

  @override
  String get kycSubmitNow => 'Submit & finish';

  @override
  String get kycSubmissionPending =>
      'Verification submitted. We\'ll review it shortly.';

  @override
  String get kycSkipError => 'Could not skip verification. Please try again.';

  @override
  String get kycSubmitError =>
      'Could not submit verification. Please try again.';

  @override
  String get kycPlanCenter => 'Center your face in the frame';

  @override
  String get kycPlanBlink => 'Blink slowly a few times';

  @override
  String get kycPlanSmile => 'Smile at the camera';

  @override
  String get kycVerification => 'KYC Verification';

  @override
  String get verificationNotStarted => 'Not started';

  @override
  String get verificationInProgress => 'In progress';

  @override
  String get verificationActionRequired => 'Action required';

  @override
  String get bfAddToCalendar => 'Add to Calendar';

  @override
  String get bfAdjustBooking => 'Adjust booking';

  @override
  String get bfAsQuotedAtCheckout => 'As quoted at checkout';

  @override
  String get bfAssignedProvider => 'Assigned provider';

  @override
  String get bfBackHome => 'Back home';

  @override
  String get bfBackToHome => 'Back to Home';

  @override
  String get bfBaseService => 'Base service';

  @override
  String get bfBookingDate => 'Booking date';

  @override
  String get bfBookingId => 'Booking ID';

  @override
  String get bfBookingSummary => 'Booking summary';

  @override
  String get bfBroadcastingRequest => 'Broadcasting request';

  @override
  String get bfCancelMatching => 'Cancel matching';

  @override
  String get bfCancelSearch => 'Cancel search';

  @override
  String get bfCheckingAvailability => 'Checking availability';

  @override
  String get bfChooseAService => 'Choose a service';

  @override
  String get bfChooseAnyFutureSlot => 'Choose any future slot';

  @override
  String get bfChooseTiming => 'Choose timing';

  @override
  String get bfCleaningType => 'Cleaning type';

  @override
  String get bfConfirmReserveSlot => 'Confirm & Reserve Slot';

  @override
  String get bfConfirmServiceLocation => 'Confirm service location';

  @override
  String get bfContinueSearch => 'Continue search';

  @override
  String get bfContinueToCheckout => 'Continue to checkout';

  @override
  String get bfContinueToSetup => 'Continue to setup';

  @override
  String get bfDateAndTime => 'Date & Time';

  @override
  String get bfDeepClean => 'Deep clean';

  @override
  String get bfDeepCleanUpgrade => 'Deep clean upgrade';

  @override
  String get bfDispatchMode => 'Dispatch mode';

  @override
  String get bfEditPin => 'Edit pin';

  @override
  String get bfEnRoute => 'En Route';

  @override
  String get bfEstimatedTotal => 'Estimated total';

  @override
  String get bfExpressArrival => 'Express arrival';

  @override
  String get bfFinalNearbySweep => 'Final nearby sweep';

  @override
  String get bfFinalizeJobSetup => 'Finalize the job setup';

  @override
  String get bfFindActiveCleanerNow => 'Find Active Cleaner Now';

  @override
  String get bfFindActiveProviderNow => 'Find Active Provider Now';

  @override
  String get bfFindAnotherProvider => 'Find Another Provider';

  @override
  String get bfFindingNearestProvider => 'Finding the nearest provider';

  @override
  String get bfHeadingToLocation => 'Heading to your location';

  @override
  String get bfInProgress => 'In Progress';

  @override
  String get bfInstantMatching => 'Instant matching';

  @override
  String get bfInstantProviderSearch => 'Instant provider search';

  @override
  String get bfLaterToday => 'Later today';

  @override
  String get bfLiveEstimate => 'Live estimate';

  @override
  String get bfAutoMatchingOn => 'Auto-Matching On';

  @override
  String get bfScanningForProviders => 'Scanning for providers';

  @override
  String get bfLocationLoading => 'Location loading...';

  @override
  String get bfMatchingFlow => 'Matching flow';

  @override
  String get bfBroadcastFailedTitle => 'Live matching unavailable';

  @override
  String get bfBroadcastFailedBody =>
      'We couldn\'t reach the dispatch service, so this is a preview. Your booking is saved — retry from your bookings or contact support.';

  @override
  String get bfNearestAvailableProvider => 'Nearest available provider';

  @override
  String get bfOnSite => 'On Site';

  @override
  String get bfPaymentMethod => 'Payment method';

  @override
  String get bfPendingAssignment => 'Pending assignment';

  @override
  String get bfPickAService => 'Pick a service';

  @override
  String get bfPickSpecificTime => 'Pick a specific time';

  @override
  String get bfPinnedLocation => 'Pinned location';

  @override
  String get bfPremiumClean => 'Premium clean';

  @override
  String get bfPremiumMaterials => 'Premium materials';

  @override
  String get bfProviderAssigned => 'Provider assigned';

  @override
  String get bfProviderAssignment => 'Provider assignment';

  @override
  String get bfProviderEnRoute => 'Provider En Route';

  @override
  String get bfProviderFound => 'Provider found';

  @override
  String get bfProviderAcceptedBooking => 'Provider has accepted your booking';

  @override
  String get bfProviderArrived => 'Provider has arrived at your location';

  @override
  String get bfProviderWorking => 'Provider is working on your request';

  @override
  String get bfProviderMatchingNow => 'Provider matching now';

  @override
  String get bfQuickBook => 'Quick book';

  @override
  String get bfRequireArrivalCode => 'Require Arrival Code';

  @override
  String get bfReturnToLiveMatching => 'Return to live matching';

  @override
  String get bfReviewLiveRequest => 'Review live request';

  @override
  String get bfReviewScheduledBooking => 'Review scheduled booking';

  @override
  String get bfRightNow => 'Right now';

  @override
  String get bfRushFactor => 'Rush factor';

  @override
  String get bfScheduleAnotherDay => 'Schedule Another Day';

  @override
  String get bfScheduledDateTime => 'Scheduled date & time';

  @override
  String get bfScheduledProviderReservation => 'Scheduled provider reservation';

  @override
  String get bfScheduledReservation => 'Scheduled reservation';

  @override
  String get bfSearchReference => 'Search reference';

  @override
  String get bfSearchingNearbyProviders => 'Searching nearby providers';

  @override
  String get bfSelectATime => 'Select a time';

  @override
  String get bfSelectedService => 'Selected service';

  @override
  String get bfServiceCompleted => 'Service has been completed';

  @override
  String get bfServiceInProgress => 'Service In Progress';

  @override
  String get bfServiceLevel => 'Service level';

  @override
  String get bfServiceLocation => 'Service location';

  @override
  String get bfServiceProvider => 'Service Provider';

  @override
  String get bfServiceRequest => 'Service request';

  @override
  String get bfServiceSetup => 'Service setup';

  @override
  String get bfServiceSummary => 'Service summary';

  @override
  String get bfStandardClean => 'Standard clean';

  @override
  String get bfToBeAssigned => 'To be assigned';

  @override
  String get bfTotalAmount => 'Total Amount';

  @override
  String get bfTrackMyBooking => 'Track My Booking';

  @override
  String get bfViewBookings => 'View Bookings';

  @override
  String get bfViewInvoice => 'View Invoice';

  @override
  String get bfViewStatus => 'View Status';

  @override
  String get bfWriteAReview => 'Write a Review';

  @override
  String get bfSlotConfirmSoon => 'Your slot will be confirmed shortly';

  @override
  String get bfYourCurrentLocation => 'Your Current Location';

  @override
  String get bfPleaseChooseService =>
      'Please choose a service before continuing.';

  @override
  String get bfNoProvidersNearby =>
      'No providers available within 10 km of your location. Try expanding your search area or scheduling for later.';

  @override
  String get bfProviderPrepTime =>
      'Our closest professional needs at least 2 hours to prepare and travel to your location. Please adjust your time selection.';

  @override
  String get bfCouldNotReserve => 'Could not reserve. Please try again.';

  @override
  String get bfCouldNotStartLiveMatching =>
      'Could not start live matching. Please try again.';

  @override
  String get bfCouldNotReserveSlot =>
      'Could not reserve the slot. Please try again.';

  @override
  String get bfInviteCopied => 'Invite link copied — share it with friends!';

  @override
  String get bfCouldNotOpenCalendar => 'Could not open your calendar app.';

  @override
  String get bfTrackingAfterAccept =>
      'Tracking will be available once a provider accepts.';

  @override
  String get bfReviewAfterSync =>
      'Review will be available once this booking is synced.';

  @override
  String get bfInvoiceSoon => 'Your invoice will be available shortly.';

  @override
  String get bfCancelProviderSearchQ => 'Cancel provider search?';

  @override
  String get bfCancelSearchBody =>
      'Your current search is still running. If you cancel now, you can adjust the booking details and try again.';

  @override
  String get bfFindAnotherProviderQ => 'Find another provider?';

  @override
  String get bfCancelBookingQ =>
      'Are you sure you want to cancel this booking and search for another provider?';

  @override
  String get bfYesCancel => 'Yes, Cancel';

  @override
  String get bfNo => 'No';

  @override
  String get bfArrivalCodeInfo =>
      'Your provider must read you a one-time arrival code before starting work — protecting you from premature or unauthorized starts.';

  @override
  String get bfBookingConfirmedExclaim => 'Booking Confirmed!';

  @override
  String get bfRequestInBody =>
      'Your request is in. We\'ll notify you the moment a provider accepts — no follow-up needed.';

  @override
  String get bfConfirmSlotSoon => 'You will confirm a slot shortly';

  @override
  String get bfConfirmRightPlace =>
      'Make sure the provider is headed to the right place before choosing the time.';

  @override
  String get bfDropOffPoint => 'Drop-off point';

  @override
  String bfWhenNeedService(Object serviceTitle) {
    return 'When do you need $serviceTitle?';
  }

  @override
  String get bfPickDispatchSpeed =>
      'Pick the dispatch speed that fits this request best.';

  @override
  String get bfTapServiceConfigure =>
      'Tap any service to instantly configure your booking.';

  @override
  String get bfCouldNotLoadServices =>
      'Could not load services. Pull down to retry.';

  @override
  String get bfSearchAllServices => 'Search all services →';

  @override
  String bfHeroCategoryReady(Object category) {
    return '$category service ready. Pick the time, then we\'ll route it fast.';
  }

  @override
  String get bfHeroFastDispatch =>
      'Fast dispatch. Zero friction. Pick the service, then the time.';

  @override
  String get bfAdjustScope =>
      'Adjust the scope in seconds. Pricing updates live as you change settings.';

  @override
  String get bfConfirmCheckoutBody =>
      'Confirm the slot, pinned address, and payment before we reserve it.';

  @override
  String get bfConfirmSearchBody =>
      'Confirm the pinned address and payment before we start searching nearby providers.';

  @override
  String get bfLockInSlot =>
      'We will lock in your selected slot and keep this pinned location for the visit.';

  @override
  String get bfSearchSavedPin =>
      'We will search nearby providers around this saved pin as soon as you continue.';

  @override
  String get bfLiveMatchingActive => 'Live matching active';

  @override
  String get bfAlertingNearbyProviders =>
      'Alerting nearby active providers around your pin.';

  @override
  String get bfComparingWhoReaches =>
      'Comparing who can reach you the fastest.';

  @override
  String get bfFinalPass =>
      'Running one last pass before the request times out.';

  @override
  String bfNameOnWay(Object name) {
    return '$name is on the way to your location.';
  }

  @override
  String get bfStayOnScreen =>
      'Stay on this screen while we look for the closest available professional.';

  @override
  String get bfSearching => 'Searching';

  @override
  String bfSecondsRemaining(Object seconds) {
    return '${seconds}s';
  }

  @override
  String get bfProvidersNotified => 'Providers notified';

  @override
  String get bfProviderCountOne => '1 provider';

  @override
  String bfProviderCountMany(Object count) {
    return '$count providers';
  }

  @override
  String get bfEstimatedFee => 'Estimated fee';

  @override
  String bfFeeRange(Object min, Object max) {
    return 'PHP $min - $max';
  }

  @override
  String bfJobsCount(Object count) {
    return '$count jobs';
  }

  @override
  String bfMinutesShort(Object minutes) {
    return '$minutes min';
  }

  @override
  String get bfProAssigned =>
      'A professional has been assigned to your request.';

  @override
  String get bfProvidersBusy => 'Providers are busy, try again';

  @override
  String get bfAdjustOrGoHome =>
      'You can adjust the booking details and retry, or head back home for now.';

  @override
  String bfHeadingTo(Object locationLabel) {
    return 'Heading to $locationLabel';
  }

  @override
  String get bfNoRouteFound => 'No route found. Showing direct path.';

  @override
  String get bfRouteUnavailable => 'Route unavailable. Showing direct path.';

  @override
  String bfBookingStatusText(Object status) {
    return 'This booking has been $status.';
  }

  @override
  String bfApproxEta(Object eta) {
    return 'Approximately $eta';
  }

  @override
  String bfStepOf(Object currentStep) {
    return 'Step $currentStep of 3';
  }

  @override
  String bfStepOfCount(Object currentStep, Object totalSteps) {
    return 'Step $currentStep of $totalSteps';
  }

  @override
  String get bfDetails => 'Details';

  @override
  String get bfReview => 'Review';

  @override
  String get bfRetry => 'Retry';

  @override
  String get bfEstimateUnavailable =>
      'Couldn\'t load the price estimate. Your draft is saved - retry or go back.';

  @override
  String get bfServices => 'Services';

  @override
  String get bfLocation => 'Location';

  @override
  String get bfPayment => 'Payment';

  @override
  String get bfTime => 'Time';

  @override
  String get bfSetup => 'Setup';

  @override
  String get bfScope => 'Scope';

  @override
  String get bfQuantity => 'Quantity';

  @override
  String get bfRooms => 'Rooms';

  @override
  String get bfItems => 'Items';

  @override
  String get bfService => 'Service';

  @override
  String get bfDispatch => 'Dispatch';

  @override
  String get bfFastest => 'FASTEST';

  @override
  String get bfChange => 'CHANGE';

  @override
  String get bfLandmarks => 'Landmarks';

  @override
  String get bfLandmarksPlaceholder =>
      'Bldg / Room No., Floor or Landmarks (Optional)';

  @override
  String get bfEta => 'ETA';

  @override
  String get bfDistance => 'Distance';

  @override
  String get bfRoute => 'Route';

  @override
  String get bfReference => 'Reference';

  @override
  String get bfDigital => 'Digital';

  @override
  String get bfCash => 'Cash';

  @override
  String get bfTotal => 'Total';

  @override
  String get bfAssigned => 'Assigned';

  @override
  String get bfScheduled => 'Scheduled';

  @override
  String get bfTotalPriceDue => 'Total Price Due:';

  @override
  String get bfNow => 'Now';

  @override
  String get bfAsapFindingProvider => 'ASAP - Finding nearest provider';

  @override
  String get bfInstantDispatch => 'Instant dispatch';

  @override
  String get bfRightNowTitle => 'Right Now';

  @override
  String get bfLaterTodayTitle => 'Later Today';

  @override
  String get bfBookNow => 'Book Now →';

  @override
  String get bfContinue => 'Continue';

  @override
  String get bfProfessional => 'Professional';

  @override
  String get bfProvider => 'Provider';

  @override
  String get bfHome => 'Home';

  @override
  String get bfStatusConfirmed => 'Confirmed';

  @override
  String get bfStatusCompleted => 'Completed';

  @override
  String get bfStatusCancelled => 'Cancelled';

  @override
  String get bfBookingConfirmed => 'Booking Confirmed';

  @override
  String get bfBookingCancelled => 'Booking Cancelled';

  @override
  String get bfConfirmationPending => 'Confirmation Pending';

  @override
  String get bfBack => 'Back';

  @override
  String get bfCall => 'Call';

  @override
  String get bfMessage => 'Message';

  @override
  String get bfLevelStandard => 'Standard';

  @override
  String get bfLevelDeep => 'Deep';

  @override
  String get bfLevelPremium => 'Premium';

  @override
  String get bfLevelBasic => 'Basic';

  @override
  String get bfLevelPriority => 'Priority';

  @override
  String get bfLevelExpress => 'Express';

  @override
  String get bfQuantityHintDefault => 'How many units or sessions do you need?';

  @override
  String get bfQuantityHintRooms => 'How many rooms do you want serviced?';

  @override
  String get bfQuantityHintItems =>
      'How many items or tasks should be covered?';

  @override
  String get bfProviderMustConfirmCode =>
      'Provider must confirm a one-time code to start.';

  @override
  String bfReviewsCount(Object rating, Object count) {
    return '$rating · $count reviews';
  }

  @override
  String get bfNewProvider => 'New';

  @override
  String bfBookCategoryNow(Object category) {
    return 'Book $category Now →';
  }

  @override
  String bfTodayAtTime(Object time) {
    return 'Today at $time';
  }

  @override
  String bfOnDateAtTime(Object month, Object day, Object time) {
    return '$month/$day at $time';
  }

  @override
  String bfAsapTodayAfter(Object time) {
    return 'ASAP today after $time';
  }

  @override
  String get tmChooseJobType => 'Choose a Job Type';

  @override
  String get tmTimeMaterialFlow => 'Time-Material flow';

  @override
  String get tmPickClosestJobType =>
      'Pick the closest job type so we can give a tighter estimate before searching for nearby providers.';

  @override
  String get tmEstimate => 'Estimate';

  @override
  String get tmEstimatedServiceFee => 'Estimated service fee';

  @override
  String get tmFinalChargesMayChange =>
      'Final charges may change depending on distance, job complexity, and hardware parts approved during the visit.';

  @override
  String get tmOnDemandDispatch => 'On-demand dispatch';

  @override
  String get tmSearchNearbyFirst =>
      'We will search for nearby providers first before falling back to a wider search radius.';

  @override
  String get tmTimePlusMaterials => 'Time + materials';

  @override
  String get tmLaborEstimatedUpfront =>
      'Labor is estimated up front. Hardware and parts can be added only if you approve them later.';

  @override
  String get tmFindProvider => 'Find Provider';

  @override
  String get tmExpandedRadiusSearch => 'Expanded radius search';

  @override
  String get tmNoProviderFoundYet => 'No provider found yet';

  @override
  String get tmSearchingNearbyProviders => 'Searching nearby providers';

  @override
  String get tmWidenedSearchRadius =>
      'We widened the search radius to reach more active providers.';

  @override
  String get tmNearbyExpandedTimedOut =>
      'Nearby and expanded searches both timed out.';

  @override
  String get tmBroadcastingRequest =>
      'Broadcasting your request to active providers near your pin.';

  @override
  String get tmTimedOut => 'Timed out';

  @override
  String get tmLookingForProvider => 'Looking for a provider';

  @override
  String get tmCouldNotSecureProvider =>
      'We could not secure a provider from the current search cycle.';

  @override
  String get tmStayOnScreen =>
      'Stay on this screen while we keep your request active and visible to nearby providers.';

  @override
  String get tmSearchRadius => 'Search radius';

  @override
  String get tmCurrentlyScanning =>
      'Currently scanning providers within 4-8 km of your pin depending on the current search phase.';

  @override
  String get tmDynamicFees => 'Dynamic fees';

  @override
  String get tmExpandedMayIncreaseFee =>
      'Expanded searches may increase the service fee based on travel distance.';

  @override
  String get tmSearchReference => 'Search reference';

  @override
  String get tmCancelSearch => 'Cancel Search';

  @override
  String get tmNoProviderFound => 'No provider found';

  @override
  String get tmFinishedSearchWindows =>
      'We finished both search windows without a provider match. You can retry, switch to the scheduled flow, or head back home.';

  @override
  String get tmSearchAgain => 'Search again';

  @override
  String get tmScheduleInstead => 'Schedule instead';

  @override
  String get tmExpandingSearchNotice =>
      'Expanding Search... Service Fee may increase by 50-100 per km';

  @override
  String get tmActiveJob => 'Active Job';

  @override
  String tmAdditionalCost(Object amount) {
    return 'Additional cost: Php $amount';
  }

  @override
  String get tmReject => 'Reject';

  @override
  String get tmApprove => 'Approve';

  @override
  String get tmOnTheWay => 'On the way';

  @override
  String get tmLiveJobTracking => 'Live job tracking';

  @override
  String tmHeadingToLocation(Object name) {
    return '$name is heading to your location. If additional hardware is needed, you will see an approval prompt here.';
  }

  @override
  String tmApprovedHardware(Object amount) {
    return 'Approved hardware: Php $amount';
  }

  @override
  String get tmMarkJobComplete => 'Mark Job Complete';

  @override
  String get tmRating => 'Rating';

  @override
  String get tmCompletedJobs => 'Completed jobs';

  @override
  String get tmVehicle => 'Vehicle';

  @override
  String get tmPayForService => 'Pay for Service';

  @override
  String get tmAmountDue => 'Amount due';

  @override
  String get tmFastMobileWallet => 'Fast mobile wallet payment';

  @override
  String get tmRecordSettlement => 'Record settlement after direct payment';

  @override
  String get tmPayNow => 'Pay Now';

  @override
  String get tmRateYourService => 'Rate your service';

  @override
  String tmHowWasExperience(Object name) {
    return 'How was the time-material service experience with $name?';
  }

  @override
  String get tmSubmitRating => 'Submit Rating';

  @override
  String get tmHowWasExperienceNoName =>
      'How was your time-material service experience?';

  @override
  String get tmFinalInvoice => 'Final Invoice';

  @override
  String get tmBaseLaborFee => 'Base labor fee';

  @override
  String get tmApprovedHardwareLabel => 'Approved hardware';

  @override
  String get tmTotalDue => 'Total due';

  @override
  String get tmFinalAmountReflects =>
      'Your final amount reflects the labor fee plus any hardware you approved during the active job.';

  @override
  String get tmErrorApproveHardware =>
      'Could not approve the hardware request right now.';

  @override
  String get tmErrorRejectHardware =>
      'Could not reject the hardware request right now.';

  @override
  String get tmErrorMarkComplete =>
      'Could not mark the job complete right now.';

  @override
  String get tmErrorMissingBookingRef =>
      'Missing booking reference for this payment.';

  @override
  String get tmErrorPaymentFailed =>
      'Payment could not be processed right now.';

  @override
  String get tmErrorMissingRatingRef =>
      'Missing provider or booking reference for rating.';

  @override
  String get tmErrorSubmitRating => 'Could not submit your rating right now.';

  @override
  String get tmErrorCancelSearch => 'Could not cancel the search right now.';

  @override
  String get tmCatHomeLockout =>
      'Door unlocking, basic lock access, and urgent entry help.';

  @override
  String get tmCatLockRepair =>
      'Minor repairs, stuck cylinders, and latch adjustments.';

  @override
  String get tmCatLockReplacement =>
      'Replace damaged locks. Hardware cost may be added later.';

  @override
  String get tmCatPipeLeak =>
      'Urgent leak isolation, sealing, and connector replacement.';

  @override
  String get tmCatFaucetIssue =>
      'Loose fittings, weak flow, and valve troubleshooting.';

  @override
  String get tmCatDrainClog =>
      'Sink, bathroom, and floor drain unclogging support.';

  @override
  String get tmCatOutletIssue =>
      'Fault isolation, rewiring checks, and safe restoration.';

  @override
  String get tmCatBreakerTrip =>
      'Short circuit diagnostics and load troubleshooting.';

  @override
  String get tmCatLighting =>
      'Fixture checks, ballast replacement, and rewiring.';

  @override
  String get tmCatWasherDryer =>
      'Diagnostics, disassembly, and repair recommendations.';

  @override
  String get tmCatRefrigerator =>
      'Cooling, leakage, or electrical troubleshooting visit.';

  @override
  String get tmCatSmallAppliance =>
      'Inspection and repair of common home appliances.';

  @override
  String get tmCatQuickRepair =>
      'Fast troubleshooting and basic repair support.';

  @override
  String get tmCatDiagnostic =>
      'Problem isolation before labor and materials are finalized.';

  @override
  String get tmCatUrgentAssistance =>
      'Immediate help for time-sensitive home service issues.';

  @override
  String get afEditAddress => 'Edit address';

  @override
  String get afNewAddress => 'New address';

  @override
  String get afContactInformation => 'Contact Information';

  @override
  String get afAddressDetails => 'Address Details';

  @override
  String get afPinLocation => 'Pin Location';

  @override
  String get afLabel => 'Label';

  @override
  String get afFullName => 'Full name';

  @override
  String get afEnterFullName => 'Enter your full name';

  @override
  String get afMobileNumber => 'Mobile number';

  @override
  String get afStreetAddress => 'Street address';

  @override
  String get afHouseUnitStreet => 'House/Unit number, Street name';

  @override
  String get afPostalCode => 'Postal code';

  @override
  String get afEnterPostalCode => 'Enter postal code';

  @override
  String get afSearchBarangay => 'Search barangay...';

  @override
  String get afErrorFullName => 'Please enter your full name';

  @override
  String get afErrorMobileNumber => 'Please enter your mobile number';

  @override
  String get afErrorValidMobile => 'Please enter a valid mobile number';

  @override
  String get afErrorStreetAddress => 'Please enter your street address';

  @override
  String get afRegion => 'Region';

  @override
  String get afSelectRegion => 'Select region';

  @override
  String get afProvince => 'Province';

  @override
  String get afSelectProvince => 'Select province';

  @override
  String get afCityMunicipality => 'City/Municipality';

  @override
  String get afSelectCity => 'Select city/municipality';

  @override
  String get afBarangay => 'Barangay';

  @override
  String get afSelectBarangay => 'Select barangay';

  @override
  String get afSelectBarangayTitle => 'Select Barangay';

  @override
  String get afNoBarangays =>
      'No barangays available for this city/municipality';

  @override
  String get afNoBarangaysFound => 'No barangays found';

  @override
  String get afSetAsDefault => 'Set as default address';

  @override
  String get afUpdateAddress => 'Update address';

  @override
  String get afSaveAddress => 'Save address';

  @override
  String get afPinLocationOnMap => 'Pin location on map (optional)';

  @override
  String get afChange => 'Change';

  @override
  String get afAddressUpdated => 'Address updated successfully';

  @override
  String get afAddressAdded => 'Address added successfully';

  @override
  String get afAddressDeleted => 'Address deleted successfully';

  @override
  String get afErrorSavingAddress => 'Error saving address';

  @override
  String afErrorSavingAddressDetail(Object e) {
    return 'Error saving address: $e';
  }

  @override
  String afErrorLoadingAddress(Object e) {
    return 'Error loading address: $e';
  }

  @override
  String afErrorDeletingAddress(Object e) {
    return 'Error deleting address: $e';
  }

  @override
  String get afDeleteAddress => 'Delete address';

  @override
  String get afDeleteConfirm => 'Are you sure you want to delete this address?';

  @override
  String get afCancel => 'Cancel';

  @override
  String get afDelete => 'Delete';

  @override
  String get bdBookingIdRequired => 'Booking ID is required';

  @override
  String get bdBookingNotFound => 'Booking not found';

  @override
  String bdFailedLoadBooking(Object e) {
    return 'Failed to load booking: $e';
  }

  @override
  String get bdCouldNotLoadBooking => 'Could not load booking';

  @override
  String get bdRetry => 'Retry';

  @override
  String get bdNoBookingData => 'No booking data';

  @override
  String get bdBookingUnavailable =>
      'This booking could not be found or is no longer available.';

  @override
  String get bdGoBack => 'Go back';

  @override
  String get bdCancelBooking => 'Cancel Booking';

  @override
  String get bdCancelConfirm => 'Are you sure you want to cancel this booking?';

  @override
  String get bdNo => 'No';

  @override
  String get bdYes => 'Yes';

  @override
  String get bdCancelledSuccessfully => 'Booking cancelled successfully';

  @override
  String get bdFailedCancelBooking => 'Failed to cancel booking';

  @override
  String get bdAssignedProvider => 'Assigned Provider';

  @override
  String get bdYourBooking => 'Your booking';

  @override
  String get bdNew => 'New';

  @override
  String get bdServiceProfessional => 'Service professional';

  @override
  String get bdCallProvider => 'Call provider';

  @override
  String get bdMessageProvider => 'Message provider';

  @override
  String get bdServiceProgress => 'Service progress';

  @override
  String get bdThisBookingCancelled => 'This booking was cancelled.';

  @override
  String get bdBookingPlaced => 'Booking placed';

  @override
  String get bdProviderConfirmed => 'Provider confirmed';

  @override
  String get bdArrivedOnSite => 'Arrived on site';

  @override
  String get bdServiceInProgress => 'Service in progress';

  @override
  String get bdCompleted => 'Completed';

  @override
  String get bdBookingInformation => 'Booking information';

  @override
  String get bdInfoSubtitle =>
      'Core scheduling, payment, and location details.';

  @override
  String get bdBookingId => 'Booking ID';

  @override
  String get bdDateAndTime => 'Date & Time';

  @override
  String get bdStatus => 'Status';

  @override
  String get bdPaymentStatus => 'Payment status';

  @override
  String get bdPending => 'Pending';

  @override
  String get bdServiceLocation => 'Service location';

  @override
  String get bdNotes => 'Notes';

  @override
  String get bdNotesSubtitle =>
      'Special instructions attached to this booking.';

  @override
  String get bdSharedAfterAssignment =>
      'Shared with your provider after assignment';

  @override
  String get bdBookingDetails => 'Booking Details';

  @override
  String get bdHeaderSubtitle =>
      'Review progress, schedule, and payment state.';

  @override
  String get bdTrackOnMap => 'Track on Map';

  @override
  String get bdUnknown => 'Unknown';

  @override
  String get bdConfirmed => 'Confirmed';

  @override
  String get bdInProgress => 'In Progress';

  @override
  String get bdCancelled => 'Cancelled';

  @override
  String get ssSecurity => 'Security';

  @override
  String get ssSubtitle =>
      'Protect your account, password, and sign-in access.';

  @override
  String get ssHeroTitle => 'Keep your account protected';

  @override
  String get ssHeroSubtitle =>
      'Manage password strength, 2FA, and recent account access in one place.';

  @override
  String get ssPassword => 'Password';

  @override
  String get ssCurrentPassword => 'Current password';

  @override
  String get ssEnterCurrentPassword => 'Enter current password';

  @override
  String get ssCurrentPasswordRequired => 'Current password is required';

  @override
  String get ssNewPassword => 'New password';

  @override
  String get ssEnterNewPassword => 'Enter new password';

  @override
  String get ssNewPasswordRequired => 'New password is required';

  @override
  String get ssPasswordMinLength => 'Password must be at least 8 characters';

  @override
  String get ssConfirmNewPassword => 'Confirm new password';

  @override
  String get ssReenterNewPassword => 'Re-enter your new password';

  @override
  String get ssConfirmPasswordRequired => 'Please confirm your password';

  @override
  String get ssPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get ssChangePassword => 'Change Password';

  @override
  String get ssPasswordResetSent =>
      'Password reset link sent to your email. Use it to set a new password.';

  @override
  String ssErrorPasswordReset(Object e) {
    return 'Error changing password: $e';
  }

  @override
  String get ssTwoFactorAuth => 'Two-Factor Authentication';

  @override
  String get ssSecureYourLogin => 'Secure your login';

  @override
  String get ssAuthenticatorApp =>
      'Use an authenticator app to add a second step during sign in.';

  @override
  String get ss2FAEnrollmentUnavailable =>
      '2FA enrollment is not available yet.';

  @override
  String get ss2FAManagementUnavailable =>
      '2FA management is not available yet.';

  @override
  String ssErrorEnrolling2FA(Object e) {
    return 'Error enrolling 2FA: $e';
  }

  @override
  String ssErrorDisabling2FA(Object e) {
    return 'Error disabling 2FA: $e';
  }

  @override
  String get ssLoginActivity => 'Login Activity';

  @override
  String get ssNoActiveSessions =>
      'No active sessions were returned for this account yet.';

  @override
  String get ssCurrentDevice => 'Current device';

  @override
  String get ssOtherSignIn => 'Other sign-in';

  @override
  String get ssActiveNow => 'Active now';

  @override
  String get ssUnknownDevice => 'Unknown device';

  @override
  String ssLastActive(Object time) {
    return 'Last active $time';
  }

  @override
  String get ssJustNow => 'Just now';

  @override
  String ssMinutesAgo(Object count) {
    return '$count minutes ago';
  }

  @override
  String ssHoursAgo(Object count) {
    return '$count hours ago';
  }

  @override
  String get ssYesterday => 'Yesterday';

  @override
  String ssDaysAgo(Object count) {
    return '$count days ago';
  }

  @override
  String get siWelcome => 'Welcome to Serbisyo';

  @override
  String get siWelcomeSubtitle =>
      'Sign in to continue with your home services.';

  @override
  String get siPhone => 'Phone';

  @override
  String get siEmail => 'Email';

  @override
  String get siMobileNumber => 'Mobile number';

  @override
  String get siPhoneNumberRequired =>
      'Phone Number is required and has to start with +.';

  @override
  String get siEmailAddress => 'Email address';

  @override
  String get siInvalidEmail => 'Invalid email';

  @override
  String get siPassword => 'Password';

  @override
  String get siEnterPassword => 'Enter your password';

  @override
  String get siInvalidEmailOrPassword => 'Invalid email or password';

  @override
  String get siSignIn => 'Sign In';

  @override
  String get siSigningIn => 'Signing In...';

  @override
  String get siForgotPassword => 'Forgot password';

  @override
  String get siNoAccountYet => 'Don\'t have an account yet?';

  @override
  String get siSignUp => 'Sign Up';

  @override
  String get siOrContinueWith => 'or continue with';

  @override
  String get siContinueWithGoogle => 'Continue with Google';

  @override
  String get siContinueWithApple => 'Continue with Apple';

  @override
  String get siGoogleComingSoon => 'Google sign-in coming soon';

  @override
  String get siAppleComingSoon => 'Apple sign-in coming soon';

  @override
  String get spHeaderTitle => 'Search';

  @override
  String get spHeaderSubtitle =>
      'Browse services with filters that actually help.';

  @override
  String get spSearchPlaceholder => 'Search for services...';

  @override
  String get spVoiceSearchNoResult =>
      'Didn\'t catch that. Try again or type your search.';

  @override
  String get spVoiceSearchUnavailable =>
      'Voice search isn\'t available on this device. Please type your search instead.';

  @override
  String get spEmptyTitle => 'Search for services';

  @override
  String get spEmptySubtitle =>
      'Try keywords like cleaning, painting, or plumbing.';

  @override
  String get spBrowseAllServices => 'Browse all services';

  @override
  String get spAllServices => 'All services';

  @override
  String get spCategory => 'Category';

  @override
  String get spAll => 'All';

  @override
  String get spMinRating => 'Minimum rating';

  @override
  String get spPrice => 'Price';

  @override
  String get spDefault => 'Default';

  @override
  String get spLowToHigh => 'Low to High';

  @override
  String get spHighToLow => 'High to Low';

  @override
  String get spResetFilters => 'Reset filters';

  @override
  String get spClearFilters => 'Clear filters';

  @override
  String get spRecentSearches => 'Recent searches';

  @override
  String get spRecentBookings => 'Recent bookings';

  @override
  String get spNoServicesFound => 'No services found';

  @override
  String get spNoResultsSubtitle =>
      'Try another keyword, open a broader category, or clear your filters.';

  @override
  String get spServiceFallback => 'Service';

  @override
  String get seTitle => 'Settings';

  @override
  String get seSubtitle => 'Manage preferences, account, and support options.';

  @override
  String get seHeroTitle => 'Control your app experience';

  @override
  String get seHeroSubtitle =>
      'Appearance, security, notifications, and support all live here.';

  @override
  String get seGeneralSection => 'General & Account Configuration';

  @override
  String get seLanguage => 'Language';

  @override
  String get seLanguageSubtitle => 'Choose the language used across the app';

  @override
  String get seNotifications => 'Notifications';

  @override
  String get seNotificationsSubtitle =>
      'Review booking, message, and payment updates';

  @override
  String get seSecurity => 'Security';

  @override
  String get seSecuritySubtitle =>
      'Password, login protection, and 2FA settings';

  @override
  String get seEditProfile => 'Edit profile';

  @override
  String get seEditProfileSubtitle =>
      'Update your personal registration information';

  @override
  String get seLegalSection => 'Legal & Feedback';

  @override
  String get seSendFeedback => 'Send feedback';

  @override
  String get seSendFeedbackSubtitle =>
      'Open an email draft to share product feedback';

  @override
  String get seTermsTitle => 'Terms of Service';

  @override
  String get seTermsSubtitle => 'Read the terms governing your use of Serbisyo';

  @override
  String get sePrivacyTitle => 'Privacy Policy';

  @override
  String get sePrivacySubtitle => 'Understand how we collect and use your data';

  @override
  String get seLogOut => 'Log out';

  @override
  String get seLogOutConfirm => 'Are you sure you want to log out?';

  @override
  String get seCancel => 'Cancel';

  @override
  String get seSignOutSubtitle => 'Sign out of your account on this device';

  @override
  String get seCouldNotLaunchUrl => 'Could not launch URL';

  @override
  String get thTitle => 'Appearance';

  @override
  String get thTheme => 'Theme';

  @override
  String get thLight => 'Light';

  @override
  String get thDark => 'Dark';

  @override
  String get thSystemDefault => 'System Default';

  @override
  String get thLightSubtitle => 'Always use light mode';

  @override
  String get thDarkSubtitle => 'Always use dark mode';

  @override
  String get thSystemSubtitle => 'Follow device settings';

  @override
  String get lgTitle => 'Language';

  @override
  String get lgSubtitle =>
      'Choose the preferred language for your app experience.';

  @override
  String get lgCurrent => 'Current language';

  @override
  String lgChanged(Object language) {
    return 'Language changed to $language';
  }

  @override
  String get npTitle => 'Notification Settings';

  @override
  String get npPush => 'Push Notifications';

  @override
  String get bpSelectPayment => 'Select Payment';

  @override
  String get bpSelectPaymentSubtitle =>
      'Review the booking and choose how you want to pay.';

  @override
  String get bpChooseHowToPay => 'Choose how you want to pay';

  @override
  String get bpEscrowSubtitle =>
      'Card, wallet, and QR payments are protected through escrow until the job is completed.';

  @override
  String get bpCard => 'Credit / Debit Card';

  @override
  String get bpCardSub => 'Visa, Mastercard';

  @override
  String get bpEwallet => 'E-Wallets';

  @override
  String get bpEwalletSub => 'GCash, Maya';

  @override
  String get bpQr => 'QR Ph Code';

  @override
  String get bpQrSub => 'Standard Philippine digital QR';

  @override
  String get bpCash => 'Cash on Completion';

  @override
  String get bpCashSub => 'Pay the pro directly after the job';

  @override
  String get bpSummaryTitle => 'Booking summary';

  @override
  String get bpDate => 'Date';

  @override
  String get bpTime => 'Time';

  @override
  String get bpNotes => 'Notes';

  @override
  String get bpNotSet => 'Not set';

  @override
  String get bpTotal => 'Total';

  @override
  String get bpProcessing => 'Processing...';

  @override
  String get bpConfirm => 'Confirm Payment';

  @override
  String get bpSelectMethod => 'Please select a payment method';

  @override
  String get bpEscrowNotice =>
      'Card, e-wallet, and QR payments are held in escrow. The provider receives the funds only after you confirm the work is done from your bookings page.';

  @override
  String get bpConfirmSlot => 'You will confirm a slot shortly';

  @override
  String get bpFailedCreate => 'Failed to create booking.';

  @override
  String get bpPaymentFailed => 'Payment failed';

  @override
  String get bsTitle => 'Booking Confirmed';

  @override
  String get bsSubtitle =>
      'Your request has been created successfully and the provider will be notified shortly.';

  @override
  String get bsNextTitle => 'What happens next';

  @override
  String get bsNextDesc =>
      'You can track the request from your bookings page and we will keep you updated as the status changes.';

  @override
  String get bsProtectionTitle => 'Payment protection';

  @override
  String get bsProtectionDesc =>
      'Escrow-enabled payments stay protected until the work is completed and confirmed.';

  @override
  String get bsViewBookings => 'View Bookings';

  @override
  String get bsBackHome => 'Back to Home';

  @override
  String get bkTitle => 'Book Service';

  @override
  String get bkSubtitle => 'Choose your schedule and location before payment.';

  @override
  String get bkSelectDate => 'Select Date';

  @override
  String get bkSelectDateSub => 'Pick the day you want the provider to arrive.';

  @override
  String get bkSelectTime => 'Select Time';

  @override
  String get bkSelectTimeSub => 'Choose your preferred appointment window.';

  @override
  String get bkServiceAddress => 'Service Address';

  @override
  String get bkServiceAddressSub =>
      'Tell the provider exactly where the work happens.';

  @override
  String get bkAdditionalNotes => 'Additional Notes';

  @override
  String get bkAdditionalNotesSub =>
      'Share instructions, landmarks, or preparation details.';

  @override
  String get bkNotesPlaceholder => 'Add any special instructions...';

  @override
  String get bkSelectDateAction => 'Select a date';

  @override
  String get bkSelectTimeAction => 'Select a time';

  @override
  String get bkSelectServiceAddress => 'Select service address';

  @override
  String get bkSelectedAddress => 'Selected address';

  @override
  String get bkTotal => 'Total';

  @override
  String get bkProceed => 'Proceed to Payment';

  @override
  String get bkErrServiceId => 'Service ID is required';

  @override
  String get bkErrSelectDate => 'Please select a date';

  @override
  String get bkErrSelectTime => 'Please select a time';

  @override
  String get bkErrSelectAddress => 'Please select an address';

  @override
  String get ppAddedToFavorites => 'Added to favorites';

  @override
  String get ppRemovedFromFavorites => 'Removed from favorites';

  @override
  String ppRating(Object rating) {
    return '$rating rating';
  }

  @override
  String ppReviews(Object reviews) {
    return '$reviews reviews';
  }

  @override
  String ppOverviewRating(Object rating, Object reviews) {
    return '$rating • $reviews reviews';
  }

  @override
  String get ppAboutTitle => 'About this service';

  @override
  String get ppAboutSubtitle =>
      'Everything the customer should understand before booking.';

  @override
  String get ppFastBooking => 'Fast booking';

  @override
  String get ppVerifiedProvider => 'Verified provider';

  @override
  String get ppOpenListing => 'Open listing';

  @override
  String get ppVerified => 'Verified';

  @override
  String get ppContact => 'Contact';

  @override
  String get ppBookNow => 'Book Now';

  @override
  String get ppWhyTitle => 'Why customers book this';

  @override
  String get ppWhySubtitle =>
      'A quick snapshot before the booking flow starts.';

  @override
  String get ppFastHandoff => 'Fast handoff';

  @override
  String get ppFastHandoffDesc =>
      'Go from service details to booking in one step.';

  @override
  String get ppSocialProof => 'Social proof';

  @override
  String ppSocialProofDesc(Object reviews) {
    return '$reviews reviews currently attached to this listing.';
  }

  @override
  String get ppProviderContact => 'Provider contact';

  @override
  String get ppProviderContactDesc =>
      'Message the provider first if you want to clarify scope or timing.';

  @override
  String get ppRecentReviews => 'Recent reviews';

  @override
  String get ppRecentReviewsSub => 'Recent customer feedback for this listing.';

  @override
  String get ppSeeAll => 'See all';

  @override
  String get ppNoReviews => 'No reviews yet';

  @override
  String ppReviewsAvailable(Object reviews) {
    return '$reviews reviews available';
  }

  @override
  String ppMinAgo(Object minutes) {
    return '$minutes min ago';
  }

  @override
  String ppHoursAgo(Object hours) {
    return '$hours hours ago';
  }

  @override
  String get ppDayAgo => '1 day ago';

  @override
  String ppDaysAgo(Object days) {
    return '$days days ago';
  }

  @override
  String ppWeeksAgo(Object weeks) {
    return '$weeks weeks ago';
  }

  @override
  String ppMonthsAgo(Object months) {
    return '$months months ago';
  }

  @override
  String get cpTitle => 'Contact Provider';

  @override
  String cpSubtitle(Object name) {
    return 'Reach out to $name about service details or availability.';
  }

  @override
  String get cpContactOptions => 'Contact options';

  @override
  String get cpCall => 'Call';

  @override
  String get cpChat => 'Chat';

  @override
  String get cpOpening => 'Opening...';

  @override
  String get cpSendMessageTitle => 'Send a message';

  @override
  String get cpSendMessageSub =>
      'This sends your message straight into the existing in-app chat thread.';

  @override
  String get cpSubject => 'Subject';

  @override
  String get cpSubjectPlaceholder => 'What is this about?';

  @override
  String get cpSubjectRequired => 'Please enter a subject';

  @override
  String get cpMessage => 'Message';

  @override
  String get cpMessagePlaceholder => 'Write your message here...';

  @override
  String get cpMessageRequired => 'Please enter a message';

  @override
  String get cpSending => 'Sending...';

  @override
  String get cpSendMessage => 'Send Message';

  @override
  String get cpPhoneUnavailable => 'Phone number unavailable';

  @override
  String get cpServiceDetails => 'Service details';

  @override
  String get cpCannotContact => 'This provider cannot be contacted yet.';

  @override
  String get cpCouldNotOpenChat => 'Could not open chat right now.';

  @override
  String get cpMessageNotSent => 'Message could not be sent.';

  @override
  String get cpNoMobile => 'No mobile number available';

  @override
  String get cpCouldNotOpenDialer => 'Could not launch phone dialer';

  @override
  String get epTitle => 'Edit Profile';

  @override
  String get epPersonalInfo => 'Personal Information';

  @override
  String get epDisplayName => 'Display Name';

  @override
  String get epDisplayNameHint => 'Enter your name';

  @override
  String get epDisplayNameRequired => 'Display name is required';

  @override
  String get epEmail => 'Email';

  @override
  String get epEmailHint => 'Enter your email';

  @override
  String get epEmailRequired => 'Email is required';

  @override
  String get epEmailInvalid => 'Please enter a valid email';

  @override
  String get epPhoneNumber => 'Phone Number';

  @override
  String get epPhoneHint => 'Enter your phone number';

  @override
  String get epSave => 'Save Changes';

  @override
  String get epStagedLocally => 'Changes staged locally (pending approval)';

  @override
  String get epUpdated => 'Profile updated successfully';

  @override
  String epUpdateError(Object error) {
    return 'Error updating profile: $error';
  }

  @override
  String get suTitle => 'Create Account';

  @override
  String get suSubtitle =>
      'Join Serbisyo and access home services at your fingertips.';

  @override
  String get suFirstName => 'First Name';

  @override
  String get suFirstNameHint => 'Juan';

  @override
  String get suMiddleName => 'Middle Name (optional)';

  @override
  String get suMiddleNameHint => 'Santos';

  @override
  String get suLastName => 'Last Name';

  @override
  String get suLastNameHint => 'Dela Cruz';

  @override
  String get suEmail => 'Email';

  @override
  String get suEmailHint => 'you@example.com';

  @override
  String get suMobileNumber => 'Mobile number';

  @override
  String get suPhonePrefix => '+63';

  @override
  String get suPhoneHint => '9123456789';

  @override
  String get suPassword => 'Password';

  @override
  String get suPasswordHint => 'At least 8 characters';

  @override
  String get suConfirmPassword => 'Confirm Password';

  @override
  String get suConfirmPasswordHint => 'Repeat your password';

  @override
  String get suSigningUp => 'Signing Up...';

  @override
  String get suAlreadyHaveAccount => 'Already have an account? ';

  @override
  String get spwTitle => 'Forgot Password';

  @override
  String get spwSubtitle =>
      'Don\'t worry! It happens. Please enter the email address associated with your account.';

  @override
  String get spwEmail => 'Email';

  @override
  String get spwInvalidEmail => 'Invalid email';

  @override
  String get spwSendReset => 'Send Reset Link';

  @override
  String get spwRememberPassword => 'Remember your password? ';

  @override
  String get fpTitle => 'Forgot Password';

  @override
  String get fpSubtitle =>
      'Don\'t worry! It happens. Please enter the email address associated with your account.';

  @override
  String get fpEmail => 'Email';

  @override
  String get fpInvalidEmail => 'Invalid email';

  @override
  String get fpSendReset => 'Send Reset Link';

  @override
  String get fpRememberPassword => 'Remember your password? ';

  @override
  String get otpTitle => 'Phone Verification';

  @override
  String get otpVerifyPhone => 'Verify your phone';

  @override
  String get otpEnterPhone =>
      'Enter your phone number to receive a one-time code.';

  @override
  String get otpEnterCode => 'Enter the 6-digit code sent to your phone.';

  @override
  String get otpPhoneNumber => 'Phone Number';

  @override
  String get otpPhonePlaceholder => '+63xxxxxxxxxx';

  @override
  String get otpSendCode => 'Send Code';

  @override
  String get otpCodeLabel => 'OTP Code';

  @override
  String get otpCodePlaceholder => '000000';

  @override
  String get otpVerified => 'Verified!';

  @override
  String get otpVerify => 'Verify';

  @override
  String get otpResend => 'Resend OTP';

  @override
  String otpResendCooldown(Object seconds) {
    return 'Resend OTP (${seconds}s)';
  }

  @override
  String get otpErrEnterPhone => 'Please enter a phone number';

  @override
  String get otpErrSendFailed => 'Failed to send code.';

  @override
  String get otpErrEnterCode => 'Please enter the 6-digit code';

  @override
  String get otpErrInvalidCode => 'Invalid code.';

  @override
  String get phvTitle => 'Phone Verification';

  @override
  String get phvEnterCode => 'Enter verification code';

  @override
  String get phvSentCode =>
      'We\'ve sent a 6-digit code to your phone number. Please enter it below.';

  @override
  String get phvErrEnterCode => 'Enter SMS verification code.';

  @override
  String get phvErrCodeDigits => 'Code must be 6 digits.';

  @override
  String get phvVerify => 'Verify';

  @override
  String get phvDidntReceive => 'Didn\'t receive the code?';

  @override
  String get phvResendCode => 'Resend Code';

  @override
  String get snSignOutAllDevices => 'Sign Out All Devices';

  @override
  String get snSignOutAllConfirm =>
      'This will sign you out of all active sessions except this one.';

  @override
  String get snSignOutAll => 'Sign Out All';

  @override
  String get snAllRevoked => 'All other sessions revoked';

  @override
  String get snFailedRevokeAll => 'Failed to revoke sessions';

  @override
  String get snRevoked => 'Session revoked';

  @override
  String get snFailedRevoke => 'Failed to revoke session';

  @override
  String get snTitle => 'Active Sessions';

  @override
  String get snNoActiveSessions => 'No active sessions';

  @override
  String get snUnknown => 'Unknown';

  @override
  String get snCurrent => 'Current';

  @override
  String get snRevoke => 'Revoke';

  @override
  String get bioSetupTitle => 'Biometric Setup';

  @override
  String get bioSetupSubtitle =>
      'Use your fingerprint or face to sign in quickly and securely.';

  @override
  String get bioSetupRegister => 'Register this device';

  @override
  String get bioSetupDeviceNameLabel => 'Device name (e.g. My Phone)';

  @override
  String get bioSetupDeviceNameDefault => 'My Device';

  @override
  String get bioSetupRegistered => 'Device registered';

  @override
  String get bioSetupRegistrationFailed => 'Registration failed';

  @override
  String get bioSetupRegisteredDevices => 'Registered Devices';

  @override
  String get bioSetupUnknown => 'Unknown';

  @override
  String get mnMarkAllFailed => 'Could not mark notifications as read.';

  @override
  String get mnNoDestination =>
      'This notification has no linked destination yet.';

  @override
  String get mnTitle => 'Notification';

  @override
  String get mnSettings => 'Notification settings';

  @override
  String get mnMarking => 'Marking...';

  @override
  String get mnMarkAllRead => 'Mark all as read';

  @override
  String get mnGranularHint =>
      'Granular controls live inside each service update.';

  @override
  String get mnTabAll => 'All';

  @override
  String get mnTabBookings => 'Bookings';

  @override
  String get mnTabOffers => 'Offers';

  @override
  String get mnTabSystem => 'System';

  @override
  String get mnEmptyBookings =>
      'Booking updates will land here as providers respond.';

  @override
  String get mnEmptyOffers => 'Promos and special offers will show up here.';

  @override
  String get mnEmptySystem => 'System updates will appear here when available.';

  @override
  String get mnOpenDetails => 'Open this update to see more details.';

  @override
  String mnMinutesAgo(Object minutes) {
    return '${minutes}m ago';
  }

  @override
  String mnHoursAgo(Object hours) {
    return '${hours}h ago';
  }

  @override
  String mnDaysAgo(Object days) {
    return '${days}d ago';
  }

  @override
  String get callPermTitleVideo => 'Camera & Microphone';

  @override
  String get callPermTitleAudio => 'Microphone';

  @override
  String get callPermAllowBoth => 'Allow camera & microphone';

  @override
  String get callPermAllowMic => 'Allow microphone';

  @override
  String callPermCalling(Object name) {
    return 'Calling $name';
  }

  @override
  String get callPermAllow => 'Allow';

  @override
  String get chdUnknown => 'Unknown';

  @override
  String get chdTitle => 'Call Details';

  @override
  String get chdUnknownProvider => 'Unknown Provider';

  @override
  String get chdInfoTitle => 'Call Information';

  @override
  String get chdStatus => 'Status';

  @override
  String get chdDuration => 'Duration';

  @override
  String get chdDateTitle => 'Date & Time';

  @override
  String get chdCallBack => 'Call Back';

  @override
  String get chdMessage => 'Message';

  @override
  String get suPhoneRequired =>
      'Phone Number is required and has to start with +.';

  @override
  String crUploadProgress(Object percent) {
    return 'Uploading $percent%';
  }

  @override
  String get mnErrorMarkRead => 'Could not mark notifications as read.';

  @override
  String get mnErrorNoDestination =>
      'This notification has no linked destination yet.';

  @override
  String get adTitle => 'Addresses';

  @override
  String get adAddNewAddress => 'Add new address';

  @override
  String get adNoAddressesYet => 'No addresses yet';

  @override
  String get adEmptySubtitle =>
      'Add your home, work, or favorite places so future bookings are quicker.';

  @override
  String get adSavedAddress => 'Saved address';

  @override
  String get adEdit => 'Edit';

  @override
  String get adSetAsDefault => 'Set as default';

  @override
  String get adDelete => 'Delete';

  @override
  String get adDefault => 'Default';

  @override
  String get adSelected => 'Selected';

  @override
  String get adErrorSetDefault => 'Error setting default address';

  @override
  String get adDefaultUpdated => 'Default address updated';

  @override
  String adErrorSetDefaultDetail(Object error) {
    return 'Error setting default address: $error';
  }

  @override
  String get adDeleteTitle => 'Delete address';

  @override
  String adDeleteConfirm(Object label) {
    return 'Are you sure you want to delete $label?';
  }

  @override
  String get adDeletedSuccess => 'Address deleted successfully';

  @override
  String adErrorDeleteDetail(Object error) {
    return 'Error deleting address: $error';
  }

  @override
  String adSelectedForBookings(Object label) {
    return '$label selected for bookings';
  }

  @override
  String get geSearch => 'Search...';

  @override
  String get geNoItemsFound => 'No items found';

  @override
  String get geTitleRegion => 'Select Region';

  @override
  String get geTitleProvince => 'Select Province';

  @override
  String get geTitleCity => 'Select City/Municipality';

  @override
  String get geTitleBarangay => 'Select Barangay';

  @override
  String get plSearchLocation => 'Search a location';

  @override
  String get plSubmit => 'Submit';

  @override
  String get plNoLocation => 'Please select a location on the map';

  @override
  String get rcTitle => 'Create Room';

  @override
  String get rcLabelTitle => 'Title';

  @override
  String get rcLabelDescription => 'Description';

  @override
  String get rcLabelMenuService => 'Menu / Service';

  @override
  String get rcLabelEventDate => 'Event Date';

  @override
  String get rcLabelEventTime => 'Event Time';

  @override
  String get rcTapToSelect => 'Tap to select';

  @override
  String get rcLabelLocation => 'Location';

  @override
  String get rcHeadsRequired => 'Heads Required';

  @override
  String get rcPricePerHead => 'Price per Head';

  @override
  String get rcFailedCreate => 'Failed to create room';

  @override
  String get rdTitle => 'Room Details';

  @override
  String get rdRoomNotFound => 'Room not found';

  @override
  String get rdParticipants => 'Participants';

  @override
  String get rdJoinCodeCopied => 'Join code copied';

  @override
  String get rdShareJoinCode => 'Share Join Code';

  @override
  String get rdRoomLocked => 'Room locked';

  @override
  String get rdFailed => 'Failed';

  @override
  String get rdLockRoom => 'Lock Room';

  @override
  String get rdCancelRoom => 'Cancel Room';

  @override
  String get rdLeaveRoom => 'Leave Room';

  @override
  String rdJoined(Object count, Object head) {
    return '$count/$head joined';
  }

  @override
  String get rlRooms => 'Rooms';

  @override
  String get rlNoRoomsYet => 'No rooms yet';

  @override
  String get rlCreateRoom => 'Create Room';

  @override
  String rlSeats(Object heads, Object seats) {
    return '$seats/$heads seats';
  }

  @override
  String get rlStatusOpen => 'Open';

  @override
  String get rlStatusLocked => 'Locked';

  @override
  String get rlStatusSettled => 'Settled';

  @override
  String get rlStatusCancelled => 'Cancelled';

  @override
  String get rlStatusExpired => 'Expired';

  @override
  String get rjTitle => 'Join Room';

  @override
  String get rjEnterJoinCode => 'Enter Join Code';

  @override
  String get rjJoinCodePlaceholder => 'Join code';

  @override
  String get rjLookUp => 'Look Up';

  @override
  String get rjRoomNotFound => 'Room not found or link expired.';

  @override
  String rjSeats(Object heads, Object seats) {
    return 'Seats: $seats/$heads';
  }

  @override
  String get rjFailedJoin => 'Failed to join room';

  @override
  String get rjJoinRoom => 'Join Room';

  @override
  String get rjCannotJoin => 'Cannot Join';

  @override
  String get ckConversation => 'Conversation';

  @override
  String get ckStartConversation => 'Start the conversation';

  @override
  String get ckConnected => 'Connected to this thread';

  @override
  String get ckChat => 'Chat';

  @override
  String get ckNoMessages => 'No messages yet';

  @override
  String get ckEmptySubtitle =>
      'Send the first message to coordinate service details, arrival timing, or updates.';

  @override
  String get ckContact => 'Contact';

  @override
  String get ckWriteMessage => 'Write a message...';

  @override
  String get ckSending => 'Sending...';

  @override
  String get ckFailed => 'Failed';

  @override
  String get ckSent => 'Sent';

  @override
  String get pcTitle => 'Create Project';

  @override
  String get pcLabelTitle => 'Title';

  @override
  String get pcLabelDescription => 'Description';

  @override
  String get pcLabelCategory => 'Category';

  @override
  String get pcB2B => 'B2B Project';

  @override
  String get pcFailedCreate => 'Failed to create project';

  @override
  String get pdTitle => 'Project Details';

  @override
  String get pdProjectNotFound => 'Project not found';

  @override
  String get pdRoleLines => 'Role Lines';

  @override
  String get pdNoProspects => 'No prospects yet';

  @override
  String get pdQuoteGenerated => 'Quote generated';

  @override
  String get pdFailed => 'Failed';

  @override
  String get pdGenerateQuote => 'Generate Quote';

  @override
  String get pdCancelProject => 'Cancel Project';

  @override
  String pdBudget(Object max, Object min) {
    return 'Budget: $min - $max';
  }

  @override
  String pdHeadcount(Object count) {
    return 'Headcount: $count';
  }

  @override
  String pdExpires(Object date) {
    return 'Expires: $date';
  }

  @override
  String pdScore(Object score) {
    return 'Score: $score';
  }

  @override
  String get plProjects => 'Projects';

  @override
  String get plNoProjects => 'No projects yet';

  @override
  String get plCreateProject => 'Create a Project';

  @override
  String get pjStatusDraft => 'Draft';

  @override
  String get pjStatusQuoted => 'Quoted';

  @override
  String get pjStatusMatching => 'Matching';

  @override
  String get pjStatusCommitted => 'Committed';

  @override
  String get pjStatusCancelled => 'Cancelled';

  @override
  String get pjStatusExpired => 'Expired';

  @override
  String get obTitle => 'On-Demand Booking';

  @override
  String get obSubtitle => 'Get help when you need it';

  @override
  String get obWhenNeed => 'When do you need service?';

  @override
  String get obOptionNow => 'Now';

  @override
  String get obOptionToday => 'Today';

  @override
  String get obOptionTomorrow => 'Tomorrow';

  @override
  String get obOptionThisWeek => 'This Week';

  @override
  String get obPreferredTime => 'Preferred Time';

  @override
  String get obBookingSummary => 'Booking Summary';

  @override
  String get obFeeService => 'Service Fee';

  @override
  String get obFeeUrgency => 'Urgency Fee';

  @override
  String get obFeeServiceCharge => 'Service Charge';

  @override
  String get obTotal => 'Total';

  @override
  String get obConfirmBooking => 'Confirm Booking';

  @override
  String get cjTitle => 'My On-Demand Jobs';

  @override
  String get cjNoJobs => 'No on-demand jobs yet';

  @override
  String get cjResume => 'Resume';

  @override
  String get cjGeneral => 'General';

  @override
  String get cjProvider => 'Provider';

  @override
  String cjFee(Object fee) {
    return 'Fee: $fee';
  }

  @override
  String cjBids(Object count) {
    return '$count bid(s)';
  }

  @override
  String get cjStatusSearching => 'Searching';

  @override
  String get cjStatusAccepted => 'Accepted';

  @override
  String get cjStatusExpired => 'Expired';

  @override
  String get cjStatusCancelled => 'Cancelled';

  @override
  String get tosTitle => 'Terms of Service';

  @override
  String tosLastUpdated(Object date) {
    return 'Last updated: $date';
  }

  @override
  String get tosAcceptance => 'Acceptance of Terms';

  @override
  String get tosAccounts => 'User Accounts';

  @override
  String get tosServicesBookings => 'Services and Bookings';

  @override
  String get tosProhibited => 'Prohibited Conduct';

  @override
  String get tosPaymentsFees => 'Payments and Fees';

  @override
  String get tosLimitation => 'Limitation of Liability';

  @override
  String get tosContact => 'Contact';

  @override
  String get privTitle => 'Privacy Policy';

  @override
  String privLastUpdated(Object date) {
    return 'Last updated: $date';
  }

  @override
  String get privCollect => 'Information We Collect';

  @override
  String get privUse => 'How We Use Your Information';

  @override
  String get privSharing => 'Information Sharing';

  @override
  String get privSecurity => 'Data Security';

  @override
  String get privRights => 'Your Rights';

  @override
  String get privContact => 'Contact Us';

  @override
  String get hpTitle => 'Help & Support';

  @override
  String get hpChatWithUs => 'Chat with us';

  @override
  String get hpBooking => 'Booking';

  @override
  String get hpPayment => 'Payment';

  @override
  String get hpAccount => 'Account';

  @override
  String get hpProviders => 'Providers';

  @override
  String get cbTitle => 'Chat Assistant';

  @override
  String get cbOnline => 'Online';

  @override
  String get cbTyping => 'Typing...';

  @override
  String get cbHint => 'Type a message...';

  @override
  String get cbGettingAnswer => 'Getting answer...';

  @override
  String get rpTitle => 'Report a Problem';

  @override
  String get rpBack => 'Back';

  @override
  String get rpSubmit => 'Submit Ticket';

  @override
  String get rpTicketSubmitted => 'Ticket Submitted';

  @override
  String get rpWillRespond => 'We\'ll get back to you as soon as possible.';

  @override
  String get rpCategory => 'Category';

  @override
  String get rpCategoryBooking => 'Booking';

  @override
  String get rpCategoryPayment => 'Payment';

  @override
  String get rpCategoryAccount => 'Account';

  @override
  String get rpCategoryOther => 'Other';

  @override
  String get rpDescribeIssue => 'Describe your issue';

  @override
  String get rpPlaceholder => 'Tell us what happened... (min 10 characters)';

  @override
  String get rpMinChars => 'Please provide at least 10 characters';

  @override
  String get dpTitle => 'My Disputes';

  @override
  String get dpNoDisputes => 'No disputes';

  @override
  String get dpViewBooking => 'View Booking';

  @override
  String get dpStatusOpen => 'Open';

  @override
  String get dpStatusReview => 'Under Review';

  @override
  String get dpStatusResolved => 'Resolved';

  @override
  String get dpStatusRejected => 'Rejected';

  @override
  String get dpStatusClosed => 'Closed';

  @override
  String get dpStatusEscalated => 'Escalated';

  @override
  String get rvTitle => 'Reviews';

  @override
  String get rvError => 'Error loading reviews';

  @override
  String get rvRetry => 'Retry';

  @override
  String get rvNoReviews => 'No reviews yet';

  @override
  String rvBeFirst(Object name) {
    return 'Be the first to review $name';
  }

  @override
  String get rvUser => 'User';

  @override
  String rvMinAgo(Object minutes) {
    return '$minutes min ago';
  }

  @override
  String rvHoursAgo(Object hours) {
    return '$hours hours ago';
  }

  @override
  String get rvDayAgo => '1 day ago';

  @override
  String rvDaysAgo(Object days) {
    return '$days days ago';
  }

  @override
  String rvWeeksAgo(Object weeks) {
    return '$weeks weeks ago';
  }

  @override
  String rvMonthsAgo(Object months) {
    return '$months months ago';
  }

  @override
  String get mrTitle => 'My Reviews';

  @override
  String get mrSubtitle =>
      'Track every service you rated and revisit your feedback.';

  @override
  String get mrFootprint => 'Your feedback footprint';

  @override
  String get mrFootprintSub =>
      'Useful for tracking what services delivered the best experience.';

  @override
  String get mrReviews => 'Reviews';

  @override
  String get mrAverage => 'Average';

  @override
  String get mr5Stars => '5 stars';

  @override
  String get mrNoReviews => 'No reviews yet';

  @override
  String get mrEmptyBody =>
      'Once you rate completed services, they will appear here with the service details and your score.';

  @override
  String get mrError => 'Could not load your reviews';

  @override
  String get mrErrorSub => 'Pull to refresh or try again now.';

  @override
  String get mrRetry => 'Retry';

  @override
  String mrServiceFallback(Object id) {
    return 'Service #$id';
  }

  @override
  String get mrService => 'Service';

  @override
  String get mrProvider => 'Service Provider';

  @override
  String get mrJustNow => 'Just now';

  @override
  String mrMinAgo(Object minutes) {
    return '${minutes}m ago';
  }

  @override
  String mrHoursAgo(Object hours) {
    return '${hours}h ago';
  }

  @override
  String mrDaysAgo(Object days) {
    return '${days}d ago';
  }

  @override
  String get wrTitle => 'Write a Review';

  @override
  String get wrExperience => 'How was your experience?';

  @override
  String get wrTellMore => 'Tell us more (optional)';

  @override
  String get wrPlaceholder => 'Share details about your experience...';

  @override
  String get wrSubmitted => 'Review submitted!';

  @override
  String get wrSubmit => 'Submit Review';

  @override
  String get wrSelectRating => 'Please select a rating';

  @override
  String get wrFailed => 'Failed to submit review.';

  @override
  String get rcmTitle => 'Recommendations';

  @override
  String get rcmTrending => 'Trending Now';

  @override
  String get rcmNearYou => 'Near You';

  @override
  String get rcmPicked => 'Picked for You';

  @override
  String get rcmNoRecs => 'No recommendations yet';

  @override
  String get rcmBrowse => 'Browse services to get personalized picks.';

  @override
  String get etTitle => 'Tracking';

  @override
  String get etLinkExpired => 'Link Expired';

  @override
  String get etLinkInvalid => 'This tracking link is no longer valid.';

  @override
  String get etSomethingWrong => 'Something went wrong';

  @override
  String get etRetry => 'Retry';

  @override
  String get etMapView => 'Map View';

  @override
  String get ppfTitle => 'Provider Profile';

  @override
  String get ppfNotFound => 'Provider not found';

  @override
  String get ppfProvider => 'Provider';

  @override
  String get ppfServices => 'Services';

  @override
  String get ppfNoServices => 'No services posted yet.';

  @override
  String get ppfReviews => 'Reviews';

  @override
  String get ppfNoReviews => 'No reviews yet.';

  @override
  String get ppfRating => 'Rating';

  @override
  String get ppfKycVerified => 'KYC Verified';

  @override
  String get ppfAnonymous => 'Anonymous';

  @override
  String get ppfCompletedBookings => 'Completed';

  @override
  String get ppfCompletedBookingsSub => 'completed services';

  @override
  String get ppfSeeAllReviews => 'See all reviews';

  @override
  String get ppfLoadMoreReviews => 'Load more reviews';

  @override
  String get ppfReviewsTitle => 'Provider Reviews';

  @override
  String get favTitle => 'Favorites';

  @override
  String get favSubtitle => 'Quick access to the services you want to revisit.';

  @override
  String get favErrorTitle => 'Error loading favorites';

  @override
  String get favErrorSub =>
      'Something went wrong while loading your saved services.';

  @override
  String get favNoTitle => 'No favorites yet';

  @override
  String get favNoSub =>
      'Save the services you love so they are easy to book again.';

  @override
  String get favService => 'Service';

  @override
  String get favProvider => 'Provider';

  @override
  String get subcatNoServices => 'No services available in this category';

  @override
  String get catdNoServices => 'No services found in this category';

  @override
  String get catdCheckLater => 'Check back later or browse other categories.';

  @override
  String get catgTitle => 'All Categories';

  @override
  String get catgSubtitle => 'Browse every service category in one place.';

  @override
  String get catgError => 'Error loading categories';

  @override
  String get catgNoCategories => 'No categories available';

  @override
  String get catgInstantDispatch => 'Instant dispatch';

  @override
  String get catgOpenServices => 'Open services';

  @override
  String get catg247 => '24/7';

  @override
  String get abcTitle => 'AI Booking Composer';

  @override
  String get abcDescribe => 'Describe what you need';

  @override
  String get abcPlaceholder =>
      'e.g., I need a plumber to fix a leaking pipe under my kitchen sink';

  @override
  String get abcAnalyzing => 'Analyzing...';

  @override
  String get abcCompose => 'Compose Booking';

  @override
  String get abcExtractError =>
      'Could not extract booking details. Please try again with more specific information.';

  @override
  String get abcExtracted => 'Extracted Details';

  @override
  String get splTagline => 'Connecting Local Needs with Trusted Providers';

  @override
  String get nfTitle => 'Page Not Found';

  @override
  String get nfBody =>
      'The page you\'re looking for doesn\'t exist or has been moved.';

  @override
  String get nfGoHome => 'Go Home';

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbNext => 'Next';

  @override
  String get kycCamera => 'Camera';

  @override
  String get kycGallery => 'Gallery';

  @override
  String get wlTitle => 'Wallet';

  @override
  String get wlBalance => 'Available Balance';

  @override
  String get wlEarnings => 'Earnings';

  @override
  String get wlSpent => 'Spent';

  @override
  String get wlTopUp => 'Top Up';

  @override
  String get wlSend => 'Send';

  @override
  String get wlWithdraw => 'Withdraw';

  @override
  String get wlTransactions => 'Transactions';

  @override
  String get wlSeeAll => 'See all';

  @override
  String get ccCancel => 'Cancel';

  @override
  String get ccConfirm => 'Confirm';

  @override
  String get ccDone => 'Done';

  @override
  String get ccOK => 'OK';

  @override
  String get ccBookNow => 'Book Now';

  @override
  String get ccDecline => 'Decline';

  @override
  String get ccAccept => 'Accept';

  @override
  String get ccNext => 'Next';

  @override
  String get ccSkip => 'Skip';

  @override
  String get ccBack => 'Back';

  @override
  String get ccSeeAll => 'See all';

  @override
  String get ccSearch => 'Search...';

  @override
  String get ccSignIn => 'Sign In';

  @override
  String get ccGetStarted => 'Get Started';

  @override
  String get ccTryAgain => 'Try again';

  @override
  String get ccSomethingWrong => 'Something went wrong';

  @override
  String get ccSignInTitle => 'Sign in to continue';

  @override
  String get ccSignInSubtitle =>
      'You need to be signed in to access this feature.';

  @override
  String get ccWriteReview => 'Write Review';

  @override
  String get ccBookAgain => 'Book Again';

  @override
  String get ccViewDetails => 'View Details';

  @override
  String get ccTrackService => 'Track Service';

  @override
  String get ccReschedule => 'Reschedule';

  @override
  String get ccInProgress => 'In progress';

  @override
  String get ccCamMicAccess => 'Camera & Microphone Access';

  @override
  String get ccMicAccess => 'Microphone Access';

  @override
  String get ccCamMicDesc =>
      'Allow camera and microphone to join the video call.';

  @override
  String get ccMicDesc => 'Allow microphone access to join the audio call.';

  @override
  String get ccPermDenied =>
      'Permission denied. Please enable it in your device settings.';

  @override
  String get ccAccessGranted => 'Access granted!';

  @override
  String get ccAllowCamMic => 'Allow Camera & Microphone';

  @override
  String get ccAllowMic => 'Allow Microphone';

  @override
  String get ccNoInternet => 'No internet connection';

  @override
  String get ccSeasonalDeals => 'Explore Seasonal Deals';

  @override
  String get cc60Off => 'Get 60% OFF!';

  @override
  String get ccNewJobRequest => 'New Job Request';

  @override
  String get ccWithin15 => 'Within 15 min';

  @override
  String get cc15to30 => '15–30 min';

  @override
  String get ccInstantDispatch => 'Instant Dispatch';

  @override
  String ccDispatchDesc(Object category) {
    return '$category pros guaranteed at your door in 15–30 minutes.';
  }

  @override
  String get ccInviteEarn => 'Invite & Earn';

  @override
  String get ccInviteSubtitle =>
      'Refer a friend and get a PHP 100 cash bonus when they complete their first booking.';

  @override
  String get ccShareLink => 'Share Link';

  @override
  String get ccTotalDue => 'Total due';

  @override
  String get ccYou => 'You';

  @override
  String get ccClient => 'Client';

  @override
  String ccKmAway(Object km) {
    return '$km km away';
  }

  @override
  String ccStarting(Object fee) {
    return 'Starting $fee';
  }

  @override
  String get ccOnline => 'Online';

  @override
  String get ccOffline => 'Offline';

  @override
  String get ccYouOnline => 'You\'re Online';

  @override
  String get ccYouOffline => 'You\'re Offline';

  @override
  String get ccReadyRequests => 'Ready to receive service requests';

  @override
  String get ccNoNewRequests => 'New requests won\'t reach you';

  @override
  String get ccEmergenciesWait => 'Emergencies can\'t wait.';

  @override
  String get ccVerifiedPro => 'Get a verified pro dispatched right now.';

  @override
  String get ccUrgentAssistance => 'Urgent Assistance';

  @override
  String get ccTypeMessage => 'Type a message...';

  @override
  String ccSelect(Object field) {
    return 'Select $field';
  }

  @override
  String get ccEnterPassword => 'Please enter your password.';

  @override
  String get ccIncorrectPassword => 'Incorrect password.';

  @override
  String get ccConfirmPasswordTitle =>
      'For your security, please confirm your password to continue.';

  @override
  String get ccPasswordLabel => 'Password';

  @override
  String get ccWaitingSelection => 'Waiting for selection…';

  @override
  String get ccClientReviewing =>
      'The client is reviewing available providers.';

  @override
  String get ccDismiss => 'Dismiss';

  @override
  String get svSubtitle => 'Find the right pro for the job.';

  @override
  String get svNoDispatchPros => 'No dispatch-ready pros nearby yet.';

  @override
  String get svSetLocation => 'Set location';

  @override
  String get svSearchPlaceholder => 'Search services or categories...';

  @override
  String get svNoServicesAvailable => 'No services available';

  @override
  String get svNoServicesFound => 'No services found';

  @override
  String get svNoCategoryListings =>
      'That category does not have live listings yet.';

  @override
  String get svTryBroaderKeyword =>
      'Try a broader keyword or clear your filters.';

  @override
  String get svDistanceUnknown => 'Distance unknown';

  @override
  String get svStartingFee => 'Starting Fee';

  @override
  String get svFilterRecommended => 'Recommended';

  @override
  String get svFilterTopRated => 'Top rated';

  @override
  String get svFilterLowestPrice => 'Lowest price';

  @override
  String get svFilterNearest => 'Nearest first';

  @override
  String get svPinnedAddress => 'Pinned address';

  @override
  String get svVoiceComingSoon => 'Voice search coming soon';

  @override
  String get pfNotFound => 'Profile not found';

  @override
  String get pfAccountGroup => 'ACCOUNT';

  @override
  String get pfMyBookings => 'My Bookings';

  @override
  String get pfMyBookingsSub => 'View past and upcoming jobs';

  @override
  String get pfPaymentInvoices => 'Payment & Invoices';

  @override
  String get pfPaymentInvoicesSub => 'View history and download invoices';

  @override
  String get pfLanguage => 'Language Preference';

  @override
  String get pfPrefsGroup => 'PREFERENCES & UTILITIES';

  @override
  String get pfFavorites => 'Favorites';

  @override
  String get pfFavoritesSub => 'Jump back into the services you saved';

  @override
  String get pfMyReviews => 'My Reviews';

  @override
  String get pfMyReviewsSub => 'See the feedback you have left';

  @override
  String get pfReferral => 'Referral Program';

  @override
  String get pfReferralSub => 'Share and earn rewards';

  @override
  String get pfNotificationSettings => 'Notification Settings';

  @override
  String get pfNotificationSettingsSub => 'Control alerts and reminders';

  @override
  String get pfHelpCenter => 'Help Center';

  @override
  String get pfHelpCenterSub => 'FAQs and chat with our support team';

  @override
  String get pfSystemAccessGroup => 'SYSTEM ACCESS';

  @override
  String get pfSecuritySub => 'Password, login protection, and app security';

  @override
  String get pfLogOutSub => 'Sign out of your account on this device';

  @override
  String get pfSavedPlaces => 'Saved Places';

  @override
  String get pfSet => 'Set';

  @override
  String get pfAdd => 'Add';

  @override
  String get pfVerificationGroup => 'VERIFICATION';

  @override
  String get pfAreYouProvider => 'Are you a service provider?';

  @override
  String get pfSwitchToProvider => 'Switch to Provider Account';

  @override
  String get pfProviderDetected => 'Provider account detected';

  @override
  String get pfProviderAppBody =>
      'Service providers use the dedicated Serbisyo Provider app. Open the store to install it, then sign in with the same account.';

  @override
  String get pfOpenProviderAppStore => 'Open Provider App Store';

  @override
  String get pfInviteCopied => 'Invite link copied — share it to earn rewards!';

  @override
  String get pfUploadingPhoto => 'Uploading photo…';

  @override
  String get pfUploadFailed => 'Could not upload photo. Please try again.';

  @override
  String get pfPhotoUpdated => 'Profile photo updated!';

  @override
  String pfUploadError(Object error) {
    return 'Upload failed: $error';
  }

  @override
  String get pfChooseGallery => 'Choose from gallery';

  @override
  String get pfTakePhoto => 'Take a photo';

  @override
  String get pmTitle => 'Payment Methods';

  @override
  String get pmSubtitle => 'Manage how you pay for bookings.';

  @override
  String pmEndingIn(Object lastFour) {
    return 'ending in $lastFour';
  }

  @override
  String pmExpires(Object month, Object year) {
    return 'Expires $month/$year';
  }

  @override
  String get pmEwallet => 'E-Wallet';

  @override
  String get pmNoPhone => 'No phone number';

  @override
  String get pmEmptyTitle => 'No payment methods yet';

  @override
  String get pmEmptySubtitle =>
      'Add a card or e-wallet so checkout is faster when you book.';

  @override
  String get pmErrorLoading => 'Error loading payment methods';

  @override
  String get pmAddTitle => 'Add Payment Method';

  @override
  String get pmSetDefault => 'Set as default';

  @override
  String get pmSetDefaultFull => 'Set as default payment method';

  @override
  String get pmEdit => 'Edit';

  @override
  String get pmRemove => 'Remove';

  @override
  String get pmRemoved => 'Payment method removed';

  @override
  String get pmCreditDebitCard => 'Credit/Debit Card';

  @override
  String get pmEwalletOptions => 'E-Wallet (GCash, Maya)';

  @override
  String get pmNotAuthenticated => 'User not authenticated';

  @override
  String get pewUpdated => 'E-wallet updated successfully';

  @override
  String get pewAdded => 'E-wallet added successfully';

  @override
  String pewSaveError(Object error) {
    return 'Error saving e-wallet: $error';
  }

  @override
  String get pewTitle => 'Add E-Wallet';

  @override
  String get pewInfoHeader => 'E-Wallet Information';

  @override
  String get pewProvider => 'Provider';

  @override
  String get pewSelectProvider => 'Please select provider';

  @override
  String get pewPhoneNumber => 'Phone Number';

  @override
  String get pewEnterPhone => 'Please enter phone number';

  @override
  String get pewValidPhone => 'Please enter a valid 11-digit phone number';

  @override
  String get pewAccountName => 'Account Name';

  @override
  String get pewEnterAccountName => 'Please enter account name';

  @override
  String get pcaUpdated => 'Card updated successfully';

  @override
  String get pcaAdded => 'Card added successfully';

  @override
  String pcaSaveError(Object error) {
    return 'Error saving card: $error';
  }

  @override
  String get pcaTitle => 'Add Card';

  @override
  String get pcaInfoHeader => 'Card Information';

  @override
  String get pcaCardNumber => 'Card Number';

  @override
  String get pcaEnterCardNumber => 'Please enter card number';

  @override
  String get pcaValidCardNumber => 'Please enter a valid card number';

  @override
  String get pcaCardType => 'Card Type';

  @override
  String get pcaSelectCardType => 'Please select card type';

  @override
  String get pcaRequired => 'Required';

  @override
  String get pcaInvalidMonth => 'Invalid month';

  @override
  String get pcaInvalidYear => 'Invalid year';

  @override
  String get pcaCardholderName => 'Cardholder Name';

  @override
  String get pcaEnterCardholderName => 'Please enter cardholder name';

  @override
  String get msTitle => 'Messages';

  @override
  String get msSubtitle => 'Stay close to providers, updates, and support.';

  @override
  String get msChats => 'Chats';

  @override
  String get msCallsHistory => 'Calls history';

  @override
  String get msSearchPlaceholder => 'Search conversations or calls';

  @override
  String get msRecentConversations => 'Recent conversations';

  @override
  String get msRecentCalls => 'Recent calls';

  @override
  String msItems(Object itemCount) {
    return '$itemCount items';
  }

  @override
  String get msNoConversations => 'No conversations yet';

  @override
  String get msNoConversationsMatch => 'No conversations matched';

  @override
  String get msEmptyChatsBody =>
      'Messages from your providers will show up here once a booking starts.';

  @override
  String get msTryAnotherProvider => 'Try another provider name or keyword.';

  @override
  String get msNoCalls => 'No call activity yet';

  @override
  String get msNoCallsMatch => 'No calls matched';

  @override
  String get msEmptyCallsBody =>
      'Your completed and missed calls will appear here when that history is available.';

  @override
  String get msTryOtherSearch => 'Try a different search term.';

  @override
  String get msNoMessages => 'No messages yet';

  @override
  String get msConversation => 'Conversation';

  @override
  String msUnreadCount(Object unreadCount) {
    return '$unreadCount unread';
  }

  @override
  String get msJustNow => 'Just now';

  @override
  String msMinutesAgo(Object n) {
    return '${n}m ago';
  }

  @override
  String msHoursAgo(Object n) {
    return '${n}h ago';
  }

  @override
  String msDaysAgo(Object n) {
    return '${n}d ago';
  }

  @override
  String get hmSearchPlaceholder => 'Search services...';

  @override
  String get hmMore => 'More';

  @override
  String get hmBookingStartsPinned =>
      'Booking starts from your pinned location';

  @override
  String get hmPinnedAddress => 'Pinned address';

  @override
  String get hmCurrentDeviceLocation => 'Current device location';

  @override
  String get hmSelectLocation => 'Select your location';

  @override
  String get hmExitApp => 'Exit App';

  @override
  String get hmExitConfirm => 'Are you sure you want to exit the app?';

  @override
  String get hmExit => 'Exit';

  @override
  String get hmChooseLocation => 'Choose location';

  @override
  String get hmChooseLocationSub =>
      'Use your live device location or one of your saved addresses.';

  @override
  String get hmUseLiveLocation => 'Use your live phone location on the map';

  @override
  String get hmEnableLocationServices =>
      'Enable location services to use this option';

  @override
  String get hmSavedAddress => 'Saved address';

  @override
  String get hmWaitingConfirmation => 'Waiting for provider confirmation';

  @override
  String get hmProviderConfirmedToday => 'Provider confirmed for today';

  @override
  String get hmCatCleaning => 'Cleaning';

  @override
  String get hmCatPlumbing => 'Plumbing';

  @override
  String get hmCatElectrical => 'Electrical';

  @override
  String get hmCatPainting => 'Painting';

  @override
  String get exTitle => 'Explore';

  @override
  String get exSubtitle => 'Discover top-rated pros and seasonal deals.';

  @override
  String get exSearchPlaceholder => 'Search services or providers';

  @override
  String get exVoiceComingSoon => 'Voice search coming soon';

  @override
  String get exServiceCategory => 'Service Category';

  @override
  String get exViewAll => 'View All';

  @override
  String get exTopRatedNearYou => 'Top Rated Near You';

  @override
  String get exServiceProviderFallback => 'Service Provider';

  @override
  String get exRecommendedForYou => 'Recommended for You';

  @override
  String get exNoRecommendations =>
      'No recommendations yet — book a service to personalize this feed.';

  @override
  String get exInviteCopied => 'Invite link copied — share it with friends!';

  @override
  String get ctgTitle => 'Categories';

  @override
  String get ctgSubtitle => 'Jump into the service type you need most.';

  @override
  String get bkfTitle => 'Bookings';

  @override
  String get bkfSubtitle =>
      'Track active work, completed visits, and next steps.';

  @override
  String get bkfPending => 'Pending';

  @override
  String get bkfCompleted => 'Completed';

  @override
  String get bkfCanceled => 'Canceled';

  @override
  String get bkfRescheduleSoon => 'Rescheduling is coming soon.';

  @override
  String get ehConnectionError =>
      'Cannot reach the server. Check your internet connection and try again.';

  @override
  String get ehGenericError => 'Something went wrong. Please try again.';

  @override
  String get ehInvalidFormat => 'Invalid format. Please try again.';

  @override
  String get ehInvalidArgument => 'Invalid input. Please try again.';

  @override
  String get auSignOutError =>
      'There was a problem signing you out. Please try again.';

  @override
  String get auVerificationEmailSent => 'Verification email sent';

  @override
  String get auVerificationError =>
      'There was a problem sending the verification email. Please try again.';

  @override
  String get panProviderAppBody =>
      'Provider tools have moved to the Serbisyo Provider app. You can continue using this app as a client, or sign out.';

  @override
  String get panSignOut => 'Sign out';

  @override
  String get panContinueAsClient => 'Continue as client';

  @override
  String get panNavigationError => 'Navigation error. Please try again.';

  @override
  String get pmtFailedObtainClientSecret =>
      'Failed to obtain payment client secret';

  @override
  String get pmtFailedObtainCheckoutUrl => 'Failed to obtain checkout URL';

  @override
  String get pmtPaymentFailed => 'Payment failed';

  @override
  String get wtUnknownService => 'Unknown Service';

  @override
  String get wtClient => 'Client';

  @override
  String wtDebitDesc(Object serviceName) {
    return 'Payment to Provider — $serviceName';
  }

  @override
  String wtCreditDesc(Object serviceName, Object clientName) {
    return 'Service Payment — $serviceName ($clientName)';
  }

  @override
  String get wtDateNa => 'N/A';

  @override
  String get hmSavedAddresses => 'Saved addresses';

  @override
  String get bfAddress => 'Address';

  @override
  String get bkEmptySearchTitle => 'No bookings matched';

  @override
  String get bkEmptySearchDesc =>
      'Try another keyword or switch the status filter.';

  @override
  String get bkEmptyAllTitle => 'No bookings found';

  @override
  String get bkEmptyAllDesc =>
      'You haven\'t scheduled any services yet. Find a pro to get started!';

  @override
  String get bkEmptyPendingTitle => 'No pending jobs';

  @override
  String get bkEmptyPendingDesc =>
      'Any service requests waiting for provider approval will appear here.';

  @override
  String get bkEmptyCompletedTitle => 'No completed visits yet';

  @override
  String get bkEmptyCompletedDesc =>
      'Once a service technician finishes a job, your history will show up here.';

  @override
  String get bkEmptyCanceledTitle => 'No canceled bookings';

  @override
  String get bkEmptyCanceledDesc =>
      'Great! You don\'t have any canceled or interrupted service requests.';

  @override
  String get bkStatusUnknown => 'Unknown';

  @override
  String get bkStatusPending => 'Pending';

  @override
  String get bkStatusConfirmed => 'Confirmed';

  @override
  String get bkStatusInProgress => 'In Progress';

  @override
  String get bkStatusCompleted => 'Completed';

  @override
  String get bkStatusCancelled => 'Cancelled';

  @override
  String get bkFallbackUnknownService => 'Unknown Service';

  @override
  String get bkFallbackService => 'Service';

  @override
  String get adSelectAddress => 'Select address';

  @override
  String get rlsTitle => 'Reset link sent!';

  @override
  String get rlsBody =>
      'We\'ve sent a password reset link to your email address. Please check your inbox and follow the instructions to reset your password.';

  @override
  String get tmSubHomeLockout => 'Home Lockout';

  @override
  String get tmSubLockRepair => 'Lock Repair';

  @override
  String get tmSubLockReplace => 'Lock Replacement';

  @override
  String get tmSubPipeLeak => 'Pipe Leak Repair';

  @override
  String get tmSubFaucetValve => 'Faucet / Valve Issue';

  @override
  String get tmSubDrainClog => 'Drain Clog Clearing';

  @override
  String get tmSubOutletSwitch => 'Outlet / Switch Issue';

  @override
  String get tmSubBreakerTrip => 'Breaker Trip Investigation';

  @override
  String get tmSubLightingRepair => 'Lighting Repair';

  @override
  String get tmSubWasherDryer => 'Washer / Dryer Issue';

  @override
  String get tmSubRefrigerator => 'Refrigerator Issue';

  @override
  String get tmSubSmallAppliance => 'Small Appliance Repair';

  @override
  String get tmSubQuickRepair => 'Quick Repair Visit';

  @override
  String get tmSubDiagnostic => 'Diagnostic Visit';

  @override
  String get tmSubUrgent => 'Urgent Assistance';

  @override
  String get tmTabMap => 'Map';

  @override
  String get tmTabChat => 'Chat';

  @override
  String get tmTabProvider => 'Provider';

  @override
  String get tmDispatchServer => 'Dispatch path: server-authoritative';

  @override
  String get tmDispatchFallback => 'Dispatch path: fallback matcher';

  @override
  String get tmDispatchPending => 'Dispatch path: pending';

  @override
  String tmEtaFormat(Object min) {
    return 'ETA $min min';
  }

  @override
  String tmRadiusLabel(Object km) {
    return '$km km radius';
  }

  @override
  String get tmModeServer => 'Server dispatch';

  @override
  String get tmModeFallback => 'Fallback dispatch';

  @override
  String get tmModePending => 'Dispatch pending';

  @override
  String get tmPmtCard => 'Card';

  @override
  String get tmPmtCashCompletion => 'Cash on Completion';

  @override
  String get tmPmtCardDesc => 'Visa, Mastercard, and debit cards';

  @override
  String get lmRoute => 'Route';

  @override
  String get lmReference => 'Reference';

  @override
  String get ppFallbackCustomer => 'Customer';

  @override
  String get ckPlaceholder => 'Type a message...';

  @override
  String get spBookingRefPrefix => 'Booking #';

  @override
  String get bsCalTitle => 'Serbisyo booking';

  @override
  String bsCalDesc(Object id) {
    return 'Booking $id via Serbisyo';
  }

  @override
  String get tmHwTitle => 'Hardware Parts Required';

  @override
  String get tmProviderDefault => 'Service Provider';

  @override
  String get tmVehicleNearby => 'Nearby service unit';

  @override
  String get tmVehicleExpanded => 'Expanded-area service unit';

  @override
  String get tmProviderFallback => 'Provider';

  @override
  String get tmVehicleFallback => 'Service unit';

  @override
  String get bkPmtCOD => 'COD';

  @override
  String get pfAddProfilePicture => 'Add profile picture';

  @override
  String get pfChangeProfilePicture => 'Change profile picture';

  @override
  String get pfRemoveProfilePicture => 'Remove profile picture';

  @override
  String get pfRemovePhotoTitle => 'Remove profile picture?';

  @override
  String get pfRemovePhotoMessage =>
      'Your photo will be removed from your public profile.';

  @override
  String get pfPhotoRemoved => 'Profile picture removed.';
}
