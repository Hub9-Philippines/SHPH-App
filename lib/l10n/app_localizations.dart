import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fil.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fil')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Serbisyo'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage preferences, account, and support options.'**
  String get settingsSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used across the app'**
  String get languageSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review booking, message, and payment updates'**
  String get notificationsSubtitle;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark appearance'**
  String get darkModeSubtitle;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @securitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Password, login activity, and 2FA settings'**
  String get securitySubtitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get editProfileSubtitle;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// No description provided for @sendFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open an email draft to share product feedback'**
  String get sendFeedbackSubtitle;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsOfServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our terms and conditions'**
  String get termsOfServiceSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get privacyPolicySubtitle;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOutTitle;

  /// No description provided for @logOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logOutAction.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOutAction;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current language'**
  String get currentLanguage;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose the preferred language for your app experience.'**
  String get chooseLanguage;

  /// No description provided for @notificationsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsPageTitle;

  /// No description provided for @notificationsPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Updates about bookings, messages, and payments.'**
  String get notificationsPageSubtitle;

  /// No description provided for @errorLoadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications'**
  String get errorLoadingNotifications;

  /// No description provided for @errorLoadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while fetching your updates.'**
  String get errorLoadingSubtitle;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @noNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up right now.'**
  String get noNotificationsSubtitle;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @securityPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityPageTitle;

  /// No description provided for @securityPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Protect your account, password, and sign-in access.'**
  String get securityPageSubtitle;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get enterCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmPassword;

  /// No description provided for @reEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your new password'**
  String get reEnterPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @errorChangingPassword.
  ///
  /// In en, this message translates to:
  /// **'Error changing password: '**
  String get errorChangingPassword;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get currentPasswordRequired;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get newPasswordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @twoFactorAuth.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuth;

  /// No description provided for @secureYourLogin.
  ///
  /// In en, this message translates to:
  /// **'Secure your login'**
  String get secureYourLogin;

  /// No description provided for @secureYourLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use an authenticator app to add a second step during sign in.'**
  String get secureYourLoginSubtitle;

  /// No description provided for @setup2FA.
  ///
  /// In en, this message translates to:
  /// **'Setup 2FA'**
  String get setup2FA;

  /// No description provided for @scanQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code with your authenticator app, then enter the 6-digit code to finish setup.'**
  String get scanQRCode;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCode;

  /// No description provided for @verifyAndEnable.
  ///
  /// In en, this message translates to:
  /// **'Verify & Enable'**
  String get verifyAndEnable;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code'**
  String get enterCode;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code: '**
  String get invalidCode;

  /// No description provided for @twoFAEnabled.
  ///
  /// In en, this message translates to:
  /// **'2FA enabled successfully'**
  String get twoFAEnabled;

  /// No description provided for @twoFADisabled.
  ///
  /// In en, this message translates to:
  /// **'2FA disabled successfully'**
  String get twoFADisabled;

  /// No description provided for @errorEnrolling2FA.
  ///
  /// In en, this message translates to:
  /// **'Error enrolling 2FA: '**
  String get errorEnrolling2FA;

  /// No description provided for @loginActivity.
  ///
  /// In en, this message translates to:
  /// **'Login Activity'**
  String get loginActivity;

  /// No description provided for @currentDevice.
  ///
  /// In en, this message translates to:
  /// **'Current device'**
  String get currentDevice;

  /// No description provided for @otherSignIn.
  ///
  /// In en, this message translates to:
  /// **'Other sign-in'**
  String get otherSignIn;

  /// No description provided for @activeNow.
  ///
  /// In en, this message translates to:
  /// **'Active now'**
  String get activeNow;

  /// No description provided for @lastActive.
  ///
  /// In en, this message translates to:
  /// **'Last active '**
  String get lastActive;

  /// No description provided for @noSessions.
  ///
  /// In en, this message translates to:
  /// **'No active sessions were returned for this account yet.'**
  String get noSessions;

  /// No description provided for @keepAccountProtected.
  ///
  /// In en, this message translates to:
  /// **'Keep your account protected'**
  String get keepAccountProtected;

  /// No description provided for @keepAccountProtectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage password strength, 2FA, and recent account access in one place.'**
  String get keepAccountProtectedSubtitle;

  /// No description provided for @providerInbox.
  ///
  /// In en, this message translates to:
  /// **'Provider inbox'**
  String get providerInbox;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'pending request'**
  String get pendingRequests;

  /// No description provided for @pendingRequests_plural.
  ///
  /// In en, this message translates to:
  /// **'pending requests'**
  String get pendingRequests_plural;

  /// No description provided for @newServiceRequests.
  ///
  /// In en, this message translates to:
  /// **'New service requests will appear here as soon as customers book you.'**
  String get newServiceRequests;

  /// No description provided for @quickReplies.
  ///
  /// In en, this message translates to:
  /// **'Quick replies help you convert more requests into confirmed jobs.'**
  String get quickReplies;

  /// No description provided for @dispatchMatch.
  ///
  /// In en, this message translates to:
  /// **'Dispatch match'**
  String get dispatchMatch;

  /// No description provided for @newOffer.
  ///
  /// In en, this message translates to:
  /// **'New offer available'**
  String get newOffer;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @offerAccepted.
  ///
  /// In en, this message translates to:
  /// **'Offer accepted — job confirmed'**
  String get offerAccepted;

  /// No description provided for @offerDeclined.
  ///
  /// In en, this message translates to:
  /// **'Offer declined'**
  String get offerDeclined;

  /// No description provided for @acceptFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to accept offer'**
  String get acceptFailed;

  /// No description provided for @declineFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to decline offer'**
  String get declineFailed;

  /// No description provided for @dispatchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Dispatch unavailable'**
  String get dispatchUnavailable;

  /// No description provided for @couldNotLoadRequests.
  ///
  /// In en, this message translates to:
  /// **'Could not load requests'**
  String get couldNotLoadRequests;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retry;

  /// No description provided for @noJobRequests.
  ///
  /// In en, this message translates to:
  /// **'No job requests yet'**
  String get noJobRequests;

  /// No description provided for @noJobRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When a client books one of your services, the request will appear here for review.'**
  String get noJobRequestsSubtitle;

  /// No description provided for @jobAccepted.
  ///
  /// In en, this message translates to:
  /// **'Job accepted successfully'**
  String get jobAccepted;

  /// No description provided for @jobDeclined.
  ///
  /// In en, this message translates to:
  /// **'Job declined'**
  String get jobDeclined;

  /// No description provided for @acceptJobFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to accept job'**
  String get acceptJobFailed;

  /// No description provided for @declineJobFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to decline job'**
  String get declineJobFailed;

  /// No description provided for @jobRequests.
  ///
  /// In en, this message translates to:
  /// **'Job Requests'**
  String get jobRequests;

  /// No description provided for @jobRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review and respond to new customer bookings fast.'**
  String get jobRequestsSubtitle;

  /// No description provided for @timeMaterial.
  ///
  /// In en, this message translates to:
  /// **'TIME-MATERIAL'**
  String get timeMaterial;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'SCHEDULED'**
  String get scheduled;

  /// No description provided for @controlYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Control your app experience'**
  String get controlYourExperience;

  /// No description provided for @controlYourExperienceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance, security, notifications, and support all live here.'**
  String get controlYourExperienceSubtitle;

  /// No description provided for @completionTitle.
  ///
  /// In en, this message translates to:
  /// **'Almost done!'**
  String get completionTitle;

  /// No description provided for @completionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell the Serbisyo team what to call you. You can add a photo and bio — or skip straight home.'**
  String get completionSubtitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @firstNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get firstNamePlaceholder;

  /// No description provided for @lastNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your family name'**
  String get lastNamePlaceholder;

  /// No description provided for @bioOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio (optional)'**
  String get bioOptionalLabel;

  /// No description provided for @bioPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tell clients a bit about yourself…'**
  String get bioPlaceholder;

  /// No description provided for @progressComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String progressComplete(Object percent);

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @saveProfileFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your profile. Please try again.'**
  String get saveProfileFailed;

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completeYourProfile;

  /// No description provided for @verifyNow.
  ///
  /// In en, this message translates to:
  /// **'Verify now'**
  String get verifyNow;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseYourLanguage;

  /// No description provided for @chooseYourLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This language is used across the app.'**
  String get chooseYourLanguageSubtitle;

  /// No description provided for @kycIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity'**
  String get kycIntroTitle;

  /// No description provided for @kycIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us keep Serbisyo safe. You\'ll need a valid government ID and a live selfie.'**
  String get kycIntroSubtitle;

  /// No description provided for @kycStartVerification.
  ///
  /// In en, this message translates to:
  /// **'Start verification'**
  String get kycStartVerification;

  /// No description provided for @kycWhatYouNeed.
  ///
  /// In en, this message translates to:
  /// **'What you\'ll need:'**
  String get kycWhatYouNeed;

  /// No description provided for @kycMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Takes only a few minutes'**
  String get kycMinutesLabel;

  /// No description provided for @kycIdFrontLabel.
  ///
  /// In en, this message translates to:
  /// **'ID front'**
  String get kycIdFrontLabel;

  /// No description provided for @kycIdBackLabel.
  ///
  /// In en, this message translates to:
  /// **'ID back'**
  String get kycIdBackLabel;

  /// No description provided for @kycSelfieLabel.
  ///
  /// In en, this message translates to:
  /// **'Selfie'**
  String get kycSelfieLabel;

  /// No description provided for @kycCapture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get kycCapture;

  /// No description provided for @kycRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get kycRetake;

  /// No description provided for @kycContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get kycContinue;

  /// No description provided for @kycLivenessTitle.
  ///
  /// In en, this message translates to:
  /// **'Face verification'**
  String get kycLivenessTitle;

  /// No description provided for @kycLivenessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Center your face in the frame and follow the instructions.'**
  String get kycLivenessSubtitle;

  /// No description provided for @kycSubmitNow.
  ///
  /// In en, this message translates to:
  /// **'Submit & finish'**
  String get kycSubmitNow;

  /// No description provided for @kycSubmissionPending.
  ///
  /// In en, this message translates to:
  /// **'Verification submitted. We\'ll review it shortly.'**
  String get kycSubmissionPending;

  /// No description provided for @kycSkipError.
  ///
  /// In en, this message translates to:
  /// **'Could not skip verification. Please try again.'**
  String get kycSkipError;

  /// No description provided for @kycSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Could not submit verification. Please try again.'**
  String get kycSubmitError;

  /// No description provided for @kycPlanCenter.
  ///
  /// In en, this message translates to:
  /// **'Center your face in the frame'**
  String get kycPlanCenter;

  /// No description provided for @kycPlanBlink.
  ///
  /// In en, this message translates to:
  /// **'Blink slowly a few times'**
  String get kycPlanBlink;

  /// No description provided for @kycPlanSmile.
  ///
  /// In en, this message translates to:
  /// **'Smile at the camera'**
  String get kycPlanSmile;

  /// No description provided for @kycVerification.
  ///
  /// In en, this message translates to:
  /// **'KYC Verification'**
  String get kycVerification;

  /// No description provided for @verificationNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get verificationNotStarted;

  /// No description provided for @verificationInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get verificationInProgress;

  /// No description provided for @verificationActionRequired.
  ///
  /// In en, this message translates to:
  /// **'Action required'**
  String get verificationActionRequired;

  /// No description provided for @bfAddToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to Calendar'**
  String get bfAddToCalendar;

  /// No description provided for @bfAdjustBooking.
  ///
  /// In en, this message translates to:
  /// **'Adjust booking'**
  String get bfAdjustBooking;

  /// No description provided for @bfAsQuotedAtCheckout.
  ///
  /// In en, this message translates to:
  /// **'As quoted at checkout'**
  String get bfAsQuotedAtCheckout;

  /// No description provided for @bfAssignedProvider.
  ///
  /// In en, this message translates to:
  /// **'Assigned provider'**
  String get bfAssignedProvider;

  /// No description provided for @bfBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back home'**
  String get bfBackHome;

  /// No description provided for @bfBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get bfBackToHome;

  /// No description provided for @bfBaseService.
  ///
  /// In en, this message translates to:
  /// **'Base service'**
  String get bfBaseService;

  /// No description provided for @bfBookingDate.
  ///
  /// In en, this message translates to:
  /// **'Booking date'**
  String get bfBookingDate;

  /// No description provided for @bfBookingId.
  ///
  /// In en, this message translates to:
  /// **'Booking ID'**
  String get bfBookingId;

  /// No description provided for @bfBookingSummary.
  ///
  /// In en, this message translates to:
  /// **'Booking summary'**
  String get bfBookingSummary;

  /// No description provided for @bfBroadcastingRequest.
  ///
  /// In en, this message translates to:
  /// **'Broadcasting request'**
  String get bfBroadcastingRequest;

  /// No description provided for @bfCancelMatching.
  ///
  /// In en, this message translates to:
  /// **'Cancel matching'**
  String get bfCancelMatching;

  /// No description provided for @bfCancelSearch.
  ///
  /// In en, this message translates to:
  /// **'Cancel search'**
  String get bfCancelSearch;

  /// No description provided for @bfCheckingAvailability.
  ///
  /// In en, this message translates to:
  /// **'Checking availability'**
  String get bfCheckingAvailability;

  /// No description provided for @bfChooseAService.
  ///
  /// In en, this message translates to:
  /// **'Choose a service'**
  String get bfChooseAService;

  /// No description provided for @bfChooseAnyFutureSlot.
  ///
  /// In en, this message translates to:
  /// **'Choose any future slot'**
  String get bfChooseAnyFutureSlot;

  /// No description provided for @bfChooseTiming.
  ///
  /// In en, this message translates to:
  /// **'Choose timing'**
  String get bfChooseTiming;

  /// No description provided for @bfCleaningType.
  ///
  /// In en, this message translates to:
  /// **'Cleaning type'**
  String get bfCleaningType;

  /// No description provided for @bfConfirmReserveSlot.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Reserve Slot'**
  String get bfConfirmReserveSlot;

  /// No description provided for @bfConfirmServiceLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm service location'**
  String get bfConfirmServiceLocation;

  /// No description provided for @bfContinueSearch.
  ///
  /// In en, this message translates to:
  /// **'Continue search'**
  String get bfContinueSearch;

  /// No description provided for @bfContinueToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Continue to checkout'**
  String get bfContinueToCheckout;

  /// No description provided for @bfContinueToSetup.
  ///
  /// In en, this message translates to:
  /// **'Continue to setup'**
  String get bfContinueToSetup;

  /// No description provided for @bfDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get bfDateAndTime;

  /// No description provided for @bfDeepClean.
  ///
  /// In en, this message translates to:
  /// **'Deep clean'**
  String get bfDeepClean;

  /// No description provided for @bfDeepCleanUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Deep clean upgrade'**
  String get bfDeepCleanUpgrade;

  /// No description provided for @bfDispatchMode.
  ///
  /// In en, this message translates to:
  /// **'Dispatch mode'**
  String get bfDispatchMode;

  /// No description provided for @bfEditPin.
  ///
  /// In en, this message translates to:
  /// **'Edit pin'**
  String get bfEditPin;

  /// No description provided for @bfEnRoute.
  ///
  /// In en, this message translates to:
  /// **'En Route'**
  String get bfEnRoute;

  /// No description provided for @bfEstimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated total'**
  String get bfEstimatedTotal;

  /// No description provided for @bfExpressArrival.
  ///
  /// In en, this message translates to:
  /// **'Express arrival'**
  String get bfExpressArrival;

  /// No description provided for @bfFinalNearbySweep.
  ///
  /// In en, this message translates to:
  /// **'Final nearby sweep'**
  String get bfFinalNearbySweep;

  /// No description provided for @bfFinalizeJobSetup.
  ///
  /// In en, this message translates to:
  /// **'Finalize the job setup'**
  String get bfFinalizeJobSetup;

  /// No description provided for @bfFindActiveCleanerNow.
  ///
  /// In en, this message translates to:
  /// **'Find Active Cleaner Now'**
  String get bfFindActiveCleanerNow;

  /// No description provided for @bfFindActiveProviderNow.
  ///
  /// In en, this message translates to:
  /// **'Find Active Provider Now'**
  String get bfFindActiveProviderNow;

  /// No description provided for @bfFindAnotherProvider.
  ///
  /// In en, this message translates to:
  /// **'Find Another Provider'**
  String get bfFindAnotherProvider;

  /// No description provided for @bfFindingNearestProvider.
  ///
  /// In en, this message translates to:
  /// **'Finding the nearest provider'**
  String get bfFindingNearestProvider;

  /// No description provided for @bfHeadingToLocation.
  ///
  /// In en, this message translates to:
  /// **'Heading to your location'**
  String get bfHeadingToLocation;

  /// No description provided for @bfInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get bfInProgress;

  /// No description provided for @bfInstantMatching.
  ///
  /// In en, this message translates to:
  /// **'Instant matching'**
  String get bfInstantMatching;

  /// No description provided for @bfInstantProviderSearch.
  ///
  /// In en, this message translates to:
  /// **'Instant provider search'**
  String get bfInstantProviderSearch;

  /// No description provided for @bfLaterToday.
  ///
  /// In en, this message translates to:
  /// **'Later today'**
  String get bfLaterToday;

  /// No description provided for @bfLiveEstimate.
  ///
  /// In en, this message translates to:
  /// **'Live estimate'**
  String get bfLiveEstimate;

  /// No description provided for @bfAutoMatchingOn.
  ///
  /// In en, this message translates to:
  /// **'Auto-Matching On'**
  String get bfAutoMatchingOn;

  /// No description provided for @bfScanningForProviders.
  ///
  /// In en, this message translates to:
  /// **'Scanning for providers'**
  String get bfScanningForProviders;

  /// No description provided for @bfLocationLoading.
  ///
  /// In en, this message translates to:
  /// **'Location loading...'**
  String get bfLocationLoading;

  /// No description provided for @bfMatchingFlow.
  ///
  /// In en, this message translates to:
  /// **'Matching flow'**
  String get bfMatchingFlow;

  /// No description provided for @bfBroadcastFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Live matching unavailable'**
  String get bfBroadcastFailedTitle;

  /// No description provided for @bfBroadcastFailedBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reach the dispatch service, so this is a preview. Your booking is saved — retry from your bookings or contact support.'**
  String get bfBroadcastFailedBody;

  /// No description provided for @bfNearestAvailableProvider.
  ///
  /// In en, this message translates to:
  /// **'Nearest available provider'**
  String get bfNearestAvailableProvider;

  /// No description provided for @bfOnSite.
  ///
  /// In en, this message translates to:
  /// **'On Site'**
  String get bfOnSite;

  /// No description provided for @bfPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get bfPaymentMethod;

  /// No description provided for @bfPendingAssignment.
  ///
  /// In en, this message translates to:
  /// **'Pending assignment'**
  String get bfPendingAssignment;

  /// No description provided for @bfPickAService.
  ///
  /// In en, this message translates to:
  /// **'Pick a service'**
  String get bfPickAService;

  /// No description provided for @bfPickSpecificTime.
  ///
  /// In en, this message translates to:
  /// **'Pick a specific time'**
  String get bfPickSpecificTime;

  /// No description provided for @bfPinnedLocation.
  ///
  /// In en, this message translates to:
  /// **'Pinned location'**
  String get bfPinnedLocation;

  /// No description provided for @bfPremiumClean.
  ///
  /// In en, this message translates to:
  /// **'Premium clean'**
  String get bfPremiumClean;

  /// No description provided for @bfPremiumMaterials.
  ///
  /// In en, this message translates to:
  /// **'Premium materials'**
  String get bfPremiumMaterials;

  /// No description provided for @bfProviderAssigned.
  ///
  /// In en, this message translates to:
  /// **'Provider assigned'**
  String get bfProviderAssigned;

  /// No description provided for @bfProviderAssignment.
  ///
  /// In en, this message translates to:
  /// **'Provider assignment'**
  String get bfProviderAssignment;

  /// No description provided for @bfProviderEnRoute.
  ///
  /// In en, this message translates to:
  /// **'Provider En Route'**
  String get bfProviderEnRoute;

  /// No description provided for @bfProviderFound.
  ///
  /// In en, this message translates to:
  /// **'Provider found'**
  String get bfProviderFound;

  /// No description provided for @bfProviderAcceptedBooking.
  ///
  /// In en, this message translates to:
  /// **'Provider has accepted your booking'**
  String get bfProviderAcceptedBooking;

  /// No description provided for @bfProviderArrived.
  ///
  /// In en, this message translates to:
  /// **'Provider has arrived at your location'**
  String get bfProviderArrived;

  /// No description provided for @bfProviderWorking.
  ///
  /// In en, this message translates to:
  /// **'Provider is working on your request'**
  String get bfProviderWorking;

  /// No description provided for @bfProviderMatchingNow.
  ///
  /// In en, this message translates to:
  /// **'Provider matching now'**
  String get bfProviderMatchingNow;

  /// No description provided for @bfQuickBook.
  ///
  /// In en, this message translates to:
  /// **'Quick book'**
  String get bfQuickBook;

  /// No description provided for @bfRequireArrivalCode.
  ///
  /// In en, this message translates to:
  /// **'Require Arrival Code'**
  String get bfRequireArrivalCode;

  /// No description provided for @bfReturnToLiveMatching.
  ///
  /// In en, this message translates to:
  /// **'Return to live matching'**
  String get bfReturnToLiveMatching;

  /// No description provided for @bfReviewLiveRequest.
  ///
  /// In en, this message translates to:
  /// **'Review live request'**
  String get bfReviewLiveRequest;

  /// No description provided for @bfReviewScheduledBooking.
  ///
  /// In en, this message translates to:
  /// **'Review scheduled booking'**
  String get bfReviewScheduledBooking;

  /// No description provided for @bfRightNow.
  ///
  /// In en, this message translates to:
  /// **'Right now'**
  String get bfRightNow;

  /// No description provided for @bfRushFactor.
  ///
  /// In en, this message translates to:
  /// **'Rush factor'**
  String get bfRushFactor;

  /// No description provided for @bfScheduleAnotherDay.
  ///
  /// In en, this message translates to:
  /// **'Schedule Another Day'**
  String get bfScheduleAnotherDay;

  /// No description provided for @bfScheduledDateTime.
  ///
  /// In en, this message translates to:
  /// **'Scheduled date & time'**
  String get bfScheduledDateTime;

  /// No description provided for @bfScheduledProviderReservation.
  ///
  /// In en, this message translates to:
  /// **'Scheduled provider reservation'**
  String get bfScheduledProviderReservation;

  /// No description provided for @bfScheduledReservation.
  ///
  /// In en, this message translates to:
  /// **'Scheduled reservation'**
  String get bfScheduledReservation;

  /// No description provided for @bfSearchReference.
  ///
  /// In en, this message translates to:
  /// **'Search reference'**
  String get bfSearchReference;

  /// No description provided for @bfSearchingNearbyProviders.
  ///
  /// In en, this message translates to:
  /// **'Searching nearby providers'**
  String get bfSearchingNearbyProviders;

  /// No description provided for @bfSelectATime.
  ///
  /// In en, this message translates to:
  /// **'Select a time'**
  String get bfSelectATime;

  /// No description provided for @bfSelectedService.
  ///
  /// In en, this message translates to:
  /// **'Selected service'**
  String get bfSelectedService;

  /// No description provided for @bfServiceCompleted.
  ///
  /// In en, this message translates to:
  /// **'Service has been completed'**
  String get bfServiceCompleted;

  /// No description provided for @bfServiceInProgress.
  ///
  /// In en, this message translates to:
  /// **'Service In Progress'**
  String get bfServiceInProgress;

  /// No description provided for @bfServiceLevel.
  ///
  /// In en, this message translates to:
  /// **'Service level'**
  String get bfServiceLevel;

  /// No description provided for @bfServiceLocation.
  ///
  /// In en, this message translates to:
  /// **'Service location'**
  String get bfServiceLocation;

  /// No description provided for @bfServiceProvider.
  ///
  /// In en, this message translates to:
  /// **'Service Provider'**
  String get bfServiceProvider;

  /// No description provided for @bfServiceRequest.
  ///
  /// In en, this message translates to:
  /// **'Service request'**
  String get bfServiceRequest;

  /// No description provided for @bfServiceSetup.
  ///
  /// In en, this message translates to:
  /// **'Service setup'**
  String get bfServiceSetup;

  /// No description provided for @bfServiceSummary.
  ///
  /// In en, this message translates to:
  /// **'Service summary'**
  String get bfServiceSummary;

  /// No description provided for @bfStandardClean.
  ///
  /// In en, this message translates to:
  /// **'Standard clean'**
  String get bfStandardClean;

  /// No description provided for @bfToBeAssigned.
  ///
  /// In en, this message translates to:
  /// **'To be assigned'**
  String get bfToBeAssigned;

  /// No description provided for @bfTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get bfTotalAmount;

  /// No description provided for @bfTrackMyBooking.
  ///
  /// In en, this message translates to:
  /// **'Track My Booking'**
  String get bfTrackMyBooking;

  /// No description provided for @bfViewBookings.
  ///
  /// In en, this message translates to:
  /// **'View Bookings'**
  String get bfViewBookings;

  /// No description provided for @bfViewInvoice.
  ///
  /// In en, this message translates to:
  /// **'View Invoice'**
  String get bfViewInvoice;

  /// No description provided for @bfViewStatus.
  ///
  /// In en, this message translates to:
  /// **'View Status'**
  String get bfViewStatus;

  /// No description provided for @bfWriteAReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get bfWriteAReview;

  /// No description provided for @bfSlotConfirmSoon.
  ///
  /// In en, this message translates to:
  /// **'Your slot will be confirmed shortly'**
  String get bfSlotConfirmSoon;

  /// No description provided for @bfYourCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Your Current Location'**
  String get bfYourCurrentLocation;

  /// No description provided for @bfPleaseChooseService.
  ///
  /// In en, this message translates to:
  /// **'Please choose a service before continuing.'**
  String get bfPleaseChooseService;

  /// No description provided for @bfNoProvidersNearby.
  ///
  /// In en, this message translates to:
  /// **'No providers available within 10 km of your location. Try expanding your search area or scheduling for later.'**
  String get bfNoProvidersNearby;

  /// No description provided for @bfProviderPrepTime.
  ///
  /// In en, this message translates to:
  /// **'Our closest professional needs at least 2 hours to prepare and travel to your location. Please adjust your time selection.'**
  String get bfProviderPrepTime;

  /// No description provided for @bfCouldNotReserve.
  ///
  /// In en, this message translates to:
  /// **'Could not reserve. Please try again.'**
  String get bfCouldNotReserve;

  /// No description provided for @bfCouldNotStartLiveMatching.
  ///
  /// In en, this message translates to:
  /// **'Could not start live matching. Please try again.'**
  String get bfCouldNotStartLiveMatching;

  /// No description provided for @bfCouldNotReserveSlot.
  ///
  /// In en, this message translates to:
  /// **'Could not reserve the slot. Please try again.'**
  String get bfCouldNotReserveSlot;

  /// No description provided for @bfInviteCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite link copied — share it with friends!'**
  String get bfInviteCopied;

  /// No description provided for @bfCouldNotOpenCalendar.
  ///
  /// In en, this message translates to:
  /// **'Could not open your calendar app.'**
  String get bfCouldNotOpenCalendar;

  /// No description provided for @bfTrackingAfterAccept.
  ///
  /// In en, this message translates to:
  /// **'Tracking will be available once a provider accepts.'**
  String get bfTrackingAfterAccept;

  /// No description provided for @bfReviewAfterSync.
  ///
  /// In en, this message translates to:
  /// **'Review will be available once this booking is synced.'**
  String get bfReviewAfterSync;

  /// No description provided for @bfInvoiceSoon.
  ///
  /// In en, this message translates to:
  /// **'Your invoice will be available shortly.'**
  String get bfInvoiceSoon;

  /// No description provided for @bfCancelProviderSearchQ.
  ///
  /// In en, this message translates to:
  /// **'Cancel provider search?'**
  String get bfCancelProviderSearchQ;

  /// No description provided for @bfCancelSearchBody.
  ///
  /// In en, this message translates to:
  /// **'Your current search is still running. If you cancel now, you can adjust the booking details and try again.'**
  String get bfCancelSearchBody;

  /// No description provided for @bfFindAnotherProviderQ.
  ///
  /// In en, this message translates to:
  /// **'Find another provider?'**
  String get bfFindAnotherProviderQ;

  /// No description provided for @bfCancelBookingQ.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this booking and search for another provider?'**
  String get bfCancelBookingQ;

  /// No description provided for @bfYesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get bfYesCancel;

  /// No description provided for @bfNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get bfNo;

  /// No description provided for @bfArrivalCodeInfo.
  ///
  /// In en, this message translates to:
  /// **'Your provider must read you a one-time arrival code before starting work — protecting you from premature or unauthorized starts.'**
  String get bfArrivalCodeInfo;

  /// No description provided for @bfBookingConfirmedExclaim.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed!'**
  String get bfBookingConfirmedExclaim;

  /// No description provided for @bfRequestInBody.
  ///
  /// In en, this message translates to:
  /// **'Your request is in. We\'ll notify you the moment a provider accepts — no follow-up needed.'**
  String get bfRequestInBody;

  /// No description provided for @bfConfirmSlotSoon.
  ///
  /// In en, this message translates to:
  /// **'You will confirm a slot shortly'**
  String get bfConfirmSlotSoon;

  /// No description provided for @bfConfirmRightPlace.
  ///
  /// In en, this message translates to:
  /// **'Make sure the provider is headed to the right place before choosing the time.'**
  String get bfConfirmRightPlace;

  /// No description provided for @bfDropOffPoint.
  ///
  /// In en, this message translates to:
  /// **'Drop-off point'**
  String get bfDropOffPoint;

  /// No description provided for @bfWhenNeedService.
  ///
  /// In en, this message translates to:
  /// **'When do you need {serviceTitle}?'**
  String bfWhenNeedService(Object serviceTitle);

  /// No description provided for @bfPickDispatchSpeed.
  ///
  /// In en, this message translates to:
  /// **'Pick the dispatch speed that fits this request best.'**
  String get bfPickDispatchSpeed;

  /// No description provided for @bfTapServiceConfigure.
  ///
  /// In en, this message translates to:
  /// **'Tap any service to instantly configure your booking.'**
  String get bfTapServiceConfigure;

  /// No description provided for @bfCouldNotLoadServices.
  ///
  /// In en, this message translates to:
  /// **'Could not load services. Pull down to retry.'**
  String get bfCouldNotLoadServices;

  /// No description provided for @bfSearchAllServices.
  ///
  /// In en, this message translates to:
  /// **'Search all services →'**
  String get bfSearchAllServices;

  /// No description provided for @bfHeroCategoryReady.
  ///
  /// In en, this message translates to:
  /// **'{category} service ready. Pick the time, then we\'ll route it fast.'**
  String bfHeroCategoryReady(Object category);

  /// No description provided for @bfHeroFastDispatch.
  ///
  /// In en, this message translates to:
  /// **'Fast dispatch. Zero friction. Pick the service, then the time.'**
  String get bfHeroFastDispatch;

  /// No description provided for @bfAdjustScope.
  ///
  /// In en, this message translates to:
  /// **'Adjust the scope in seconds. Pricing updates live as you change settings.'**
  String get bfAdjustScope;

  /// No description provided for @bfConfirmCheckoutBody.
  ///
  /// In en, this message translates to:
  /// **'Confirm the slot, pinned address, and payment before we reserve it.'**
  String get bfConfirmCheckoutBody;

  /// No description provided for @bfConfirmSearchBody.
  ///
  /// In en, this message translates to:
  /// **'Confirm the pinned address and payment before we start searching nearby providers.'**
  String get bfConfirmSearchBody;

  /// No description provided for @bfLockInSlot.
  ///
  /// In en, this message translates to:
  /// **'We will lock in your selected slot and keep this pinned location for the visit.'**
  String get bfLockInSlot;

  /// No description provided for @bfSearchSavedPin.
  ///
  /// In en, this message translates to:
  /// **'We will search nearby providers around this saved pin as soon as you continue.'**
  String get bfSearchSavedPin;

  /// No description provided for @bfLiveMatchingActive.
  ///
  /// In en, this message translates to:
  /// **'Live matching active'**
  String get bfLiveMatchingActive;

  /// No description provided for @bfAlertingNearbyProviders.
  ///
  /// In en, this message translates to:
  /// **'Alerting nearby active providers around your pin.'**
  String get bfAlertingNearbyProviders;

  /// No description provided for @bfComparingWhoReaches.
  ///
  /// In en, this message translates to:
  /// **'Comparing who can reach you the fastest.'**
  String get bfComparingWhoReaches;

  /// No description provided for @bfFinalPass.
  ///
  /// In en, this message translates to:
  /// **'Running one last pass before the request times out.'**
  String get bfFinalPass;

  /// No description provided for @bfNameOnWay.
  ///
  /// In en, this message translates to:
  /// **'{name} is on the way to your location.'**
  String bfNameOnWay(Object name);

  /// No description provided for @bfStayOnScreen.
  ///
  /// In en, this message translates to:
  /// **'Stay on this screen while we look for the closest available professional.'**
  String get bfStayOnScreen;

  /// No description provided for @bfSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching'**
  String get bfSearching;

  /// No description provided for @bfProvidersNotified.
  ///
  /// In en, this message translates to:
  /// **'Providers notified'**
  String get bfProvidersNotified;

  /// No description provided for @bfProviderCountOne.
  ///
  /// In en, this message translates to:
  /// **'1 provider'**
  String get bfProviderCountOne;

  /// No description provided for @bfProviderCountMany.
  ///
  /// In en, this message translates to:
  /// **'{count} providers'**
  String bfProviderCountMany(Object count);

  /// No description provided for @bfEstimatedFee.
  ///
  /// In en, this message translates to:
  /// **'Estimated fee'**
  String get bfEstimatedFee;

  /// No description provided for @bfFeeRange.
  ///
  /// In en, this message translates to:
  /// **'PHP {min} - {max}'**
  String bfFeeRange(Object min, Object max);

  /// No description provided for @bfJobsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} jobs'**
  String bfJobsCount(Object count);

  /// No description provided for @bfMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String bfMinutesShort(Object minutes);

  /// No description provided for @bfProAssigned.
  ///
  /// In en, this message translates to:
  /// **'A professional has been assigned to your request.'**
  String get bfProAssigned;

  /// No description provided for @bfProvidersBusy.
  ///
  /// In en, this message translates to:
  /// **'Providers are busy, try again'**
  String get bfProvidersBusy;

  /// No description provided for @bfAdjustOrGoHome.
  ///
  /// In en, this message translates to:
  /// **'You can adjust the booking details and retry, or head back home for now.'**
  String get bfAdjustOrGoHome;

  /// No description provided for @bfHeadingTo.
  ///
  /// In en, this message translates to:
  /// **'Heading to {locationLabel}'**
  String bfHeadingTo(Object locationLabel);

  /// No description provided for @bfNoRouteFound.
  ///
  /// In en, this message translates to:
  /// **'No route found. Showing direct path.'**
  String get bfNoRouteFound;

  /// No description provided for @bfRouteUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Route unavailable. Showing direct path.'**
  String get bfRouteUnavailable;

  /// No description provided for @bfBookingStatusText.
  ///
  /// In en, this message translates to:
  /// **'This booking has been {status}.'**
  String bfBookingStatusText(Object status);

  /// No description provided for @bfApproxEta.
  ///
  /// In en, this message translates to:
  /// **'Approximately {eta}'**
  String bfApproxEta(Object eta);

  /// No description provided for @bfStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {currentStep} of 3'**
  String bfStepOf(Object currentStep);

  /// No description provided for @bfStepOfCount.
  ///
  /// In en, this message translates to:
  /// **'Step {currentStep} of {totalSteps}'**
  String bfStepOfCount(Object currentStep, Object totalSteps);

  /// No description provided for @bfDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get bfDetails;

  /// No description provided for @bfReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get bfReview;

  /// No description provided for @bfRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get bfRetry;

  /// No description provided for @bfEstimateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the price estimate. Your draft is saved - retry or go back.'**
  String get bfEstimateUnavailable;

  /// No description provided for @bfServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get bfServices;

  /// No description provided for @bfLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get bfLocation;

  /// No description provided for @bfPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get bfPayment;

  /// No description provided for @bfTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get bfTime;

  /// No description provided for @bfSetup.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get bfSetup;

  /// No description provided for @bfScope.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get bfScope;

  /// No description provided for @bfQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get bfQuantity;

  /// No description provided for @bfRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get bfRooms;

  /// No description provided for @bfItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get bfItems;

  /// No description provided for @bfService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get bfService;

  /// No description provided for @bfDispatch.
  ///
  /// In en, this message translates to:
  /// **'Dispatch'**
  String get bfDispatch;

  /// No description provided for @bfFastest.
  ///
  /// In en, this message translates to:
  /// **'FASTEST'**
  String get bfFastest;

  /// No description provided for @bfChange.
  ///
  /// In en, this message translates to:
  /// **'CHANGE'**
  String get bfChange;

  /// No description provided for @bfLandmarks.
  ///
  /// In en, this message translates to:
  /// **'Landmarks'**
  String get bfLandmarks;

  /// No description provided for @bfLandmarksPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Bldg / Room No., Floor or Landmarks (Optional)'**
  String get bfLandmarksPlaceholder;

  /// No description provided for @bfEta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get bfEta;

  /// No description provided for @bfDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get bfDistance;

  /// No description provided for @bfRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get bfRoute;

  /// No description provided for @bfReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get bfReference;

  /// No description provided for @bfDigital.
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get bfDigital;

  /// No description provided for @bfCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get bfCash;

  /// No description provided for @bfTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get bfTotal;

  /// No description provided for @bfAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get bfAssigned;

  /// No description provided for @bfScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get bfScheduled;

  /// No description provided for @bfTotalPriceDue.
  ///
  /// In en, this message translates to:
  /// **'Total Price Due:'**
  String get bfTotalPriceDue;

  /// No description provided for @bfNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get bfNow;

  /// No description provided for @bfAsapFindingProvider.
  ///
  /// In en, this message translates to:
  /// **'ASAP - Finding nearest provider'**
  String get bfAsapFindingProvider;

  /// No description provided for @bfInstantDispatch.
  ///
  /// In en, this message translates to:
  /// **'Instant dispatch'**
  String get bfInstantDispatch;

  /// No description provided for @bfRightNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Right Now'**
  String get bfRightNowTitle;

  /// No description provided for @bfLaterTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Later Today'**
  String get bfLaterTodayTitle;

  /// No description provided for @bfBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now →'**
  String get bfBookNow;

  /// No description provided for @bfContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get bfContinue;

  /// No description provided for @bfProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get bfProfessional;

  /// No description provided for @bfProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get bfProvider;

  /// No description provided for @bfHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bfHome;

  /// No description provided for @bfStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get bfStatusConfirmed;

  /// No description provided for @bfStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bfStatusCompleted;

  /// No description provided for @bfStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bfStatusCancelled;

  /// No description provided for @bfBookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed'**
  String get bfBookingConfirmed;

  /// No description provided for @bfBookingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Booking Cancelled'**
  String get bfBookingCancelled;

  /// No description provided for @bfConfirmationPending.
  ///
  /// In en, this message translates to:
  /// **'Confirmation Pending'**
  String get bfConfirmationPending;

  /// No description provided for @bfBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get bfBack;

  /// No description provided for @bfCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get bfCall;

  /// No description provided for @bfMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get bfMessage;

  /// No description provided for @bfLevelStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get bfLevelStandard;

  /// No description provided for @bfLevelDeep.
  ///
  /// In en, this message translates to:
  /// **'Deep'**
  String get bfLevelDeep;

  /// No description provided for @bfLevelPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get bfLevelPremium;

  /// No description provided for @bfLevelBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get bfLevelBasic;

  /// No description provided for @bfLevelPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get bfLevelPriority;

  /// No description provided for @bfLevelExpress.
  ///
  /// In en, this message translates to:
  /// **'Express'**
  String get bfLevelExpress;

  /// No description provided for @bfQuantityHintDefault.
  ///
  /// In en, this message translates to:
  /// **'How many units or sessions do you need?'**
  String get bfQuantityHintDefault;

  /// No description provided for @bfQuantityHintRooms.
  ///
  /// In en, this message translates to:
  /// **'How many rooms do you want serviced?'**
  String get bfQuantityHintRooms;

  /// No description provided for @bfQuantityHintItems.
  ///
  /// In en, this message translates to:
  /// **'How many items or tasks should be covered?'**
  String get bfQuantityHintItems;

  /// No description provided for @bfProviderMustConfirmCode.
  ///
  /// In en, this message translates to:
  /// **'Provider must confirm a one-time code to start.'**
  String get bfProviderMustConfirmCode;

  /// No description provided for @bfReviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{rating} · {count} reviews'**
  String bfReviewsCount(Object rating, Object count);

  /// No description provided for @bfNewProvider.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get bfNewProvider;

  /// No description provided for @bfBookCategoryNow.
  ///
  /// In en, this message translates to:
  /// **'Book {category} Now →'**
  String bfBookCategoryNow(Object category);

  /// No description provided for @bfTodayAtTime.
  ///
  /// In en, this message translates to:
  /// **'Today at {time}'**
  String bfTodayAtTime(Object time);

  /// No description provided for @bfOnDateAtTime.
  ///
  /// In en, this message translates to:
  /// **'{month}/{day} at {time}'**
  String bfOnDateAtTime(Object month, Object day, Object time);

  /// No description provided for @bfAsapTodayAfter.
  ///
  /// In en, this message translates to:
  /// **'ASAP today after {time}'**
  String bfAsapTodayAfter(Object time);

  /// No description provided for @tmChooseJobType.
  ///
  /// In en, this message translates to:
  /// **'Choose a Job Type'**
  String get tmChooseJobType;

  /// No description provided for @tmTimeMaterialFlow.
  ///
  /// In en, this message translates to:
  /// **'Time-Material flow'**
  String get tmTimeMaterialFlow;

  /// No description provided for @tmPickClosestJobType.
  ///
  /// In en, this message translates to:
  /// **'Pick the closest job type so we can give a tighter estimate before searching for nearby providers.'**
  String get tmPickClosestJobType;

  /// No description provided for @tmEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get tmEstimate;

  /// No description provided for @tmEstimatedServiceFee.
  ///
  /// In en, this message translates to:
  /// **'Estimated service fee'**
  String get tmEstimatedServiceFee;

  /// No description provided for @tmFinalChargesMayChange.
  ///
  /// In en, this message translates to:
  /// **'Final charges may change depending on distance, job complexity, and hardware parts approved during the visit.'**
  String get tmFinalChargesMayChange;

  /// No description provided for @tmOnDemandDispatch.
  ///
  /// In en, this message translates to:
  /// **'On-demand dispatch'**
  String get tmOnDemandDispatch;

  /// No description provided for @tmSearchNearbyFirst.
  ///
  /// In en, this message translates to:
  /// **'We will search for nearby providers first before falling back to a wider search radius.'**
  String get tmSearchNearbyFirst;

  /// No description provided for @tmTimePlusMaterials.
  ///
  /// In en, this message translates to:
  /// **'Time + materials'**
  String get tmTimePlusMaterials;

  /// No description provided for @tmLaborEstimatedUpfront.
  ///
  /// In en, this message translates to:
  /// **'Labor is estimated up front. Hardware and parts can be added only if you approve them later.'**
  String get tmLaborEstimatedUpfront;

  /// No description provided for @tmFindProvider.
  ///
  /// In en, this message translates to:
  /// **'Find Provider'**
  String get tmFindProvider;

  /// No description provided for @tmExpandedRadiusSearch.
  ///
  /// In en, this message translates to:
  /// **'Expanded radius search'**
  String get tmExpandedRadiusSearch;

  /// No description provided for @tmNoProviderFoundYet.
  ///
  /// In en, this message translates to:
  /// **'No provider found yet'**
  String get tmNoProviderFoundYet;

  /// No description provided for @tmSearchingNearbyProviders.
  ///
  /// In en, this message translates to:
  /// **'Searching nearby providers'**
  String get tmSearchingNearbyProviders;

  /// No description provided for @tmWidenedSearchRadius.
  ///
  /// In en, this message translates to:
  /// **'We widened the search radius to reach more active providers.'**
  String get tmWidenedSearchRadius;

  /// No description provided for @tmNearbyExpandedTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Nearby and expanded searches both timed out.'**
  String get tmNearbyExpandedTimedOut;

  /// No description provided for @tmBroadcastingRequest.
  ///
  /// In en, this message translates to:
  /// **'Broadcasting your request to active providers near your pin.'**
  String get tmBroadcastingRequest;

  /// No description provided for @tmTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Timed out'**
  String get tmTimedOut;

  /// No description provided for @tmLookingForProvider.
  ///
  /// In en, this message translates to:
  /// **'Looking for a provider'**
  String get tmLookingForProvider;

  /// No description provided for @tmCouldNotSecureProvider.
  ///
  /// In en, this message translates to:
  /// **'We could not secure a provider from the current search cycle.'**
  String get tmCouldNotSecureProvider;

  /// No description provided for @tmStayOnScreen.
  ///
  /// In en, this message translates to:
  /// **'Stay on this screen while we keep your request active and visible to nearby providers.'**
  String get tmStayOnScreen;

  /// No description provided for @tmSearchRadius.
  ///
  /// In en, this message translates to:
  /// **'Search radius'**
  String get tmSearchRadius;

  /// No description provided for @tmCurrentlyScanning.
  ///
  /// In en, this message translates to:
  /// **'Currently scanning providers within 4-8 km of your pin depending on the current search phase.'**
  String get tmCurrentlyScanning;

  /// No description provided for @tmDynamicFees.
  ///
  /// In en, this message translates to:
  /// **'Dynamic fees'**
  String get tmDynamicFees;

  /// No description provided for @tmExpandedMayIncreaseFee.
  ///
  /// In en, this message translates to:
  /// **'Expanded searches may increase the service fee based on travel distance.'**
  String get tmExpandedMayIncreaseFee;

  /// No description provided for @tmSearchReference.
  ///
  /// In en, this message translates to:
  /// **'Search reference'**
  String get tmSearchReference;

  /// No description provided for @tmCancelSearch.
  ///
  /// In en, this message translates to:
  /// **'Cancel Search'**
  String get tmCancelSearch;

  /// No description provided for @tmNoProviderFound.
  ///
  /// In en, this message translates to:
  /// **'No provider found'**
  String get tmNoProviderFound;

  /// No description provided for @tmFinishedSearchWindows.
  ///
  /// In en, this message translates to:
  /// **'We finished both search windows without a provider match. You can retry, switch to the scheduled flow, or head back home.'**
  String get tmFinishedSearchWindows;

  /// No description provided for @tmSearchAgain.
  ///
  /// In en, this message translates to:
  /// **'Search again'**
  String get tmSearchAgain;

  /// No description provided for @tmScheduleInstead.
  ///
  /// In en, this message translates to:
  /// **'Schedule instead'**
  String get tmScheduleInstead;

  /// No description provided for @tmExpandingSearchNotice.
  ///
  /// In en, this message translates to:
  /// **'Expanding Search... Service Fee may increase by 50-100 per km'**
  String get tmExpandingSearchNotice;

  /// No description provided for @tmActiveJob.
  ///
  /// In en, this message translates to:
  /// **'Active Job'**
  String get tmActiveJob;

  /// No description provided for @tmAdditionalCost.
  ///
  /// In en, this message translates to:
  /// **'Additional cost: Php {amount}'**
  String tmAdditionalCost(Object amount);

  /// No description provided for @tmReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get tmReject;

  /// No description provided for @tmApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get tmApprove;

  /// No description provided for @tmOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get tmOnTheWay;

  /// No description provided for @tmLiveJobTracking.
  ///
  /// In en, this message translates to:
  /// **'Live job tracking'**
  String get tmLiveJobTracking;

  /// No description provided for @tmHeadingToLocation.
  ///
  /// In en, this message translates to:
  /// **'{name} is heading to your location. If additional hardware is needed, you will see an approval prompt here.'**
  String tmHeadingToLocation(Object name);

  /// No description provided for @tmApprovedHardware.
  ///
  /// In en, this message translates to:
  /// **'Approved hardware: Php {amount}'**
  String tmApprovedHardware(Object amount);

  /// No description provided for @tmMarkJobComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Job Complete'**
  String get tmMarkJobComplete;

  /// No description provided for @tmRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get tmRating;

  /// No description provided for @tmCompletedJobs.
  ///
  /// In en, this message translates to:
  /// **'Completed jobs'**
  String get tmCompletedJobs;

  /// No description provided for @tmVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get tmVehicle;

  /// No description provided for @tmPayForService.
  ///
  /// In en, this message translates to:
  /// **'Pay for Service'**
  String get tmPayForService;

  /// No description provided for @tmAmountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount due'**
  String get tmAmountDue;

  /// No description provided for @tmFastMobileWallet.
  ///
  /// In en, this message translates to:
  /// **'Fast mobile wallet payment'**
  String get tmFastMobileWallet;

  /// No description provided for @tmRecordSettlement.
  ///
  /// In en, this message translates to:
  /// **'Record settlement after direct payment'**
  String get tmRecordSettlement;

  /// No description provided for @tmPayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get tmPayNow;

  /// No description provided for @tmRateYourService.
  ///
  /// In en, this message translates to:
  /// **'Rate your service'**
  String get tmRateYourService;

  /// No description provided for @tmHowWasExperience.
  ///
  /// In en, this message translates to:
  /// **'How was the time-material service experience with {name}?'**
  String tmHowWasExperience(Object name);

  /// No description provided for @tmSubmitRating.
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get tmSubmitRating;

  /// No description provided for @tmHowWasExperienceNoName.
  ///
  /// In en, this message translates to:
  /// **'How was your time-material service experience?'**
  String get tmHowWasExperienceNoName;

  /// No description provided for @tmFinalInvoice.
  ///
  /// In en, this message translates to:
  /// **'Final Invoice'**
  String get tmFinalInvoice;

  /// No description provided for @tmBaseLaborFee.
  ///
  /// In en, this message translates to:
  /// **'Base labor fee'**
  String get tmBaseLaborFee;

  /// No description provided for @tmApprovedHardwareLabel.
  ///
  /// In en, this message translates to:
  /// **'Approved hardware'**
  String get tmApprovedHardwareLabel;

  /// No description provided for @tmTotalDue.
  ///
  /// In en, this message translates to:
  /// **'Total due'**
  String get tmTotalDue;

  /// No description provided for @tmFinalAmountReflects.
  ///
  /// In en, this message translates to:
  /// **'Your final amount reflects the labor fee plus any hardware you approved during the active job.'**
  String get tmFinalAmountReflects;

  /// No description provided for @tmErrorApproveHardware.
  ///
  /// In en, this message translates to:
  /// **'Could not approve the hardware request right now.'**
  String get tmErrorApproveHardware;

  /// No description provided for @tmErrorRejectHardware.
  ///
  /// In en, this message translates to:
  /// **'Could not reject the hardware request right now.'**
  String get tmErrorRejectHardware;

  /// No description provided for @tmErrorMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Could not mark the job complete right now.'**
  String get tmErrorMarkComplete;

  /// No description provided for @tmErrorMissingBookingRef.
  ///
  /// In en, this message translates to:
  /// **'Missing booking reference for this payment.'**
  String get tmErrorMissingBookingRef;

  /// No description provided for @tmErrorPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment could not be processed right now.'**
  String get tmErrorPaymentFailed;

  /// No description provided for @tmErrorMissingRatingRef.
  ///
  /// In en, this message translates to:
  /// **'Missing provider or booking reference for rating.'**
  String get tmErrorMissingRatingRef;

  /// No description provided for @tmErrorSubmitRating.
  ///
  /// In en, this message translates to:
  /// **'Could not submit your rating right now.'**
  String get tmErrorSubmitRating;

  /// No description provided for @tmErrorCancelSearch.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel the search right now.'**
  String get tmErrorCancelSearch;

  /// No description provided for @tmCatHomeLockout.
  ///
  /// In en, this message translates to:
  /// **'Door unlocking, basic lock access, and urgent entry help.'**
  String get tmCatHomeLockout;

  /// No description provided for @tmCatLockRepair.
  ///
  /// In en, this message translates to:
  /// **'Minor repairs, stuck cylinders, and latch adjustments.'**
  String get tmCatLockRepair;

  /// No description provided for @tmCatLockReplacement.
  ///
  /// In en, this message translates to:
  /// **'Replace damaged locks. Hardware cost may be added later.'**
  String get tmCatLockReplacement;

  /// No description provided for @tmCatPipeLeak.
  ///
  /// In en, this message translates to:
  /// **'Urgent leak isolation, sealing, and connector replacement.'**
  String get tmCatPipeLeak;

  /// No description provided for @tmCatFaucetIssue.
  ///
  /// In en, this message translates to:
  /// **'Loose fittings, weak flow, and valve troubleshooting.'**
  String get tmCatFaucetIssue;

  /// No description provided for @tmCatDrainClog.
  ///
  /// In en, this message translates to:
  /// **'Sink, bathroom, and floor drain unclogging support.'**
  String get tmCatDrainClog;

  /// No description provided for @tmCatOutletIssue.
  ///
  /// In en, this message translates to:
  /// **'Fault isolation, rewiring checks, and safe restoration.'**
  String get tmCatOutletIssue;

  /// No description provided for @tmCatBreakerTrip.
  ///
  /// In en, this message translates to:
  /// **'Short circuit diagnostics and load troubleshooting.'**
  String get tmCatBreakerTrip;

  /// No description provided for @tmCatLighting.
  ///
  /// In en, this message translates to:
  /// **'Fixture checks, ballast replacement, and rewiring.'**
  String get tmCatLighting;

  /// No description provided for @tmCatWasherDryer.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics, disassembly, and repair recommendations.'**
  String get tmCatWasherDryer;

  /// No description provided for @tmCatRefrigerator.
  ///
  /// In en, this message translates to:
  /// **'Cooling, leakage, or electrical troubleshooting visit.'**
  String get tmCatRefrigerator;

  /// No description provided for @tmCatSmallAppliance.
  ///
  /// In en, this message translates to:
  /// **'Inspection and repair of common home appliances.'**
  String get tmCatSmallAppliance;

  /// No description provided for @tmCatQuickRepair.
  ///
  /// In en, this message translates to:
  /// **'Fast troubleshooting and basic repair support.'**
  String get tmCatQuickRepair;

  /// No description provided for @tmCatDiagnostic.
  ///
  /// In en, this message translates to:
  /// **'Problem isolation before labor and materials are finalized.'**
  String get tmCatDiagnostic;

  /// No description provided for @tmCatUrgentAssistance.
  ///
  /// In en, this message translates to:
  /// **'Immediate help for time-sensitive home service issues.'**
  String get tmCatUrgentAssistance;

  /// No description provided for @afEditAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit address'**
  String get afEditAddress;

  /// No description provided for @afNewAddress.
  ///
  /// In en, this message translates to:
  /// **'New address'**
  String get afNewAddress;

  /// No description provided for @afContactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get afContactInformation;

  /// No description provided for @afAddressDetails.
  ///
  /// In en, this message translates to:
  /// **'Address Details'**
  String get afAddressDetails;

  /// No description provided for @afPinLocation.
  ///
  /// In en, this message translates to:
  /// **'Pin Location'**
  String get afPinLocation;

  /// No description provided for @afLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get afLabel;

  /// No description provided for @afFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get afFullName;

  /// No description provided for @afEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get afEnterFullName;

  /// No description provided for @afMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get afMobileNumber;

  /// No description provided for @afStreetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street address'**
  String get afStreetAddress;

  /// No description provided for @afHouseUnitStreet.
  ///
  /// In en, this message translates to:
  /// **'House/Unit number, Street name'**
  String get afHouseUnitStreet;

  /// No description provided for @afPostalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get afPostalCode;

  /// No description provided for @afEnterPostalCode.
  ///
  /// In en, this message translates to:
  /// **'Enter postal code'**
  String get afEnterPostalCode;

  /// No description provided for @afSearchBarangay.
  ///
  /// In en, this message translates to:
  /// **'Search barangay...'**
  String get afSearchBarangay;

  /// No description provided for @afErrorFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get afErrorFullName;

  /// No description provided for @afErrorMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your mobile number'**
  String get afErrorMobileNumber;

  /// No description provided for @afErrorValidMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid mobile number'**
  String get afErrorValidMobile;

  /// No description provided for @afErrorStreetAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter your street address'**
  String get afErrorStreetAddress;

  /// No description provided for @afRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get afRegion;

  /// No description provided for @afSelectRegion.
  ///
  /// In en, this message translates to:
  /// **'Select region'**
  String get afSelectRegion;

  /// No description provided for @afProvince.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get afProvince;

  /// No description provided for @afSelectProvince.
  ///
  /// In en, this message translates to:
  /// **'Select province'**
  String get afSelectProvince;

  /// No description provided for @afCityMunicipality.
  ///
  /// In en, this message translates to:
  /// **'City/Municipality'**
  String get afCityMunicipality;

  /// No description provided for @afSelectCity.
  ///
  /// In en, this message translates to:
  /// **'Select city/municipality'**
  String get afSelectCity;

  /// No description provided for @afBarangay.
  ///
  /// In en, this message translates to:
  /// **'Barangay'**
  String get afBarangay;

  /// No description provided for @afSelectBarangay.
  ///
  /// In en, this message translates to:
  /// **'Select barangay'**
  String get afSelectBarangay;

  /// No description provided for @afSelectBarangayTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Barangay'**
  String get afSelectBarangayTitle;

  /// No description provided for @afNoBarangays.
  ///
  /// In en, this message translates to:
  /// **'No barangays available for this city/municipality'**
  String get afNoBarangays;

  /// No description provided for @afNoBarangaysFound.
  ///
  /// In en, this message translates to:
  /// **'No barangays found'**
  String get afNoBarangaysFound;

  /// No description provided for @afSetAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default address'**
  String get afSetAsDefault;

  /// No description provided for @afUpdateAddress.
  ///
  /// In en, this message translates to:
  /// **'Update address'**
  String get afUpdateAddress;

  /// No description provided for @afSaveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save address'**
  String get afSaveAddress;

  /// No description provided for @afPinLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pin location on map (optional)'**
  String get afPinLocationOnMap;

  /// No description provided for @afChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get afChange;

  /// No description provided for @afAddressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Address updated successfully'**
  String get afAddressUpdated;

  /// No description provided for @afAddressAdded.
  ///
  /// In en, this message translates to:
  /// **'Address added successfully'**
  String get afAddressAdded;

  /// No description provided for @afAddressDeleted.
  ///
  /// In en, this message translates to:
  /// **'Address deleted successfully'**
  String get afAddressDeleted;

  /// No description provided for @afErrorSavingAddress.
  ///
  /// In en, this message translates to:
  /// **'Error saving address'**
  String get afErrorSavingAddress;

  /// No description provided for @afErrorSavingAddressDetail.
  ///
  /// In en, this message translates to:
  /// **'Error saving address: {e}'**
  String afErrorSavingAddressDetail(Object e);

  /// No description provided for @afErrorLoadingAddress.
  ///
  /// In en, this message translates to:
  /// **'Error loading address: {e}'**
  String afErrorLoadingAddress(Object e);

  /// No description provided for @afErrorDeletingAddress.
  ///
  /// In en, this message translates to:
  /// **'Error deleting address: {e}'**
  String afErrorDeletingAddress(Object e);

  /// No description provided for @afDeleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Delete address'**
  String get afDeleteAddress;

  /// No description provided for @afDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this address?'**
  String get afDeleteConfirm;

  /// No description provided for @afCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get afCancel;

  /// No description provided for @afDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get afDelete;

  /// No description provided for @bdBookingIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Booking ID is required'**
  String get bdBookingIdRequired;

  /// No description provided for @bdBookingNotFound.
  ///
  /// In en, this message translates to:
  /// **'Booking not found'**
  String get bdBookingNotFound;

  /// No description provided for @bdFailedLoadBooking.
  ///
  /// In en, this message translates to:
  /// **'Failed to load booking: {e}'**
  String bdFailedLoadBooking(Object e);

  /// No description provided for @bdCouldNotLoadBooking.
  ///
  /// In en, this message translates to:
  /// **'Could not load booking'**
  String get bdCouldNotLoadBooking;

  /// No description provided for @bdRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get bdRetry;

  /// No description provided for @bdNoBookingData.
  ///
  /// In en, this message translates to:
  /// **'No booking data'**
  String get bdNoBookingData;

  /// No description provided for @bdBookingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This booking could not be found or is no longer available.'**
  String get bdBookingUnavailable;

  /// No description provided for @bdGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get bdGoBack;

  /// No description provided for @bdCancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get bdCancelBooking;

  /// No description provided for @bdCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this booking?'**
  String get bdCancelConfirm;

  /// No description provided for @bdNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get bdNo;

  /// No description provided for @bdYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get bdYes;

  /// No description provided for @bdCancelledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled successfully'**
  String get bdCancelledSuccessfully;

  /// No description provided for @bdFailedCancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel booking'**
  String get bdFailedCancelBooking;

  /// No description provided for @bdAssignedProvider.
  ///
  /// In en, this message translates to:
  /// **'Assigned Provider'**
  String get bdAssignedProvider;

  /// No description provided for @bdYourBooking.
  ///
  /// In en, this message translates to:
  /// **'Your booking'**
  String get bdYourBooking;

  /// No description provided for @bdNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get bdNew;

  /// No description provided for @bdServiceProfessional.
  ///
  /// In en, this message translates to:
  /// **'Service professional'**
  String get bdServiceProfessional;

  /// No description provided for @bdCallProvider.
  ///
  /// In en, this message translates to:
  /// **'Call provider'**
  String get bdCallProvider;

  /// No description provided for @bdMessageProvider.
  ///
  /// In en, this message translates to:
  /// **'Message provider'**
  String get bdMessageProvider;

  /// No description provided for @bdServiceProgress.
  ///
  /// In en, this message translates to:
  /// **'Service progress'**
  String get bdServiceProgress;

  /// No description provided for @bdThisBookingCancelled.
  ///
  /// In en, this message translates to:
  /// **'This booking was cancelled.'**
  String get bdThisBookingCancelled;

  /// No description provided for @bdBookingPlaced.
  ///
  /// In en, this message translates to:
  /// **'Booking placed'**
  String get bdBookingPlaced;

  /// No description provided for @bdProviderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Provider confirmed'**
  String get bdProviderConfirmed;

  /// No description provided for @bdArrivedOnSite.
  ///
  /// In en, this message translates to:
  /// **'Arrived on site'**
  String get bdArrivedOnSite;

  /// No description provided for @bdServiceInProgress.
  ///
  /// In en, this message translates to:
  /// **'Service in progress'**
  String get bdServiceInProgress;

  /// No description provided for @bdCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bdCompleted;

  /// No description provided for @bdBookingInformation.
  ///
  /// In en, this message translates to:
  /// **'Booking information'**
  String get bdBookingInformation;

  /// No description provided for @bdInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Core scheduling, payment, and location details.'**
  String get bdInfoSubtitle;

  /// No description provided for @bdBookingId.
  ///
  /// In en, this message translates to:
  /// **'Booking ID'**
  String get bdBookingId;

  /// No description provided for @bdDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get bdDateAndTime;

  /// No description provided for @bdStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get bdStatus;

  /// No description provided for @bdPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment status'**
  String get bdPaymentStatus;

  /// No description provided for @bdPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get bdPending;

  /// No description provided for @bdServiceLocation.
  ///
  /// In en, this message translates to:
  /// **'Service location'**
  String get bdServiceLocation;

  /// No description provided for @bdNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get bdNotes;

  /// No description provided for @bdNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Special instructions attached to this booking.'**
  String get bdNotesSubtitle;

  /// No description provided for @bdSharedAfterAssignment.
  ///
  /// In en, this message translates to:
  /// **'Shared with your provider after assignment'**
  String get bdSharedAfterAssignment;

  /// No description provided for @bdBookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bdBookingDetails;

  /// No description provided for @bdHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review progress, schedule, and payment state.'**
  String get bdHeaderSubtitle;

  /// No description provided for @bdUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get bdUnknown;

  /// No description provided for @bdConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get bdConfirmed;

  /// No description provided for @bdInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get bdInProgress;

  /// No description provided for @bdCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bdCancelled;

  /// No description provided for @ssSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get ssSecurity;

  /// No description provided for @ssSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Protect your account, password, and sign-in access.'**
  String get ssSubtitle;

  /// No description provided for @ssHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your account protected'**
  String get ssHeroTitle;

  /// No description provided for @ssHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage password strength, 2FA, and recent account access in one place.'**
  String get ssHeroSubtitle;

  /// No description provided for @ssPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get ssPassword;

  /// No description provided for @ssCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get ssCurrentPassword;

  /// No description provided for @ssEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get ssEnterCurrentPassword;

  /// No description provided for @ssCurrentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get ssCurrentPasswordRequired;

  /// No description provided for @ssNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get ssNewPassword;

  /// No description provided for @ssEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get ssEnterNewPassword;

  /// No description provided for @ssNewPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get ssNewPasswordRequired;

  /// No description provided for @ssPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get ssPasswordMinLength;

  /// No description provided for @ssConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get ssConfirmNewPassword;

  /// No description provided for @ssReenterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your new password'**
  String get ssReenterNewPassword;

  /// No description provided for @ssConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get ssConfirmPasswordRequired;

  /// No description provided for @ssPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get ssPasswordsDoNotMatch;

  /// No description provided for @ssChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get ssChangePassword;

  /// No description provided for @ssPasswordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email. Use it to set a new password.'**
  String get ssPasswordResetSent;

  /// No description provided for @ssErrorPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'Error changing password: {e}'**
  String ssErrorPasswordReset(Object e);

  /// No description provided for @ssTwoFactorAuth.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get ssTwoFactorAuth;

  /// No description provided for @ssSecureYourLogin.
  ///
  /// In en, this message translates to:
  /// **'Secure your login'**
  String get ssSecureYourLogin;

  /// No description provided for @ssAuthenticatorApp.
  ///
  /// In en, this message translates to:
  /// **'Use an authenticator app to add a second step during sign in.'**
  String get ssAuthenticatorApp;

  /// No description provided for @ss2FAEnrollmentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'2FA enrollment is not available yet.'**
  String get ss2FAEnrollmentUnavailable;

  /// No description provided for @ss2FAManagementUnavailable.
  ///
  /// In en, this message translates to:
  /// **'2FA management is not available yet.'**
  String get ss2FAManagementUnavailable;

  /// No description provided for @ssErrorEnrolling2FA.
  ///
  /// In en, this message translates to:
  /// **'Error enrolling 2FA: {e}'**
  String ssErrorEnrolling2FA(Object e);

  /// No description provided for @ssErrorDisabling2FA.
  ///
  /// In en, this message translates to:
  /// **'Error disabling 2FA: {e}'**
  String ssErrorDisabling2FA(Object e);

  /// No description provided for @ssLoginActivity.
  ///
  /// In en, this message translates to:
  /// **'Login Activity'**
  String get ssLoginActivity;

  /// No description provided for @ssNoActiveSessions.
  ///
  /// In en, this message translates to:
  /// **'No active sessions were returned for this account yet.'**
  String get ssNoActiveSessions;

  /// No description provided for @ssCurrentDevice.
  ///
  /// In en, this message translates to:
  /// **'Current device'**
  String get ssCurrentDevice;

  /// No description provided for @ssOtherSignIn.
  ///
  /// In en, this message translates to:
  /// **'Other sign-in'**
  String get ssOtherSignIn;

  /// No description provided for @ssActiveNow.
  ///
  /// In en, this message translates to:
  /// **'Active now'**
  String get ssActiveNow;

  /// No description provided for @ssUnknownDevice.
  ///
  /// In en, this message translates to:
  /// **'Unknown device'**
  String get ssUnknownDevice;

  /// No description provided for @ssLastActive.
  ///
  /// In en, this message translates to:
  /// **'Last active {time}'**
  String ssLastActive(Object time);

  /// No description provided for @ssJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get ssJustNow;

  /// No description provided for @ssMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String ssMinutesAgo(Object count);

  /// No description provided for @ssHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String ssHoursAgo(Object count);

  /// No description provided for @ssYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get ssYesterday;

  /// No description provided for @ssDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String ssDaysAgo(Object count);

  /// No description provided for @siWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Serbisyo'**
  String get siWelcome;

  /// No description provided for @siWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue with your home services.'**
  String get siWelcomeSubtitle;

  /// No description provided for @siPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get siPhone;

  /// No description provided for @siEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get siEmail;

  /// No description provided for @siMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get siMobileNumber;

  /// No description provided for @siPhoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone Number is required and has to start with +.'**
  String get siPhoneNumberRequired;

  /// No description provided for @siEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get siEmailAddress;

  /// No description provided for @siInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get siInvalidEmail;

  /// No description provided for @siPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get siPassword;

  /// No description provided for @siEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get siEnterPassword;

  /// No description provided for @siInvalidEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get siInvalidEmailOrPassword;

  /// No description provided for @siSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get siSignIn;

  /// No description provided for @siSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing In...'**
  String get siSigningIn;

  /// No description provided for @siForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get siForgotPassword;

  /// No description provided for @siNoAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet?'**
  String get siNoAccountYet;

  /// No description provided for @siSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get siSignUp;

  /// No description provided for @siOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get siOrContinueWith;

  /// No description provided for @siContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get siContinueWithGoogle;

  /// No description provided for @siContinueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get siContinueWithApple;

  /// No description provided for @siGoogleComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in coming soon'**
  String get siGoogleComingSoon;

  /// No description provided for @siAppleComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in coming soon'**
  String get siAppleComingSoon;

  /// No description provided for @spHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get spHeaderTitle;

  /// No description provided for @spHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse services with filters that actually help.'**
  String get spHeaderSubtitle;

  /// No description provided for @spSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for services...'**
  String get spSearchPlaceholder;

  /// No description provided for @spVoiceSearchNoResult.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t catch that. Try again or type your search.'**
  String get spVoiceSearchNoResult;

  /// No description provided for @spVoiceSearchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Voice search isn\'t available on this device. Please type your search instead.'**
  String get spVoiceSearchUnavailable;

  /// No description provided for @spEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Search for services'**
  String get spEmptyTitle;

  /// No description provided for @spEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try keywords like cleaning, painting, or plumbing.'**
  String get spEmptySubtitle;

  /// No description provided for @spBrowseAllServices.
  ///
  /// In en, this message translates to:
  /// **'Browse all services'**
  String get spBrowseAllServices;

  /// No description provided for @spAllServices.
  ///
  /// In en, this message translates to:
  /// **'All services'**
  String get spAllServices;

  /// No description provided for @spCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get spCategory;

  /// No description provided for @spAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get spAll;

  /// No description provided for @spMinRating.
  ///
  /// In en, this message translates to:
  /// **'Minimum rating'**
  String get spMinRating;

  /// No description provided for @spPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get spPrice;

  /// No description provided for @spDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get spDefault;

  /// No description provided for @spLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Low to High'**
  String get spLowToHigh;

  /// No description provided for @spHighToLow.
  ///
  /// In en, this message translates to:
  /// **'High to Low'**
  String get spHighToLow;

  /// No description provided for @spResetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get spResetFilters;

  /// No description provided for @spClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get spClearFilters;

  /// No description provided for @spRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get spRecentSearches;

  /// No description provided for @spRecentBookings.
  ///
  /// In en, this message translates to:
  /// **'Recent bookings'**
  String get spRecentBookings;

  /// No description provided for @spNoServicesFound.
  ///
  /// In en, this message translates to:
  /// **'No services found'**
  String get spNoServicesFound;

  /// No description provided for @spNoResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try another keyword, open a broader category, or clear your filters.'**
  String get spNoResultsSubtitle;

  /// No description provided for @spServiceFallback.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get spServiceFallback;

  /// No description provided for @seTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get seTitle;

  /// No description provided for @seSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage preferences, account, and support options.'**
  String get seSubtitle;

  /// No description provided for @seHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Control your app experience'**
  String get seHeroTitle;

  /// No description provided for @seHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance, security, notifications, and support all live here.'**
  String get seHeroSubtitle;

  /// No description provided for @seGeneralSection.
  ///
  /// In en, this message translates to:
  /// **'General & Account Configuration'**
  String get seGeneralSection;

  /// No description provided for @seLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get seLanguage;

  /// No description provided for @seLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used across the app'**
  String get seLanguageSubtitle;

  /// No description provided for @seNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get seNotifications;

  /// No description provided for @seNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review booking, message, and payment updates'**
  String get seNotificationsSubtitle;

  /// No description provided for @seSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get seSecurity;

  /// No description provided for @seSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Password, login protection, and 2FA settings'**
  String get seSecuritySubtitle;

  /// No description provided for @seEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get seEditProfile;

  /// No description provided for @seEditProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your personal registration information'**
  String get seEditProfileSubtitle;

  /// No description provided for @seLegalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal & Feedback'**
  String get seLegalSection;

  /// No description provided for @seSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get seSendFeedback;

  /// No description provided for @seSendFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open an email draft to share product feedback'**
  String get seSendFeedbackSubtitle;

  /// No description provided for @seTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get seTermsTitle;

  /// No description provided for @seTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read the terms governing your use of Serbisyo'**
  String get seTermsSubtitle;

  /// No description provided for @sePrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get sePrivacyTitle;

  /// No description provided for @sePrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Understand how we collect and use your data'**
  String get sePrivacySubtitle;

  /// No description provided for @seLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get seLogOut;

  /// No description provided for @seLogOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get seLogOutConfirm;

  /// No description provided for @seCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get seCancel;

  /// No description provided for @seSignOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account on this device'**
  String get seSignOutSubtitle;

  /// No description provided for @seCouldNotLaunchUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not launch URL'**
  String get seCouldNotLaunchUrl;

  /// No description provided for @thTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get thTitle;

  /// No description provided for @thTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get thTheme;

  /// No description provided for @thLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get thLight;

  /// No description provided for @thDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get thDark;

  /// No description provided for @thSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get thSystemDefault;

  /// No description provided for @thLightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always use light mode'**
  String get thLightSubtitle;

  /// No description provided for @thDarkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always use dark mode'**
  String get thDarkSubtitle;

  /// No description provided for @thSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow device settings'**
  String get thSystemSubtitle;

  /// No description provided for @lgTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get lgTitle;

  /// No description provided for @lgSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the preferred language for your app experience.'**
  String get lgSubtitle;

  /// No description provided for @lgCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current language'**
  String get lgCurrent;

  /// No description provided for @lgChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String lgChanged(Object language);

  /// No description provided for @npTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get npTitle;

  /// No description provided for @npPush.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get npPush;

  /// No description provided for @bpSelectPayment.
  ///
  /// In en, this message translates to:
  /// **'Select Payment'**
  String get bpSelectPayment;

  /// No description provided for @bpSelectPaymentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review the booking and choose how you want to pay.'**
  String get bpSelectPaymentSubtitle;

  /// No description provided for @bpChooseHowToPay.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to pay'**
  String get bpChooseHowToPay;

  /// No description provided for @bpEscrowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Card, wallet, and QR payments are protected through escrow until the job is completed.'**
  String get bpEscrowSubtitle;

  /// No description provided for @bpCard.
  ///
  /// In en, this message translates to:
  /// **'Credit / Debit Card'**
  String get bpCard;

  /// No description provided for @bpCardSub.
  ///
  /// In en, this message translates to:
  /// **'Visa, Mastercard'**
  String get bpCardSub;

  /// No description provided for @bpEwallet.
  ///
  /// In en, this message translates to:
  /// **'E-Wallets'**
  String get bpEwallet;

  /// No description provided for @bpEwalletSub.
  ///
  /// In en, this message translates to:
  /// **'GCash, Maya'**
  String get bpEwalletSub;

  /// No description provided for @bpQr.
  ///
  /// In en, this message translates to:
  /// **'QR Ph Code'**
  String get bpQr;

  /// No description provided for @bpQrSub.
  ///
  /// In en, this message translates to:
  /// **'Standard Philippine digital QR'**
  String get bpQrSub;

  /// No description provided for @bpCash.
  ///
  /// In en, this message translates to:
  /// **'Cash on Completion'**
  String get bpCash;

  /// No description provided for @bpCashSub.
  ///
  /// In en, this message translates to:
  /// **'Pay the pro directly after the job'**
  String get bpCashSub;

  /// No description provided for @bpSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking summary'**
  String get bpSummaryTitle;

  /// No description provided for @bpDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get bpDate;

  /// No description provided for @bpTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get bpTime;

  /// No description provided for @bpNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get bpNotes;

  /// No description provided for @bpNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get bpNotSet;

  /// No description provided for @bpTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get bpTotal;

  /// No description provided for @bpProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get bpProcessing;

  /// No description provided for @bpConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get bpConfirm;

  /// No description provided for @bpSelectMethod.
  ///
  /// In en, this message translates to:
  /// **'Please select a payment method'**
  String get bpSelectMethod;

  /// No description provided for @bpEscrowNotice.
  ///
  /// In en, this message translates to:
  /// **'Card, e-wallet, and QR payments are held in escrow. The provider receives the funds only after you confirm the work is done from your bookings page.'**
  String get bpEscrowNotice;

  /// No description provided for @bpConfirmSlot.
  ///
  /// In en, this message translates to:
  /// **'You will confirm a slot shortly'**
  String get bpConfirmSlot;

  /// No description provided for @bpFailedCreate.
  ///
  /// In en, this message translates to:
  /// **'Failed to create booking.'**
  String get bpFailedCreate;

  /// No description provided for @bpPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get bpPaymentFailed;

  /// No description provided for @bsTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed'**
  String get bsTitle;

  /// No description provided for @bsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your request has been created successfully and the provider will be notified shortly.'**
  String get bsSubtitle;

  /// No description provided for @bsNextTitle.
  ///
  /// In en, this message translates to:
  /// **'What happens next'**
  String get bsNextTitle;

  /// No description provided for @bsNextDesc.
  ///
  /// In en, this message translates to:
  /// **'You can track the request from your bookings page and we will keep you updated as the status changes.'**
  String get bsNextDesc;

  /// No description provided for @bsProtectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment protection'**
  String get bsProtectionTitle;

  /// No description provided for @bsProtectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Escrow-enabled payments stay protected until the work is completed and confirmed.'**
  String get bsProtectionDesc;

  /// No description provided for @bsViewBookings.
  ///
  /// In en, this message translates to:
  /// **'View Bookings'**
  String get bsViewBookings;

  /// No description provided for @bsBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get bsBackHome;

  /// No description provided for @bkTitle.
  ///
  /// In en, this message translates to:
  /// **'Book Service'**
  String get bkTitle;

  /// No description provided for @bkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your schedule and location before payment.'**
  String get bkSubtitle;

  /// No description provided for @bkSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get bkSelectDate;

  /// No description provided for @bkSelectDateSub.
  ///
  /// In en, this message translates to:
  /// **'Pick the day you want the provider to arrive.'**
  String get bkSelectDateSub;

  /// No description provided for @bkSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get bkSelectTime;

  /// No description provided for @bkSelectTimeSub.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred appointment window.'**
  String get bkSelectTimeSub;

  /// No description provided for @bkServiceAddress.
  ///
  /// In en, this message translates to:
  /// **'Service Address'**
  String get bkServiceAddress;

  /// No description provided for @bkServiceAddressSub.
  ///
  /// In en, this message translates to:
  /// **'Tell the provider exactly where the work happens.'**
  String get bkServiceAddressSub;

  /// No description provided for @bkAdditionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get bkAdditionalNotes;

  /// No description provided for @bkAdditionalNotesSub.
  ///
  /// In en, this message translates to:
  /// **'Share instructions, landmarks, or preparation details.'**
  String get bkAdditionalNotesSub;

  /// No description provided for @bkNotesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add any special instructions...'**
  String get bkNotesPlaceholder;

  /// No description provided for @bkSelectDateAction.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get bkSelectDateAction;

  /// No description provided for @bkSelectTimeAction.
  ///
  /// In en, this message translates to:
  /// **'Select a time'**
  String get bkSelectTimeAction;

  /// No description provided for @bkSelectServiceAddress.
  ///
  /// In en, this message translates to:
  /// **'Select service address'**
  String get bkSelectServiceAddress;

  /// No description provided for @bkSelectedAddress.
  ///
  /// In en, this message translates to:
  /// **'Selected address'**
  String get bkSelectedAddress;

  /// No description provided for @bkTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get bkTotal;

  /// No description provided for @bkProceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get bkProceed;

  /// No description provided for @bkErrServiceId.
  ///
  /// In en, this message translates to:
  /// **'Service ID is required'**
  String get bkErrServiceId;

  /// No description provided for @bkErrSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get bkErrSelectDate;

  /// No description provided for @bkErrSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Please select a time'**
  String get bkErrSelectTime;

  /// No description provided for @bkErrSelectAddress.
  ///
  /// In en, this message translates to:
  /// **'Please select an address'**
  String get bkErrSelectAddress;

  /// No description provided for @ppAddedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get ppAddedToFavorites;

  /// No description provided for @ppRemovedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get ppRemovedFromFavorites;

  /// No description provided for @ppRating.
  ///
  /// In en, this message translates to:
  /// **'{rating} rating'**
  String ppRating(Object rating);

  /// No description provided for @ppReviews.
  ///
  /// In en, this message translates to:
  /// **'{reviews} reviews'**
  String ppReviews(Object reviews);

  /// No description provided for @ppOverviewRating.
  ///
  /// In en, this message translates to:
  /// **'{rating} • {reviews} reviews'**
  String ppOverviewRating(Object rating, Object reviews);

  /// No description provided for @ppAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About this service'**
  String get ppAboutTitle;

  /// No description provided for @ppAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything the customer should understand before booking.'**
  String get ppAboutSubtitle;

  /// No description provided for @ppFastBooking.
  ///
  /// In en, this message translates to:
  /// **'Fast booking'**
  String get ppFastBooking;

  /// No description provided for @ppVerifiedProvider.
  ///
  /// In en, this message translates to:
  /// **'Verified provider'**
  String get ppVerifiedProvider;

  /// No description provided for @ppOpenListing.
  ///
  /// In en, this message translates to:
  /// **'Open listing'**
  String get ppOpenListing;

  /// No description provided for @ppVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get ppVerified;

  /// No description provided for @ppContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get ppContact;

  /// No description provided for @ppBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get ppBookNow;

  /// No description provided for @ppWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why customers book this'**
  String get ppWhyTitle;

  /// No description provided for @ppWhySubtitle.
  ///
  /// In en, this message translates to:
  /// **'A quick snapshot before the booking flow starts.'**
  String get ppWhySubtitle;

  /// No description provided for @ppFastHandoff.
  ///
  /// In en, this message translates to:
  /// **'Fast handoff'**
  String get ppFastHandoff;

  /// No description provided for @ppFastHandoffDesc.
  ///
  /// In en, this message translates to:
  /// **'Go from service details to booking in one step.'**
  String get ppFastHandoffDesc;

  /// No description provided for @ppSocialProof.
  ///
  /// In en, this message translates to:
  /// **'Social proof'**
  String get ppSocialProof;

  /// No description provided for @ppSocialProofDesc.
  ///
  /// In en, this message translates to:
  /// **'{reviews} reviews currently attached to this listing.'**
  String ppSocialProofDesc(Object reviews);

  /// No description provided for @ppProviderContact.
  ///
  /// In en, this message translates to:
  /// **'Provider contact'**
  String get ppProviderContact;

  /// No description provided for @ppProviderContactDesc.
  ///
  /// In en, this message translates to:
  /// **'Message the provider first if you want to clarify scope or timing.'**
  String get ppProviderContactDesc;

  /// No description provided for @ppRecentReviews.
  ///
  /// In en, this message translates to:
  /// **'Recent reviews'**
  String get ppRecentReviews;

  /// No description provided for @ppRecentReviewsSub.
  ///
  /// In en, this message translates to:
  /// **'Recent customer feedback for this listing.'**
  String get ppRecentReviewsSub;

  /// No description provided for @ppSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get ppSeeAll;

  /// No description provided for @ppNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get ppNoReviews;

  /// No description provided for @ppReviewsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{reviews} reviews available'**
  String ppReviewsAvailable(Object reviews);

  /// No description provided for @ppMinAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String ppMinAgo(Object minutes);

  /// No description provided for @ppHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String ppHoursAgo(Object hours);

  /// No description provided for @ppDayAgo.
  ///
  /// In en, this message translates to:
  /// **'1 day ago'**
  String get ppDayAgo;

  /// No description provided for @ppDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String ppDaysAgo(Object days);

  /// No description provided for @ppWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks ago'**
  String ppWeeksAgo(Object weeks);

  /// No description provided for @ppMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{months} months ago'**
  String ppMonthsAgo(Object months);

  /// No description provided for @cpTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Provider'**
  String get cpTitle;

  /// No description provided for @cpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reach out to {name} about service details or availability.'**
  String cpSubtitle(Object name);

  /// No description provided for @cpContactOptions.
  ///
  /// In en, this message translates to:
  /// **'Contact options'**
  String get cpContactOptions;

  /// No description provided for @cpCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get cpCall;

  /// No description provided for @cpChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get cpChat;

  /// No description provided for @cpOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening...'**
  String get cpOpening;

  /// No description provided for @cpSendMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a message'**
  String get cpSendMessageTitle;

  /// No description provided for @cpSendMessageSub.
  ///
  /// In en, this message translates to:
  /// **'This sends your message straight into the existing in-app chat thread.'**
  String get cpSendMessageSub;

  /// No description provided for @cpSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get cpSubject;

  /// No description provided for @cpSubjectPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'What is this about?'**
  String get cpSubjectPlaceholder;

  /// No description provided for @cpSubjectRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject'**
  String get cpSubjectRequired;

  /// No description provided for @cpMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get cpMessage;

  /// No description provided for @cpMessagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Write your message here...'**
  String get cpMessagePlaceholder;

  /// No description provided for @cpMessageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a message'**
  String get cpMessageRequired;

  /// No description provided for @cpSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get cpSending;

  /// No description provided for @cpSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get cpSendMessage;

  /// No description provided for @cpPhoneUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Phone number unavailable'**
  String get cpPhoneUnavailable;

  /// No description provided for @cpServiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Service details'**
  String get cpServiceDetails;

  /// No description provided for @cpCannotContact.
  ///
  /// In en, this message translates to:
  /// **'This provider cannot be contacted yet.'**
  String get cpCannotContact;

  /// No description provided for @cpCouldNotOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Could not open chat right now.'**
  String get cpCouldNotOpenChat;

  /// No description provided for @cpMessageNotSent.
  ///
  /// In en, this message translates to:
  /// **'Message could not be sent.'**
  String get cpMessageNotSent;

  /// No description provided for @cpNoMobile.
  ///
  /// In en, this message translates to:
  /// **'No mobile number available'**
  String get cpNoMobile;

  /// No description provided for @cpCouldNotOpenDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not launch phone dialer'**
  String get cpCouldNotOpenDialer;

  /// No description provided for @caCallByNumber.
  ///
  /// In en, this message translates to:
  /// **'Call by number'**
  String get caCallByNumber;

  /// No description provided for @caInAppCall.
  ///
  /// In en, this message translates to:
  /// **'Call using the app'**
  String get caInAppCall;

  /// No description provided for @caTextSms.
  ///
  /// In en, this message translates to:
  /// **'Text via SMS'**
  String get caTextSms;

  /// No description provided for @caInAppChat.
  ///
  /// In en, this message translates to:
  /// **'Chat in app'**
  String get caInAppChat;

  /// No description provided for @epTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get epTitle;

  /// No description provided for @epPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get epPersonalInfo;

  /// No description provided for @epDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get epDisplayName;

  /// No description provided for @epDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get epDisplayNameHint;

  /// No description provided for @epDisplayNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Display name is required'**
  String get epDisplayNameRequired;

  /// No description provided for @epEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get epEmail;

  /// No description provided for @epEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get epEmailHint;

  /// No description provided for @epEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get epEmailRequired;

  /// No description provided for @epEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get epEmailInvalid;

  /// No description provided for @epPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get epPhoneNumber;

  /// No description provided for @epPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get epPhoneHint;

  /// No description provided for @epSave.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get epSave;

  /// No description provided for @epStagedLocally.
  ///
  /// In en, this message translates to:
  /// **'Changes staged locally (pending approval)'**
  String get epStagedLocally;

  /// No description provided for @epUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get epUpdated;

  /// No description provided for @epUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile: {error}'**
  String epUpdateError(Object error);

  /// No description provided for @suTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get suTitle;

  /// No description provided for @suSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join Serbisyo and access home services at your fingertips.'**
  String get suSubtitle;

  /// No description provided for @suFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get suFirstName;

  /// No description provided for @suFirstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Juan'**
  String get suFirstNameHint;

  /// No description provided for @suMiddleName.
  ///
  /// In en, this message translates to:
  /// **'Middle Name (optional)'**
  String get suMiddleName;

  /// No description provided for @suMiddleNameHint.
  ///
  /// In en, this message translates to:
  /// **'Santos'**
  String get suMiddleNameHint;

  /// No description provided for @suLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get suLastName;

  /// No description provided for @suLastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Dela Cruz'**
  String get suLastNameHint;

  /// No description provided for @suEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get suEmail;

  /// No description provided for @suEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get suEmailHint;

  /// No description provided for @suMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get suMobileNumber;

  /// No description provided for @suPhonePrefix.
  ///
  /// In en, this message translates to:
  /// **'+63'**
  String get suPhonePrefix;

  /// No description provided for @suPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'9123456789'**
  String get suPhoneHint;

  /// No description provided for @suPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get suPassword;

  /// No description provided for @suPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get suPasswordHint;

  /// No description provided for @suConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get suConfirmPassword;

  /// No description provided for @suConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get suConfirmPasswordHint;

  /// No description provided for @suSigningUp.
  ///
  /// In en, this message translates to:
  /// **'Signing Up...'**
  String get suSigningUp;

  /// No description provided for @suAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get suAlreadyHaveAccount;

  /// No description provided for @spwTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get spwTitle;

  /// No description provided for @spwSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry! It happens. Please enter the email address associated with your account.'**
  String get spwSubtitle;

  /// No description provided for @spwEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get spwEmail;

  /// No description provided for @spwInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get spwInvalidEmail;

  /// No description provided for @spwSendReset.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get spwSendReset;

  /// No description provided for @spwRememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password? '**
  String get spwRememberPassword;

  /// No description provided for @fpTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get fpTitle;

  /// No description provided for @fpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry! It happens. Please enter the email address associated with your account.'**
  String get fpSubtitle;

  /// No description provided for @fpEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fpEmail;

  /// No description provided for @fpInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get fpInvalidEmail;

  /// No description provided for @fpSendReset.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get fpSendReset;

  /// No description provided for @fpRememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password? '**
  String get fpRememberPassword;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Verification'**
  String get otpTitle;

  /// No description provided for @otpVerifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone'**
  String get otpVerifyPhone;

  /// No description provided for @otpEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to receive a one-time code.'**
  String get otpEnterPhone;

  /// No description provided for @otpEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your phone.'**
  String get otpEnterCode;

  /// No description provided for @otpPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get otpPhoneNumber;

  /// No description provided for @otpPhonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'+63xxxxxxxxxx'**
  String get otpPhonePlaceholder;

  /// No description provided for @otpSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get otpSendCode;

  /// No description provided for @otpCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get otpCodeLabel;

  /// No description provided for @otpCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'000000'**
  String get otpCodePlaceholder;

  /// No description provided for @otpVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified!'**
  String get otpVerified;

  /// No description provided for @otpVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerify;

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get otpResend;

  /// No description provided for @otpResendCooldown.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP ({seconds}s)'**
  String otpResendCooldown(Object seconds);

  /// No description provided for @otpErrEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number'**
  String get otpErrEnterPhone;

  /// No description provided for @otpErrSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send code.'**
  String get otpErrSendFailed;

  /// No description provided for @otpErrEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit code'**
  String get otpErrEnterCode;

  /// No description provided for @otpErrInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code.'**
  String get otpErrInvalidCode;

  /// No description provided for @phvTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Verification'**
  String get phvTitle;

  /// No description provided for @phvEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get phvEnterCode;

  /// No description provided for @phvSentCode.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit code to your phone number. Please enter it below.'**
  String get phvSentCode;

  /// No description provided for @phvErrEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter SMS verification code.'**
  String get phvErrEnterCode;

  /// No description provided for @phvErrCodeDigits.
  ///
  /// In en, this message translates to:
  /// **'Code must be 6 digits.'**
  String get phvErrCodeDigits;

  /// No description provided for @phvVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get phvVerify;

  /// No description provided for @phvDidntReceive.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get phvDidntReceive;

  /// No description provided for @phvResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get phvResendCode;

  /// No description provided for @snSignOutAllDevices.
  ///
  /// In en, this message translates to:
  /// **'Sign Out All Devices'**
  String get snSignOutAllDevices;

  /// No description provided for @snSignOutAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will sign you out of all active sessions except this one.'**
  String get snSignOutAllConfirm;

  /// No description provided for @snSignOutAll.
  ///
  /// In en, this message translates to:
  /// **'Sign Out All'**
  String get snSignOutAll;

  /// No description provided for @snAllRevoked.
  ///
  /// In en, this message translates to:
  /// **'All other sessions revoked'**
  String get snAllRevoked;

  /// No description provided for @snFailedRevokeAll.
  ///
  /// In en, this message translates to:
  /// **'Failed to revoke sessions'**
  String get snFailedRevokeAll;

  /// No description provided for @snRevoked.
  ///
  /// In en, this message translates to:
  /// **'Session revoked'**
  String get snRevoked;

  /// No description provided for @snFailedRevoke.
  ///
  /// In en, this message translates to:
  /// **'Failed to revoke session'**
  String get snFailedRevoke;

  /// No description provided for @snTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Sessions'**
  String get snTitle;

  /// No description provided for @snNoActiveSessions.
  ///
  /// In en, this message translates to:
  /// **'No active sessions'**
  String get snNoActiveSessions;

  /// No description provided for @snUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get snUnknown;

  /// No description provided for @snCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get snCurrent;

  /// No description provided for @snRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get snRevoke;

  /// No description provided for @bioSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric Setup'**
  String get bioSetupTitle;

  /// No description provided for @bioSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your fingerprint or face to sign in quickly and securely.'**
  String get bioSetupSubtitle;

  /// No description provided for @bioSetupRegister.
  ///
  /// In en, this message translates to:
  /// **'Register this device'**
  String get bioSetupRegister;

  /// No description provided for @bioSetupDeviceNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Device name (e.g. My Phone)'**
  String get bioSetupDeviceNameLabel;

  /// No description provided for @bioSetupDeviceNameDefault.
  ///
  /// In en, this message translates to:
  /// **'My Device'**
  String get bioSetupDeviceNameDefault;

  /// No description provided for @bioSetupRegistered.
  ///
  /// In en, this message translates to:
  /// **'Device registered'**
  String get bioSetupRegistered;

  /// No description provided for @bioSetupRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get bioSetupRegistrationFailed;

  /// No description provided for @bioSetupRegisteredDevices.
  ///
  /// In en, this message translates to:
  /// **'Registered Devices'**
  String get bioSetupRegisteredDevices;

  /// No description provided for @bioSetupUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get bioSetupUnknown;

  /// No description provided for @mnMarkAllFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not mark notifications as read.'**
  String get mnMarkAllFailed;

  /// No description provided for @mnNoDestination.
  ///
  /// In en, this message translates to:
  /// **'This notification has no linked destination yet.'**
  String get mnNoDestination;

  /// No description provided for @mnTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get mnTitle;

  /// No description provided for @mnSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get mnSettings;

  /// No description provided for @mnMarking.
  ///
  /// In en, this message translates to:
  /// **'Marking...'**
  String get mnMarking;

  /// No description provided for @mnMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get mnMarkAllRead;

  /// No description provided for @mnGranularHint.
  ///
  /// In en, this message translates to:
  /// **'Granular controls live inside each service update.'**
  String get mnGranularHint;

  /// No description provided for @mnTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mnTabAll;

  /// No description provided for @mnTabBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get mnTabBookings;

  /// No description provided for @mnTabOffers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get mnTabOffers;

  /// No description provided for @mnTabSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get mnTabSystem;

  /// No description provided for @mnEmptyBookings.
  ///
  /// In en, this message translates to:
  /// **'Booking updates will land here as providers respond.'**
  String get mnEmptyBookings;

  /// No description provided for @mnEmptyOffers.
  ///
  /// In en, this message translates to:
  /// **'Promos and special offers will show up here.'**
  String get mnEmptyOffers;

  /// No description provided for @mnEmptySystem.
  ///
  /// In en, this message translates to:
  /// **'System updates will appear here when available.'**
  String get mnEmptySystem;

  /// No description provided for @mnOpenDetails.
  ///
  /// In en, this message translates to:
  /// **'Open this update to see more details.'**
  String get mnOpenDetails;

  /// No description provided for @mnMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String mnMinutesAgo(Object minutes);

  /// No description provided for @mnHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String mnHoursAgo(Object hours);

  /// No description provided for @mnDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String mnDaysAgo(Object days);

  /// No description provided for @callPermTitleVideo.
  ///
  /// In en, this message translates to:
  /// **'Camera & Microphone'**
  String get callPermTitleVideo;

  /// No description provided for @callPermTitleAudio.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get callPermTitleAudio;

  /// No description provided for @callPermAllowBoth.
  ///
  /// In en, this message translates to:
  /// **'Allow camera & microphone'**
  String get callPermAllowBoth;

  /// No description provided for @callPermAllowMic.
  ///
  /// In en, this message translates to:
  /// **'Allow microphone'**
  String get callPermAllowMic;

  /// No description provided for @callPermCalling.
  ///
  /// In en, this message translates to:
  /// **'Calling {name}'**
  String callPermCalling(Object name);

  /// No description provided for @callPermAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get callPermAllow;

  /// No description provided for @chdUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get chdUnknown;

  /// No description provided for @chdTitle.
  ///
  /// In en, this message translates to:
  /// **'Call Details'**
  String get chdTitle;

  /// No description provided for @chdUnknownProvider.
  ///
  /// In en, this message translates to:
  /// **'Unknown Provider'**
  String get chdUnknownProvider;

  /// No description provided for @chdInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Call Information'**
  String get chdInfoTitle;

  /// No description provided for @chdStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get chdStatus;

  /// No description provided for @chdDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get chdDuration;

  /// No description provided for @chdDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get chdDateTitle;

  /// No description provided for @chdCallBack.
  ///
  /// In en, this message translates to:
  /// **'Call Back'**
  String get chdCallBack;

  /// No description provided for @chdMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chdMessage;

  /// No description provided for @suPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone Number is required and has to start with +.'**
  String get suPhoneRequired;

  /// No description provided for @crUploadProgress.
  ///
  /// In en, this message translates to:
  /// **'Uploading {percent}%'**
  String crUploadProgress(Object percent);

  /// No description provided for @mnErrorMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Could not mark notifications as read.'**
  String get mnErrorMarkRead;

  /// No description provided for @mnErrorNoDestination.
  ///
  /// In en, this message translates to:
  /// **'This notification has no linked destination yet.'**
  String get mnErrorNoDestination;

  /// No description provided for @adTitle.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get adTitle;

  /// No description provided for @adAddNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add new address'**
  String get adAddNewAddress;

  /// No description provided for @adNoAddressesYet.
  ///
  /// In en, this message translates to:
  /// **'No addresses yet'**
  String get adNoAddressesYet;

  /// No description provided for @adEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your home, work, or favorite places so future bookings are quicker.'**
  String get adEmptySubtitle;

  /// No description provided for @adSavedAddress.
  ///
  /// In en, this message translates to:
  /// **'Saved address'**
  String get adSavedAddress;

  /// No description provided for @adEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get adEdit;

  /// No description provided for @adSetAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get adSetAsDefault;

  /// No description provided for @adDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adDelete;

  /// No description provided for @adDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get adDefault;

  /// No description provided for @adSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get adSelected;

  /// No description provided for @adErrorSetDefault.
  ///
  /// In en, this message translates to:
  /// **'Error setting default address'**
  String get adErrorSetDefault;

  /// No description provided for @adDefaultUpdated.
  ///
  /// In en, this message translates to:
  /// **'Default address updated'**
  String get adDefaultUpdated;

  /// No description provided for @adErrorSetDefaultDetail.
  ///
  /// In en, this message translates to:
  /// **'Error setting default address: {error}'**
  String adErrorSetDefaultDetail(Object error);

  /// No description provided for @adDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete address'**
  String get adDeleteTitle;

  /// No description provided for @adDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {label}?'**
  String adDeleteConfirm(Object label);

  /// No description provided for @adDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address deleted successfully'**
  String get adDeletedSuccess;

  /// No description provided for @adErrorDeleteDetail.
  ///
  /// In en, this message translates to:
  /// **'Error deleting address: {error}'**
  String adErrorDeleteDetail(Object error);

  /// No description provided for @adSelectedForBookings.
  ///
  /// In en, this message translates to:
  /// **'{label} selected for bookings'**
  String adSelectedForBookings(Object label);

  /// No description provided for @geSearch.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get geSearch;

  /// No description provided for @geNoItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get geNoItemsFound;

  /// No description provided for @geTitleRegion.
  ///
  /// In en, this message translates to:
  /// **'Select Region'**
  String get geTitleRegion;

  /// No description provided for @geTitleProvince.
  ///
  /// In en, this message translates to:
  /// **'Select Province'**
  String get geTitleProvince;

  /// No description provided for @geTitleCity.
  ///
  /// In en, this message translates to:
  /// **'Select City/Municipality'**
  String get geTitleCity;

  /// No description provided for @geTitleBarangay.
  ///
  /// In en, this message translates to:
  /// **'Select Barangay'**
  String get geTitleBarangay;

  /// No description provided for @plSearchLocation.
  ///
  /// In en, this message translates to:
  /// **'Search a location'**
  String get plSearchLocation;

  /// No description provided for @plSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get plSubmit;

  /// No description provided for @plNoLocation.
  ///
  /// In en, this message translates to:
  /// **'Please select a location on the map'**
  String get plNoLocation;

  /// No description provided for @rcTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get rcTitle;

  /// No description provided for @rcLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get rcLabelTitle;

  /// No description provided for @rcLabelDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get rcLabelDescription;

  /// No description provided for @rcLabelMenuService.
  ///
  /// In en, this message translates to:
  /// **'Menu / Service'**
  String get rcLabelMenuService;

  /// No description provided for @rcLabelEventDate.
  ///
  /// In en, this message translates to:
  /// **'Event Date'**
  String get rcLabelEventDate;

  /// No description provided for @rcLabelEventTime.
  ///
  /// In en, this message translates to:
  /// **'Event Time'**
  String get rcLabelEventTime;

  /// No description provided for @rcTapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get rcTapToSelect;

  /// No description provided for @rcLabelLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get rcLabelLocation;

  /// No description provided for @rcHeadsRequired.
  ///
  /// In en, this message translates to:
  /// **'Heads Required'**
  String get rcHeadsRequired;

  /// No description provided for @rcPricePerHead.
  ///
  /// In en, this message translates to:
  /// **'Price per Head'**
  String get rcPricePerHead;

  /// No description provided for @rcFailedCreate.
  ///
  /// In en, this message translates to:
  /// **'Failed to create room'**
  String get rcFailedCreate;

  /// No description provided for @rdTitle.
  ///
  /// In en, this message translates to:
  /// **'Room Details'**
  String get rdTitle;

  /// No description provided for @rdRoomNotFound.
  ///
  /// In en, this message translates to:
  /// **'Room not found'**
  String get rdRoomNotFound;

  /// No description provided for @rdParticipants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get rdParticipants;

  /// No description provided for @rdJoinCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Join code copied'**
  String get rdJoinCodeCopied;

  /// No description provided for @rdShareJoinCode.
  ///
  /// In en, this message translates to:
  /// **'Share Join Code'**
  String get rdShareJoinCode;

  /// No description provided for @rdRoomLocked.
  ///
  /// In en, this message translates to:
  /// **'Room locked'**
  String get rdRoomLocked;

  /// No description provided for @rdFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get rdFailed;

  /// No description provided for @rdLockRoom.
  ///
  /// In en, this message translates to:
  /// **'Lock Room'**
  String get rdLockRoom;

  /// No description provided for @rdCancelRoom.
  ///
  /// In en, this message translates to:
  /// **'Cancel Room'**
  String get rdCancelRoom;

  /// No description provided for @rdLeaveRoom.
  ///
  /// In en, this message translates to:
  /// **'Leave Room'**
  String get rdLeaveRoom;

  /// No description provided for @rdJoined.
  ///
  /// In en, this message translates to:
  /// **'{count}/{head} joined'**
  String rdJoined(Object count, Object head);

  /// No description provided for @rlRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get rlRooms;

  /// No description provided for @rlNoRoomsYet.
  ///
  /// In en, this message translates to:
  /// **'No rooms yet'**
  String get rlNoRoomsYet;

  /// No description provided for @rlCreateRoom.
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get rlCreateRoom;

  /// No description provided for @rlSeats.
  ///
  /// In en, this message translates to:
  /// **'{seats}/{heads} seats'**
  String rlSeats(Object heads, Object seats);

  /// No description provided for @rlStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get rlStatusOpen;

  /// No description provided for @rlStatusLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get rlStatusLocked;

  /// No description provided for @rlStatusSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get rlStatusSettled;

  /// No description provided for @rlStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get rlStatusCancelled;

  /// No description provided for @rlStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get rlStatusExpired;

  /// No description provided for @rjTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Room'**
  String get rjTitle;

  /// No description provided for @rjEnterJoinCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Join Code'**
  String get rjEnterJoinCode;

  /// No description provided for @rjJoinCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Join code'**
  String get rjJoinCodePlaceholder;

  /// No description provided for @rjLookUp.
  ///
  /// In en, this message translates to:
  /// **'Look Up'**
  String get rjLookUp;

  /// No description provided for @rjRoomNotFound.
  ///
  /// In en, this message translates to:
  /// **'Room not found or link expired.'**
  String get rjRoomNotFound;

  /// No description provided for @rjSeats.
  ///
  /// In en, this message translates to:
  /// **'Seats: {seats}/{heads}'**
  String rjSeats(Object heads, Object seats);

  /// No description provided for @rjFailedJoin.
  ///
  /// In en, this message translates to:
  /// **'Failed to join room'**
  String get rjFailedJoin;

  /// No description provided for @rjJoinRoom.
  ///
  /// In en, this message translates to:
  /// **'Join Room'**
  String get rjJoinRoom;

  /// No description provided for @rjCannotJoin.
  ///
  /// In en, this message translates to:
  /// **'Cannot Join'**
  String get rjCannotJoin;

  /// No description provided for @ckConversation.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get ckConversation;

  /// No description provided for @ckStartConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation'**
  String get ckStartConversation;

  /// No description provided for @ckConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected to this thread'**
  String get ckConnected;

  /// No description provided for @ckChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get ckChat;

  /// No description provided for @ckNoMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get ckNoMessages;

  /// No description provided for @ckEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send the first message to coordinate service details, arrival timing, or updates.'**
  String get ckEmptySubtitle;

  /// No description provided for @ckContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get ckContact;

  /// No description provided for @ckWriteMessage.
  ///
  /// In en, this message translates to:
  /// **'Write a message...'**
  String get ckWriteMessage;

  /// No description provided for @ckSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get ckSending;

  /// No description provided for @ckFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get ckFailed;

  /// No description provided for @ckSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get ckSent;

  /// No description provided for @pcTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Project'**
  String get pcTitle;

  /// No description provided for @pcLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get pcLabelTitle;

  /// No description provided for @pcLabelDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get pcLabelDescription;

  /// No description provided for @pcLabelCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get pcLabelCategory;

  /// No description provided for @pcB2B.
  ///
  /// In en, this message translates to:
  /// **'B2B Project'**
  String get pcB2B;

  /// No description provided for @pcFailedCreate.
  ///
  /// In en, this message translates to:
  /// **'Failed to create project'**
  String get pcFailedCreate;

  /// No description provided for @pdTitle.
  ///
  /// In en, this message translates to:
  /// **'Project Details'**
  String get pdTitle;

  /// No description provided for @pdProjectNotFound.
  ///
  /// In en, this message translates to:
  /// **'Project not found'**
  String get pdProjectNotFound;

  /// No description provided for @pdRoleLines.
  ///
  /// In en, this message translates to:
  /// **'Role Lines'**
  String get pdRoleLines;

  /// No description provided for @pdNoProspects.
  ///
  /// In en, this message translates to:
  /// **'No prospects yet'**
  String get pdNoProspects;

  /// No description provided for @pdQuoteGenerated.
  ///
  /// In en, this message translates to:
  /// **'Quote generated'**
  String get pdQuoteGenerated;

  /// No description provided for @pdFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get pdFailed;

  /// No description provided for @pdGenerateQuote.
  ///
  /// In en, this message translates to:
  /// **'Generate Quote'**
  String get pdGenerateQuote;

  /// No description provided for @pdCancelProject.
  ///
  /// In en, this message translates to:
  /// **'Cancel Project'**
  String get pdCancelProject;

  /// No description provided for @pdBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget: {min} - {max}'**
  String pdBudget(Object max, Object min);

  /// No description provided for @pdHeadcount.
  ///
  /// In en, this message translates to:
  /// **'Headcount: {count}'**
  String pdHeadcount(Object count);

  /// No description provided for @pdExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String pdExpires(Object date);

  /// No description provided for @pdScore.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String pdScore(Object score);

  /// No description provided for @plProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get plProjects;

  /// No description provided for @plNoProjects.
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get plNoProjects;

  /// No description provided for @plCreateProject.
  ///
  /// In en, this message translates to:
  /// **'Create a Project'**
  String get plCreateProject;

  /// No description provided for @pjStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get pjStatusDraft;

  /// No description provided for @pjStatusQuoted.
  ///
  /// In en, this message translates to:
  /// **'Quoted'**
  String get pjStatusQuoted;

  /// No description provided for @pjStatusMatching.
  ///
  /// In en, this message translates to:
  /// **'Matching'**
  String get pjStatusMatching;

  /// No description provided for @pjStatusCommitted.
  ///
  /// In en, this message translates to:
  /// **'Committed'**
  String get pjStatusCommitted;

  /// No description provided for @pjStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get pjStatusCancelled;

  /// No description provided for @pjStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get pjStatusExpired;

  /// No description provided for @obTitle.
  ///
  /// In en, this message translates to:
  /// **'On-Demand Booking'**
  String get obTitle;

  /// No description provided for @obSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get help when you need it'**
  String get obSubtitle;

  /// No description provided for @obWhenNeed.
  ///
  /// In en, this message translates to:
  /// **'When do you need service?'**
  String get obWhenNeed;

  /// No description provided for @obOptionNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get obOptionNow;

  /// No description provided for @obOptionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get obOptionToday;

  /// No description provided for @obOptionTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get obOptionTomorrow;

  /// No description provided for @obOptionThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get obOptionThisWeek;

  /// No description provided for @obPreferredTime.
  ///
  /// In en, this message translates to:
  /// **'Preferred Time'**
  String get obPreferredTime;

  /// No description provided for @obBookingSummary.
  ///
  /// In en, this message translates to:
  /// **'Booking Summary'**
  String get obBookingSummary;

  /// No description provided for @obFeeService.
  ///
  /// In en, this message translates to:
  /// **'Service Fee'**
  String get obFeeService;

  /// No description provided for @obFeeUrgency.
  ///
  /// In en, this message translates to:
  /// **'Urgency Fee'**
  String get obFeeUrgency;

  /// No description provided for @obFeeServiceCharge.
  ///
  /// In en, this message translates to:
  /// **'Service Charge'**
  String get obFeeServiceCharge;

  /// No description provided for @obTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get obTotal;

  /// No description provided for @obConfirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get obConfirmBooking;

  /// No description provided for @cjTitle.
  ///
  /// In en, this message translates to:
  /// **'My On-Demand Jobs'**
  String get cjTitle;

  /// No description provided for @cjNoJobs.
  ///
  /// In en, this message translates to:
  /// **'No on-demand jobs yet'**
  String get cjNoJobs;

  /// No description provided for @cjResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get cjResume;

  /// No description provided for @cjGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get cjGeneral;

  /// No description provided for @cjProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get cjProvider;

  /// No description provided for @cjFee.
  ///
  /// In en, this message translates to:
  /// **'Fee: {fee}'**
  String cjFee(Object fee);

  /// No description provided for @cjBids.
  ///
  /// In en, this message translates to:
  /// **'{count} bid(s)'**
  String cjBids(Object count);

  /// No description provided for @cjStatusSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching'**
  String get cjStatusSearching;

  /// No description provided for @cjStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get cjStatusAccepted;

  /// No description provided for @cjStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get cjStatusExpired;

  /// No description provided for @cjStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cjStatusCancelled;

  /// No description provided for @tosTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get tosTitle;

  /// No description provided for @tosLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String tosLastUpdated(Object date);

  /// No description provided for @tosAcceptance.
  ///
  /// In en, this message translates to:
  /// **'Acceptance of Terms'**
  String get tosAcceptance;

  /// No description provided for @tosAccounts.
  ///
  /// In en, this message translates to:
  /// **'User Accounts'**
  String get tosAccounts;

  /// No description provided for @tosServicesBookings.
  ///
  /// In en, this message translates to:
  /// **'Services and Bookings'**
  String get tosServicesBookings;

  /// No description provided for @tosProhibited.
  ///
  /// In en, this message translates to:
  /// **'Prohibited Conduct'**
  String get tosProhibited;

  /// No description provided for @tosPaymentsFees.
  ///
  /// In en, this message translates to:
  /// **'Payments and Fees'**
  String get tosPaymentsFees;

  /// No description provided for @tosLimitation.
  ///
  /// In en, this message translates to:
  /// **'Limitation of Liability'**
  String get tosLimitation;

  /// No description provided for @tosContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get tosContact;

  /// No description provided for @privTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privTitle;

  /// No description provided for @privLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String privLastUpdated(Object date);

  /// No description provided for @privCollect.
  ///
  /// In en, this message translates to:
  /// **'Information We Collect'**
  String get privCollect;

  /// No description provided for @privUse.
  ///
  /// In en, this message translates to:
  /// **'How We Use Your Information'**
  String get privUse;

  /// No description provided for @privSharing.
  ///
  /// In en, this message translates to:
  /// **'Information Sharing'**
  String get privSharing;

  /// No description provided for @privSecurity.
  ///
  /// In en, this message translates to:
  /// **'Data Security'**
  String get privSecurity;

  /// No description provided for @privRights.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get privRights;

  /// No description provided for @privContact.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get privContact;

  /// No description provided for @hpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get hpTitle;

  /// No description provided for @hpChatWithUs.
  ///
  /// In en, this message translates to:
  /// **'Chat with us'**
  String get hpChatWithUs;

  /// No description provided for @hpBooking.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get hpBooking;

  /// No description provided for @hpPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get hpPayment;

  /// No description provided for @hpAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get hpAccount;

  /// No description provided for @hpProviders.
  ///
  /// In en, this message translates to:
  /// **'Providers'**
  String get hpProviders;

  /// No description provided for @cbTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat Assistant'**
  String get cbTitle;

  /// No description provided for @cbOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get cbOnline;

  /// No description provided for @cbTyping.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get cbTyping;

  /// No description provided for @cbHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get cbHint;

  /// No description provided for @cbGettingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Getting answer...'**
  String get cbGettingAnswer;

  /// No description provided for @rpTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get rpTitle;

  /// No description provided for @rpBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get rpBack;

  /// No description provided for @rpSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Ticket'**
  String get rpSubmit;

  /// No description provided for @rpTicketSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Ticket Submitted'**
  String get rpTicketSubmitted;

  /// No description provided for @rpWillRespond.
  ///
  /// In en, this message translates to:
  /// **'We\'ll get back to you as soon as possible.'**
  String get rpWillRespond;

  /// No description provided for @rpCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get rpCategory;

  /// No description provided for @rpCategoryBooking.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get rpCategoryBooking;

  /// No description provided for @rpCategoryPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get rpCategoryPayment;

  /// No description provided for @rpCategoryAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get rpCategoryAccount;

  /// No description provided for @rpCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get rpCategoryOther;

  /// No description provided for @rpDescribeIssue.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue'**
  String get rpDescribeIssue;

  /// No description provided for @rpPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tell us what happened... (min 10 characters)'**
  String get rpPlaceholder;

  /// No description provided for @rpMinChars.
  ///
  /// In en, this message translates to:
  /// **'Please provide at least 10 characters'**
  String get rpMinChars;

  /// No description provided for @dpTitle.
  ///
  /// In en, this message translates to:
  /// **'My Disputes'**
  String get dpTitle;

  /// No description provided for @dpNoDisputes.
  ///
  /// In en, this message translates to:
  /// **'No disputes'**
  String get dpNoDisputes;

  /// No description provided for @dpViewBooking.
  ///
  /// In en, this message translates to:
  /// **'View Booking'**
  String get dpViewBooking;

  /// No description provided for @dpStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get dpStatusOpen;

  /// No description provided for @dpStatusReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get dpStatusReview;

  /// No description provided for @dpStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get dpStatusResolved;

  /// No description provided for @dpStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get dpStatusRejected;

  /// No description provided for @dpStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get dpStatusClosed;

  /// No description provided for @dpStatusEscalated.
  ///
  /// In en, this message translates to:
  /// **'Escalated'**
  String get dpStatusEscalated;

  /// No description provided for @rvTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get rvTitle;

  /// No description provided for @rvError.
  ///
  /// In en, this message translates to:
  /// **'Error loading reviews'**
  String get rvError;

  /// No description provided for @rvRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get rvRetry;

  /// No description provided for @rvNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get rvNoReviews;

  /// No description provided for @rvBeFirst.
  ///
  /// In en, this message translates to:
  /// **'Be the first to review {name}'**
  String rvBeFirst(Object name);

  /// No description provided for @rvUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get rvUser;

  /// No description provided for @rvMinAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String rvMinAgo(Object minutes);

  /// No description provided for @rvHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String rvHoursAgo(Object hours);

  /// No description provided for @rvDayAgo.
  ///
  /// In en, this message translates to:
  /// **'1 day ago'**
  String get rvDayAgo;

  /// No description provided for @rvDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String rvDaysAgo(Object days);

  /// No description provided for @rvWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks ago'**
  String rvWeeksAgo(Object weeks);

  /// No description provided for @rvMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{months} months ago'**
  String rvMonthsAgo(Object months);

  /// No description provided for @mrTitle.
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get mrTitle;

  /// No description provided for @mrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track every service you rated and revisit your feedback.'**
  String get mrSubtitle;

  /// No description provided for @mrFootprint.
  ///
  /// In en, this message translates to:
  /// **'Your feedback footprint'**
  String get mrFootprint;

  /// No description provided for @mrFootprintSub.
  ///
  /// In en, this message translates to:
  /// **'Useful for tracking what services delivered the best experience.'**
  String get mrFootprintSub;

  /// No description provided for @mrReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get mrReviews;

  /// No description provided for @mrAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get mrAverage;

  /// No description provided for @mr5Stars.
  ///
  /// In en, this message translates to:
  /// **'5 stars'**
  String get mr5Stars;

  /// No description provided for @mrNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get mrNoReviews;

  /// No description provided for @mrEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Once you rate completed services, they will appear here with the service details and your score.'**
  String get mrEmptyBody;

  /// No description provided for @mrError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your reviews'**
  String get mrError;

  /// No description provided for @mrErrorSub.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh or try again now.'**
  String get mrErrorSub;

  /// No description provided for @mrRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get mrRetry;

  /// No description provided for @mrServiceFallback.
  ///
  /// In en, this message translates to:
  /// **'Service #{id}'**
  String mrServiceFallback(Object id);

  /// No description provided for @mrService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get mrService;

  /// No description provided for @mrProvider.
  ///
  /// In en, this message translates to:
  /// **'Service Provider'**
  String get mrProvider;

  /// No description provided for @mrJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get mrJustNow;

  /// No description provided for @mrMinAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String mrMinAgo(Object minutes);

  /// No description provided for @mrHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String mrHoursAgo(Object hours);

  /// No description provided for @mrDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String mrDaysAgo(Object days);

  /// No description provided for @wrTitle.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get wrTitle;

  /// No description provided for @wrExperience.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get wrExperience;

  /// No description provided for @wrTellMore.
  ///
  /// In en, this message translates to:
  /// **'Tell us more (optional)'**
  String get wrTellMore;

  /// No description provided for @wrPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Share details about your experience...'**
  String get wrPlaceholder;

  /// No description provided for @wrSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted!'**
  String get wrSubmitted;

  /// No description provided for @wrSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get wrSubmit;

  /// No description provided for @wrSelectRating.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get wrSelectRating;

  /// No description provided for @wrFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit review.'**
  String get wrFailed;

  /// No description provided for @rcmTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get rcmTitle;

  /// No description provided for @rcmTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending Now'**
  String get rcmTrending;

  /// No description provided for @rcmNearYou.
  ///
  /// In en, this message translates to:
  /// **'Near You'**
  String get rcmNearYou;

  /// No description provided for @rcmPicked.
  ///
  /// In en, this message translates to:
  /// **'Picked for You'**
  String get rcmPicked;

  /// No description provided for @rcmNoRecs.
  ///
  /// In en, this message translates to:
  /// **'No recommendations yet'**
  String get rcmNoRecs;

  /// No description provided for @rcmBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse services to get personalized picks.'**
  String get rcmBrowse;

  /// No description provided for @etTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get etTitle;

  /// No description provided for @etLinkExpired.
  ///
  /// In en, this message translates to:
  /// **'Link Expired'**
  String get etLinkExpired;

  /// No description provided for @etLinkInvalid.
  ///
  /// In en, this message translates to:
  /// **'This tracking link is no longer valid.'**
  String get etLinkInvalid;

  /// No description provided for @etSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get etSomethingWrong;

  /// No description provided for @etRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get etRetry;

  /// No description provided for @etMapView.
  ///
  /// In en, this message translates to:
  /// **'Map View'**
  String get etMapView;

  /// No description provided for @ppfTitle.
  ///
  /// In en, this message translates to:
  /// **'Provider Profile'**
  String get ppfTitle;

  /// No description provided for @ppfNotFound.
  ///
  /// In en, this message translates to:
  /// **'Provider not found'**
  String get ppfNotFound;

  /// No description provided for @ppfProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get ppfProvider;

  /// No description provided for @ppfServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get ppfServices;

  /// No description provided for @ppfNoServices.
  ///
  /// In en, this message translates to:
  /// **'No services posted yet.'**
  String get ppfNoServices;

  /// No description provided for @ppfReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get ppfReviews;

  /// No description provided for @ppfNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get ppfNoReviews;

  /// No description provided for @ppfRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ppfRating;

  /// No description provided for @ppfKycVerified.
  ///
  /// In en, this message translates to:
  /// **'KYC Verified'**
  String get ppfKycVerified;

  /// No description provided for @ppfAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get ppfAnonymous;

  /// No description provided for @ppfCompletedBookings.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ppfCompletedBookings;

  /// No description provided for @ppfCompletedBookingsSub.
  ///
  /// In en, this message translates to:
  /// **'completed services'**
  String get ppfCompletedBookingsSub;

  /// No description provided for @ppfSeeAllReviews.
  ///
  /// In en, this message translates to:
  /// **'See all reviews'**
  String get ppfSeeAllReviews;

  /// No description provided for @ppfLoadMoreReviews.
  ///
  /// In en, this message translates to:
  /// **'Load more reviews'**
  String get ppfLoadMoreReviews;

  /// No description provided for @ppfReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Provider Reviews'**
  String get ppfReviewsTitle;

  /// No description provided for @favTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favTitle;

  /// No description provided for @favSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick access to the services you want to revisit.'**
  String get favSubtitle;

  /// No description provided for @favErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error loading favorites'**
  String get favErrorTitle;

  /// No description provided for @favErrorSub.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading your saved services.'**
  String get favErrorSub;

  /// No description provided for @favNoTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favNoTitle;

  /// No description provided for @favNoSub.
  ///
  /// In en, this message translates to:
  /// **'Save the services you love so they are easy to book again.'**
  String get favNoSub;

  /// No description provided for @favService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get favService;

  /// No description provided for @favProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get favProvider;

  /// No description provided for @subcatNoServices.
  ///
  /// In en, this message translates to:
  /// **'No services available in this category'**
  String get subcatNoServices;

  /// No description provided for @catdNoServices.
  ///
  /// In en, this message translates to:
  /// **'No services found in this category'**
  String get catdNoServices;

  /// No description provided for @catdCheckLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later or browse other categories.'**
  String get catdCheckLater;

  /// No description provided for @catgTitle.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get catgTitle;

  /// No description provided for @catgSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse every service category in one place.'**
  String get catgSubtitle;

  /// No description provided for @catgError.
  ///
  /// In en, this message translates to:
  /// **'Error loading categories'**
  String get catgError;

  /// No description provided for @catgNoCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get catgNoCategories;

  /// No description provided for @catgInstantDispatch.
  ///
  /// In en, this message translates to:
  /// **'Instant dispatch'**
  String get catgInstantDispatch;

  /// No description provided for @catgOpenServices.
  ///
  /// In en, this message translates to:
  /// **'Open services'**
  String get catgOpenServices;

  /// No description provided for @catg247.
  ///
  /// In en, this message translates to:
  /// **'24/7'**
  String get catg247;

  /// No description provided for @abcTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Booking Composer'**
  String get abcTitle;

  /// No description provided for @abcDescribe.
  ///
  /// In en, this message translates to:
  /// **'Describe what you need'**
  String get abcDescribe;

  /// No description provided for @abcPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g., I need a plumber to fix a leaking pipe under my kitchen sink'**
  String get abcPlaceholder;

  /// No description provided for @abcAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get abcAnalyzing;

  /// No description provided for @abcCompose.
  ///
  /// In en, this message translates to:
  /// **'Compose Booking'**
  String get abcCompose;

  /// No description provided for @abcExtractError.
  ///
  /// In en, this message translates to:
  /// **'Could not extract booking details. Please try again with more specific information.'**
  String get abcExtractError;

  /// No description provided for @abcExtracted.
  ///
  /// In en, this message translates to:
  /// **'Extracted Details'**
  String get abcExtracted;

  /// No description provided for @splTagline.
  ///
  /// In en, this message translates to:
  /// **'Connecting Local Needs with Trusted Providers'**
  String get splTagline;

  /// No description provided for @nfTitle.
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get nfTitle;

  /// No description provided for @nfBody.
  ///
  /// In en, this message translates to:
  /// **'The page you\'re looking for doesn\'t exist or has been moved.'**
  String get nfBody;

  /// No description provided for @nfGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get nfGoHome;

  /// No description provided for @onbSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onbSkip;

  /// No description provided for @onbNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onbNext;

  /// No description provided for @kycCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get kycCamera;

  /// No description provided for @kycGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get kycGallery;

  /// No description provided for @wlTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wlTitle;

  /// No description provided for @wlBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get wlBalance;

  /// No description provided for @wlEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get wlEarnings;

  /// No description provided for @wlSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get wlSpent;

  /// No description provided for @wlTopUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get wlTopUp;

  /// No description provided for @wlSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get wlSend;

  /// No description provided for @wlWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get wlWithdraw;

  /// No description provided for @wlTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get wlTransactions;

  /// No description provided for @wlSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get wlSeeAll;

  /// No description provided for @ccCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get ccCancel;

  /// No description provided for @ccConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get ccConfirm;

  /// No description provided for @ccDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get ccDone;

  /// No description provided for @ccOK.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ccOK;

  /// No description provided for @ccBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get ccBookNow;

  /// No description provided for @ccDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get ccDecline;

  /// No description provided for @ccAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get ccAccept;

  /// No description provided for @ccNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get ccNext;

  /// No description provided for @ccSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get ccSkip;

  /// No description provided for @ccBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get ccBack;

  /// No description provided for @ccSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get ccSeeAll;

  /// No description provided for @ccSearch.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get ccSearch;

  /// No description provided for @ccSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get ccSignIn;

  /// No description provided for @ccGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get ccGetStarted;

  /// No description provided for @ccTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get ccTryAgain;

  /// No description provided for @ccSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get ccSomethingWrong;

  /// No description provided for @ccSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get ccSignInTitle;

  /// No description provided for @ccSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You need to be signed in to access this feature.'**
  String get ccSignInSubtitle;

  /// No description provided for @ccWriteReview.
  ///
  /// In en, this message translates to:
  /// **'Write Review'**
  String get ccWriteReview;

  /// No description provided for @ccBookAgain.
  ///
  /// In en, this message translates to:
  /// **'Book Again'**
  String get ccBookAgain;

  /// No description provided for @ccViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get ccViewDetails;

  /// No description provided for @ccTrackService.
  ///
  /// In en, this message translates to:
  /// **'Track Service'**
  String get ccTrackService;

  /// No description provided for @ccReschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get ccReschedule;

  /// No description provided for @ccInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get ccInProgress;

  /// No description provided for @ccCamMicAccess.
  ///
  /// In en, this message translates to:
  /// **'Camera & Microphone Access'**
  String get ccCamMicAccess;

  /// No description provided for @ccMicAccess.
  ///
  /// In en, this message translates to:
  /// **'Microphone Access'**
  String get ccMicAccess;

  /// No description provided for @ccCamMicDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow camera and microphone to join the video call.'**
  String get ccCamMicDesc;

  /// No description provided for @ccMicDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow microphone access to join the audio call.'**
  String get ccMicDesc;

  /// No description provided for @ccPermDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please enable it in your device settings.'**
  String get ccPermDenied;

  /// No description provided for @ccAccessGranted.
  ///
  /// In en, this message translates to:
  /// **'Access granted!'**
  String get ccAccessGranted;

  /// No description provided for @ccAllowCamMic.
  ///
  /// In en, this message translates to:
  /// **'Allow Camera & Microphone'**
  String get ccAllowCamMic;

  /// No description provided for @ccAllowMic.
  ///
  /// In en, this message translates to:
  /// **'Allow Microphone'**
  String get ccAllowMic;

  /// No description provided for @ccOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get ccOpenSettings;

  /// No description provided for @ccNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get ccNoInternet;

  /// No description provided for @ccSeasonalDeals.
  ///
  /// In en, this message translates to:
  /// **'Explore Seasonal Deals'**
  String get ccSeasonalDeals;

  /// No description provided for @cc60Off.
  ///
  /// In en, this message translates to:
  /// **'Get 60% OFF!'**
  String get cc60Off;

  /// No description provided for @ccNewJobRequest.
  ///
  /// In en, this message translates to:
  /// **'New Job Request'**
  String get ccNewJobRequest;

  /// No description provided for @ccWithin15.
  ///
  /// In en, this message translates to:
  /// **'Within 15 min'**
  String get ccWithin15;

  /// No description provided for @cc15to30.
  ///
  /// In en, this message translates to:
  /// **'15–30 min'**
  String get cc15to30;

  /// No description provided for @ccInstantDispatch.
  ///
  /// In en, this message translates to:
  /// **'Instant Dispatch'**
  String get ccInstantDispatch;

  /// No description provided for @ccDispatchDesc.
  ///
  /// In en, this message translates to:
  /// **'{category} pros guaranteed at your door in 15–30 minutes.'**
  String ccDispatchDesc(Object category);

  /// No description provided for @ccInviteEarn.
  ///
  /// In en, this message translates to:
  /// **'Invite & Earn'**
  String get ccInviteEarn;

  /// No description provided for @ccInviteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Refer a friend and get a PHP 100 cash bonus when they complete their first booking.'**
  String get ccInviteSubtitle;

  /// No description provided for @ccShareLink.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get ccShareLink;

  /// No description provided for @ccTotalDue.
  ///
  /// In en, this message translates to:
  /// **'Total due'**
  String get ccTotalDue;

  /// No description provided for @ccYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get ccYou;

  /// No description provided for @ccClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get ccClient;

  /// No description provided for @ccKmAway.
  ///
  /// In en, this message translates to:
  /// **'{km} km away'**
  String ccKmAway(Object km);

  /// No description provided for @ccStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting {fee}'**
  String ccStarting(Object fee);

  /// No description provided for @ccOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get ccOnline;

  /// No description provided for @ccOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get ccOffline;

  /// No description provided for @ccYouOnline.
  ///
  /// In en, this message translates to:
  /// **'You\'re Online'**
  String get ccYouOnline;

  /// No description provided for @ccYouOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re Offline'**
  String get ccYouOffline;

  /// No description provided for @ccReadyRequests.
  ///
  /// In en, this message translates to:
  /// **'Ready to receive service requests'**
  String get ccReadyRequests;

  /// No description provided for @ccNoNewRequests.
  ///
  /// In en, this message translates to:
  /// **'New requests won\'t reach you'**
  String get ccNoNewRequests;

  /// No description provided for @ccEmergenciesWait.
  ///
  /// In en, this message translates to:
  /// **'Emergencies can\'t wait.'**
  String get ccEmergenciesWait;

  /// No description provided for @ccVerifiedPro.
  ///
  /// In en, this message translates to:
  /// **'Get a verified pro dispatched right now.'**
  String get ccVerifiedPro;

  /// No description provided for @ccUrgentAssistance.
  ///
  /// In en, this message translates to:
  /// **'Urgent Assistance'**
  String get ccUrgentAssistance;

  /// No description provided for @ccTypeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get ccTypeMessage;

  /// No description provided for @ccSelect.
  ///
  /// In en, this message translates to:
  /// **'Select {field}'**
  String ccSelect(Object field);

  /// No description provided for @ccEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get ccEnterPassword;

  /// No description provided for @ccIncorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get ccIncorrectPassword;

  /// No description provided for @ccConfirmPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'For your security, please confirm your password to continue.'**
  String get ccConfirmPasswordTitle;

  /// No description provided for @ccPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get ccPasswordLabel;

  /// No description provided for @ccWaitingSelection.
  ///
  /// In en, this message translates to:
  /// **'Waiting for selection…'**
  String get ccWaitingSelection;

  /// No description provided for @ccClientReviewing.
  ///
  /// In en, this message translates to:
  /// **'The client is reviewing available providers.'**
  String get ccClientReviewing;

  /// No description provided for @ccDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get ccDismiss;

  /// No description provided for @svSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find the right pro for the job.'**
  String get svSubtitle;

  /// No description provided for @svNoDispatchPros.
  ///
  /// In en, this message translates to:
  /// **'No dispatch-ready pros nearby yet.'**
  String get svNoDispatchPros;

  /// No description provided for @svSetLocation.
  ///
  /// In en, this message translates to:
  /// **'Set location'**
  String get svSetLocation;

  /// No description provided for @svSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search services or categories...'**
  String get svSearchPlaceholder;

  /// No description provided for @svNoServicesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No services available'**
  String get svNoServicesAvailable;

  /// No description provided for @svNoServicesFound.
  ///
  /// In en, this message translates to:
  /// **'No services found'**
  String get svNoServicesFound;

  /// No description provided for @svNoCategoryListings.
  ///
  /// In en, this message translates to:
  /// **'That category does not have live listings yet.'**
  String get svNoCategoryListings;

  /// No description provided for @svTryBroaderKeyword.
  ///
  /// In en, this message translates to:
  /// **'Try a broader keyword or clear your filters.'**
  String get svTryBroaderKeyword;

  /// No description provided for @svDistanceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Distance unknown'**
  String get svDistanceUnknown;

  /// No description provided for @svStartingFee.
  ///
  /// In en, this message translates to:
  /// **'Starting Fee'**
  String get svStartingFee;

  /// No description provided for @svFilterRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get svFilterRecommended;

  /// No description provided for @svFilterTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get svFilterTopRated;

  /// No description provided for @svFilterLowestPrice.
  ///
  /// In en, this message translates to:
  /// **'Lowest price'**
  String get svFilterLowestPrice;

  /// No description provided for @svFilterNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest first'**
  String get svFilterNearest;

  /// No description provided for @svPinnedAddress.
  ///
  /// In en, this message translates to:
  /// **'Pinned address'**
  String get svPinnedAddress;

  /// No description provided for @svVoiceComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Voice search coming soon'**
  String get svVoiceComingSoon;

  /// No description provided for @pfNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get pfNotFound;

  /// No description provided for @pfAccountGroup.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get pfAccountGroup;

  /// No description provided for @pfMyBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get pfMyBookings;

  /// No description provided for @pfMyBookingsSub.
  ///
  /// In en, this message translates to:
  /// **'View past and upcoming jobs'**
  String get pfMyBookingsSub;

  /// No description provided for @pfPaymentInvoices.
  ///
  /// In en, this message translates to:
  /// **'Payment & Invoices'**
  String get pfPaymentInvoices;

  /// No description provided for @pfPaymentInvoicesSub.
  ///
  /// In en, this message translates to:
  /// **'View history and download invoices'**
  String get pfPaymentInvoicesSub;

  /// No description provided for @pfLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language Preference'**
  String get pfLanguage;

  /// No description provided for @pfPrefsGroup.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES & UTILITIES'**
  String get pfPrefsGroup;

  /// No description provided for @pfFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get pfFavorites;

  /// No description provided for @pfFavoritesSub.
  ///
  /// In en, this message translates to:
  /// **'Jump back into the services you saved'**
  String get pfFavoritesSub;

  /// No description provided for @pfMyReviews.
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get pfMyReviews;

  /// No description provided for @pfMyReviewsSub.
  ///
  /// In en, this message translates to:
  /// **'See the feedback you have left'**
  String get pfMyReviewsSub;

  /// No description provided for @pfReferral.
  ///
  /// In en, this message translates to:
  /// **'Referral Program'**
  String get pfReferral;

  /// No description provided for @pfReferralSub.
  ///
  /// In en, this message translates to:
  /// **'Share and earn rewards'**
  String get pfReferralSub;

  /// No description provided for @pfNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get pfNotificationSettings;

  /// No description provided for @pfNotificationSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'Control alerts and reminders'**
  String get pfNotificationSettingsSub;

  /// No description provided for @pfHelpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get pfHelpCenter;

  /// No description provided for @pfHelpCenterSub.
  ///
  /// In en, this message translates to:
  /// **'FAQs and chat with our support team'**
  String get pfHelpCenterSub;

  /// No description provided for @pfSystemAccessGroup.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM ACCESS'**
  String get pfSystemAccessGroup;

  /// No description provided for @pfSecuritySub.
  ///
  /// In en, this message translates to:
  /// **'Password, login protection, and app security'**
  String get pfSecuritySub;

  /// No description provided for @pfLogOutSub.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account on this device'**
  String get pfLogOutSub;

  /// No description provided for @pfSavedPlaces.
  ///
  /// In en, this message translates to:
  /// **'Saved Places'**
  String get pfSavedPlaces;

  /// No description provided for @pfSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get pfSet;

  /// No description provided for @pfAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get pfAdd;

  /// No description provided for @pfVerificationGroup.
  ///
  /// In en, this message translates to:
  /// **'VERIFICATION'**
  String get pfVerificationGroup;

  /// No description provided for @pfAreYouProvider.
  ///
  /// In en, this message translates to:
  /// **'Are you a service provider?'**
  String get pfAreYouProvider;

  /// No description provided for @pfSwitchToProvider.
  ///
  /// In en, this message translates to:
  /// **'Switch to Provider Account'**
  String get pfSwitchToProvider;

  /// No description provided for @pfProviderDetected.
  ///
  /// In en, this message translates to:
  /// **'Provider account detected'**
  String get pfProviderDetected;

  /// No description provided for @pfProviderAppBody.
  ///
  /// In en, this message translates to:
  /// **'Service providers use the dedicated Serbisyo Provider app. Open the store to install it, then sign in with the same account.'**
  String get pfProviderAppBody;

  /// No description provided for @pfOpenProviderAppStore.
  ///
  /// In en, this message translates to:
  /// **'Open Provider App Store'**
  String get pfOpenProviderAppStore;

  /// No description provided for @pfInviteCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite link copied — share it to earn rewards!'**
  String get pfInviteCopied;

  /// No description provided for @pfUploadingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo…'**
  String get pfUploadingPhoto;

  /// No description provided for @pfUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload photo. Please try again.'**
  String get pfUploadFailed;

  /// No description provided for @pfPhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated!'**
  String get pfPhotoUpdated;

  /// No description provided for @pfUploadError.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String pfUploadError(Object error);

  /// No description provided for @pfChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get pfChooseGallery;

  /// No description provided for @pfTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get pfTakePhoto;

  /// No description provided for @pmTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get pmTitle;

  /// No description provided for @pmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage how you pay for bookings.'**
  String get pmSubtitle;

  /// No description provided for @pmEndingIn.
  ///
  /// In en, this message translates to:
  /// **'ending in {lastFour}'**
  String pmEndingIn(Object lastFour);

  /// No description provided for @pmExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires {month}/{year}'**
  String pmExpires(Object month, Object year);

  /// No description provided for @pmEwallet.
  ///
  /// In en, this message translates to:
  /// **'E-Wallet'**
  String get pmEwallet;

  /// No description provided for @pmNoPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone number'**
  String get pmNoPhone;

  /// No description provided for @pmEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No payment methods yet'**
  String get pmEmptyTitle;

  /// No description provided for @pmEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a card or e-wallet so checkout is faster when you book.'**
  String get pmEmptySubtitle;

  /// No description provided for @pmErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading payment methods'**
  String get pmErrorLoading;

  /// No description provided for @pmAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Payment Method'**
  String get pmAddTitle;

  /// No description provided for @pmSetDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get pmSetDefault;

  /// No description provided for @pmSetDefaultFull.
  ///
  /// In en, this message translates to:
  /// **'Set as default payment method'**
  String get pmSetDefaultFull;

  /// No description provided for @pmEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get pmEdit;

  /// No description provided for @pmRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get pmRemove;

  /// No description provided for @pmRemoved.
  ///
  /// In en, this message translates to:
  /// **'Payment method removed'**
  String get pmRemoved;

  /// No description provided for @pmCreditDebitCard.
  ///
  /// In en, this message translates to:
  /// **'Credit/Debit Card'**
  String get pmCreditDebitCard;

  /// No description provided for @pmEwalletOptions.
  ///
  /// In en, this message translates to:
  /// **'E-Wallet (GCash, Maya)'**
  String get pmEwalletOptions;

  /// No description provided for @pmNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get pmNotAuthenticated;

  /// No description provided for @pewUpdated.
  ///
  /// In en, this message translates to:
  /// **'E-wallet updated successfully'**
  String get pewUpdated;

  /// No description provided for @pewAdded.
  ///
  /// In en, this message translates to:
  /// **'E-wallet added successfully'**
  String get pewAdded;

  /// No description provided for @pewSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving e-wallet: {error}'**
  String pewSaveError(Object error);

  /// No description provided for @pewTitle.
  ///
  /// In en, this message translates to:
  /// **'Add E-Wallet'**
  String get pewTitle;

  /// No description provided for @pewInfoHeader.
  ///
  /// In en, this message translates to:
  /// **'E-Wallet Information'**
  String get pewInfoHeader;

  /// No description provided for @pewProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get pewProvider;

  /// No description provided for @pewSelectProvider.
  ///
  /// In en, this message translates to:
  /// **'Please select provider'**
  String get pewSelectProvider;

  /// No description provided for @pewPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get pewPhoneNumber;

  /// No description provided for @pewEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pewEnterPhone;

  /// No description provided for @pewValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 11-digit phone number'**
  String get pewValidPhone;

  /// No description provided for @pewAccountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get pewAccountName;

  /// No description provided for @pewEnterAccountName.
  ///
  /// In en, this message translates to:
  /// **'Please enter account name'**
  String get pewEnterAccountName;

  /// No description provided for @pcaUpdated.
  ///
  /// In en, this message translates to:
  /// **'Card updated successfully'**
  String get pcaUpdated;

  /// No description provided for @pcaAdded.
  ///
  /// In en, this message translates to:
  /// **'Card added successfully'**
  String get pcaAdded;

  /// No description provided for @pcaSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving card: {error}'**
  String pcaSaveError(Object error);

  /// No description provided for @pcaTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get pcaTitle;

  /// No description provided for @pcaInfoHeader.
  ///
  /// In en, this message translates to:
  /// **'Card Information'**
  String get pcaInfoHeader;

  /// No description provided for @pcaCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get pcaCardNumber;

  /// No description provided for @pcaEnterCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter card number'**
  String get pcaEnterCardNumber;

  /// No description provided for @pcaValidCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid card number'**
  String get pcaValidCardNumber;

  /// No description provided for @pcaCardType.
  ///
  /// In en, this message translates to:
  /// **'Card Type'**
  String get pcaCardType;

  /// No description provided for @pcaSelectCardType.
  ///
  /// In en, this message translates to:
  /// **'Please select card type'**
  String get pcaSelectCardType;

  /// No description provided for @pcaRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get pcaRequired;

  /// No description provided for @pcaInvalidMonth.
  ///
  /// In en, this message translates to:
  /// **'Invalid month'**
  String get pcaInvalidMonth;

  /// No description provided for @pcaInvalidYear.
  ///
  /// In en, this message translates to:
  /// **'Invalid year'**
  String get pcaInvalidYear;

  /// No description provided for @pcaCardholderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get pcaCardholderName;

  /// No description provided for @pcaEnterCardholderName.
  ///
  /// In en, this message translates to:
  /// **'Please enter cardholder name'**
  String get pcaEnterCardholderName;

  /// No description provided for @msTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get msTitle;

  /// No description provided for @msSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay close to providers, updates, and support.'**
  String get msSubtitle;

  /// No description provided for @msChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get msChats;

  /// No description provided for @msCallsHistory.
  ///
  /// In en, this message translates to:
  /// **'Calls history'**
  String get msCallsHistory;

  /// No description provided for @msSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search conversations or calls'**
  String get msSearchPlaceholder;

  /// No description provided for @msRecentConversations.
  ///
  /// In en, this message translates to:
  /// **'Recent conversations'**
  String get msRecentConversations;

  /// No description provided for @msRecentCalls.
  ///
  /// In en, this message translates to:
  /// **'Recent calls'**
  String get msRecentCalls;

  /// No description provided for @msItems.
  ///
  /// In en, this message translates to:
  /// **'{itemCount} items'**
  String msItems(Object itemCount);

  /// No description provided for @msNoConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get msNoConversations;

  /// No description provided for @msNoConversationsMatch.
  ///
  /// In en, this message translates to:
  /// **'No conversations matched'**
  String get msNoConversationsMatch;

  /// No description provided for @msEmptyChatsBody.
  ///
  /// In en, this message translates to:
  /// **'Messages from your providers will show up here once a booking starts.'**
  String get msEmptyChatsBody;

  /// No description provided for @msTryAnotherProvider.
  ///
  /// In en, this message translates to:
  /// **'Try another provider name or keyword.'**
  String get msTryAnotherProvider;

  /// No description provided for @msNoCalls.
  ///
  /// In en, this message translates to:
  /// **'No call activity yet'**
  String get msNoCalls;

  /// No description provided for @msNoCallsMatch.
  ///
  /// In en, this message translates to:
  /// **'No calls matched'**
  String get msNoCallsMatch;

  /// No description provided for @msEmptyCallsBody.
  ///
  /// In en, this message translates to:
  /// **'Your completed and missed calls will appear here when that history is available.'**
  String get msEmptyCallsBody;

  /// No description provided for @msTryOtherSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term.'**
  String get msTryOtherSearch;

  /// No description provided for @msNoMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get msNoMessages;

  /// No description provided for @msConversation.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get msConversation;

  /// No description provided for @msUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{unreadCount} unread'**
  String msUnreadCount(Object unreadCount);

  /// No description provided for @msJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get msJustNow;

  /// No description provided for @msMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}m ago'**
  String msMinutesAgo(Object n);

  /// No description provided for @msHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}h ago'**
  String msHoursAgo(Object n);

  /// No description provided for @msDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}d ago'**
  String msDaysAgo(Object n);

  /// No description provided for @hmSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search services...'**
  String get hmSearchPlaceholder;

  /// No description provided for @hmMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get hmMore;

  /// No description provided for @hmBookingStartsPinned.
  ///
  /// In en, this message translates to:
  /// **'Booking starts from your pinned location'**
  String get hmBookingStartsPinned;

  /// No description provided for @hmPinnedAddress.
  ///
  /// In en, this message translates to:
  /// **'Pinned address'**
  String get hmPinnedAddress;

  /// No description provided for @hmCurrentDeviceLocation.
  ///
  /// In en, this message translates to:
  /// **'Current device location'**
  String get hmCurrentDeviceLocation;

  /// No description provided for @hmSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select your location'**
  String get hmSelectLocation;

  /// No description provided for @hmExitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get hmExitApp;

  /// No description provided for @hmExitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the app?'**
  String get hmExitConfirm;

  /// No description provided for @hmExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get hmExit;

  /// No description provided for @hmChooseLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose location'**
  String get hmChooseLocation;

  /// No description provided for @hmChooseLocationSub.
  ///
  /// In en, this message translates to:
  /// **'Use your live device location or one of your saved addresses.'**
  String get hmChooseLocationSub;

  /// No description provided for @hmUseLiveLocation.
  ///
  /// In en, this message translates to:
  /// **'Use your live phone location on the map'**
  String get hmUseLiveLocation;

  /// No description provided for @hmEnableLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Enable location services to use this option'**
  String get hmEnableLocationServices;

  /// No description provided for @hmSavedAddress.
  ///
  /// In en, this message translates to:
  /// **'Saved address'**
  String get hmSavedAddress;

  /// No description provided for @hmWaitingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for provider confirmation'**
  String get hmWaitingConfirmation;

  /// No description provided for @hmProviderConfirmedToday.
  ///
  /// In en, this message translates to:
  /// **'Provider confirmed for today'**
  String get hmProviderConfirmedToday;

  /// No description provided for @hmCatCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get hmCatCleaning;

  /// No description provided for @hmCatPlumbing.
  ///
  /// In en, this message translates to:
  /// **'Plumbing'**
  String get hmCatPlumbing;

  /// No description provided for @hmCatElectrical.
  ///
  /// In en, this message translates to:
  /// **'Electrical'**
  String get hmCatElectrical;

  /// No description provided for @hmCatPainting.
  ///
  /// In en, this message translates to:
  /// **'Painting'**
  String get hmCatPainting;

  /// No description provided for @exTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exTitle;

  /// No description provided for @exSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover top-rated pros and seasonal deals.'**
  String get exSubtitle;

  /// No description provided for @exSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search services or providers'**
  String get exSearchPlaceholder;

  /// No description provided for @exVoiceComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Voice search coming soon'**
  String get exVoiceComingSoon;

  /// No description provided for @exServiceCategory.
  ///
  /// In en, this message translates to:
  /// **'Service Category'**
  String get exServiceCategory;

  /// No description provided for @exViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get exViewAll;

  /// No description provided for @exTopRatedNearYou.
  ///
  /// In en, this message translates to:
  /// **'Top Rated Near You'**
  String get exTopRatedNearYou;

  /// No description provided for @exServiceProviderFallback.
  ///
  /// In en, this message translates to:
  /// **'Service Provider'**
  String get exServiceProviderFallback;

  /// No description provided for @exRecommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get exRecommendedForYou;

  /// No description provided for @exNoRecommendations.
  ///
  /// In en, this message translates to:
  /// **'No recommendations yet — book a service to personalize this feed.'**
  String get exNoRecommendations;

  /// No description provided for @exInviteCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite link copied — share it with friends!'**
  String get exInviteCopied;

  /// No description provided for @ctgTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get ctgTitle;

  /// No description provided for @ctgSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Jump into the service type you need most.'**
  String get ctgSubtitle;

  /// No description provided for @bkfTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bkfTitle;

  /// No description provided for @bkfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track active work, completed visits, and next steps.'**
  String get bkfSubtitle;

  /// No description provided for @bkfPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get bkfPending;

  /// No description provided for @bkfCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bkfCompleted;

  /// No description provided for @bkfCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get bkfCanceled;

  /// No description provided for @bkfRescheduleSoon.
  ///
  /// In en, this message translates to:
  /// **'Rescheduling is coming soon.'**
  String get bkfRescheduleSoon;

  /// No description provided for @ehConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the server. Check your internet connection and try again.'**
  String get ehConnectionError;

  /// No description provided for @ehGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get ehGenericError;

  /// No description provided for @ehInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format. Please try again.'**
  String get ehInvalidFormat;

  /// No description provided for @ehInvalidArgument.
  ///
  /// In en, this message translates to:
  /// **'Invalid input. Please try again.'**
  String get ehInvalidArgument;

  /// No description provided for @auSignOutError.
  ///
  /// In en, this message translates to:
  /// **'There was a problem signing you out. Please try again.'**
  String get auSignOutError;

  /// No description provided for @auVerificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get auVerificationEmailSent;

  /// No description provided for @auVerificationError.
  ///
  /// In en, this message translates to:
  /// **'There was a problem sending the verification email. Please try again.'**
  String get auVerificationError;

  /// No description provided for @panProviderAppBody.
  ///
  /// In en, this message translates to:
  /// **'Provider tools have moved to the Serbisyo Provider app. You can continue using this app as a client, or sign out.'**
  String get panProviderAppBody;

  /// No description provided for @panSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get panSignOut;

  /// No description provided for @panContinueAsClient.
  ///
  /// In en, this message translates to:
  /// **'Continue as client'**
  String get panContinueAsClient;

  /// No description provided for @panNavigationError.
  ///
  /// In en, this message translates to:
  /// **'Navigation error. Please try again.'**
  String get panNavigationError;

  /// No description provided for @pmtFailedObtainClientSecret.
  ///
  /// In en, this message translates to:
  /// **'Failed to obtain payment client secret'**
  String get pmtFailedObtainClientSecret;

  /// No description provided for @pmtFailedObtainCheckoutUrl.
  ///
  /// In en, this message translates to:
  /// **'Failed to obtain checkout URL'**
  String get pmtFailedObtainCheckoutUrl;

  /// No description provided for @pmtPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get pmtPaymentFailed;

  /// No description provided for @wtUnknownService.
  ///
  /// In en, this message translates to:
  /// **'Unknown Service'**
  String get wtUnknownService;

  /// No description provided for @wtClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get wtClient;

  /// No description provided for @wtDebitDesc.
  ///
  /// In en, this message translates to:
  /// **'Payment to Provider — {serviceName}'**
  String wtDebitDesc(Object serviceName);

  /// No description provided for @wtCreditDesc.
  ///
  /// In en, this message translates to:
  /// **'Service Payment — {serviceName} ({clientName})'**
  String wtCreditDesc(Object serviceName, Object clientName);

  /// No description provided for @wtDateNa.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get wtDateNa;

  /// No description provided for @hmSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved addresses'**
  String get hmSavedAddresses;

  /// No description provided for @bfAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get bfAddress;

  /// No description provided for @bkEmptySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'No bookings matched'**
  String get bkEmptySearchTitle;

  /// No description provided for @bkEmptySearchDesc.
  ///
  /// In en, this message translates to:
  /// **'Try another keyword or switch the status filter.'**
  String get bkEmptySearchDesc;

  /// No description provided for @bkEmptyAllTitle.
  ///
  /// In en, this message translates to:
  /// **'No bookings found'**
  String get bkEmptyAllTitle;

  /// No description provided for @bkEmptyAllDesc.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t scheduled any services yet. Find a pro to get started!'**
  String get bkEmptyAllDesc;

  /// No description provided for @bkEmptyPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'No pending jobs'**
  String get bkEmptyPendingTitle;

  /// No description provided for @bkEmptyPendingDesc.
  ///
  /// In en, this message translates to:
  /// **'Any service requests waiting for provider approval will appear here.'**
  String get bkEmptyPendingDesc;

  /// No description provided for @bkEmptyCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'No completed visits yet'**
  String get bkEmptyCompletedTitle;

  /// No description provided for @bkEmptyCompletedDesc.
  ///
  /// In en, this message translates to:
  /// **'Once a service technician finishes a job, your history will show up here.'**
  String get bkEmptyCompletedDesc;

  /// No description provided for @bkEmptyCanceledTitle.
  ///
  /// In en, this message translates to:
  /// **'No canceled bookings'**
  String get bkEmptyCanceledTitle;

  /// No description provided for @bkEmptyCanceledDesc.
  ///
  /// In en, this message translates to:
  /// **'Great! You don\'t have any canceled or interrupted service requests.'**
  String get bkEmptyCanceledDesc;

  /// No description provided for @bkStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get bkStatusUnknown;

  /// No description provided for @bkStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get bkStatusPending;

  /// No description provided for @bkStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get bkStatusConfirmed;

  /// No description provided for @bkStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get bkStatusInProgress;

  /// No description provided for @bkStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bkStatusCompleted;

  /// No description provided for @bkStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bkStatusCancelled;

  /// No description provided for @bkFallbackUnknownService.
  ///
  /// In en, this message translates to:
  /// **'Unknown Service'**
  String get bkFallbackUnknownService;

  /// No description provided for @bkFallbackService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get bkFallbackService;

  /// No description provided for @adSelectAddress.
  ///
  /// In en, this message translates to:
  /// **'Select address'**
  String get adSelectAddress;

  /// No description provided for @rlsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent!'**
  String get rlsTitle;

  /// No description provided for @rlsBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a password reset link to your email address. Please check your inbox and follow the instructions to reset your password.'**
  String get rlsBody;

  /// No description provided for @tmSubHomeLockout.
  ///
  /// In en, this message translates to:
  /// **'Home Lockout'**
  String get tmSubHomeLockout;

  /// No description provided for @tmSubLockRepair.
  ///
  /// In en, this message translates to:
  /// **'Lock Repair'**
  String get tmSubLockRepair;

  /// No description provided for @tmSubLockReplace.
  ///
  /// In en, this message translates to:
  /// **'Lock Replacement'**
  String get tmSubLockReplace;

  /// No description provided for @tmSubPipeLeak.
  ///
  /// In en, this message translates to:
  /// **'Pipe Leak Repair'**
  String get tmSubPipeLeak;

  /// No description provided for @tmSubFaucetValve.
  ///
  /// In en, this message translates to:
  /// **'Faucet / Valve Issue'**
  String get tmSubFaucetValve;

  /// No description provided for @tmSubDrainClog.
  ///
  /// In en, this message translates to:
  /// **'Drain Clog Clearing'**
  String get tmSubDrainClog;

  /// No description provided for @tmSubOutletSwitch.
  ///
  /// In en, this message translates to:
  /// **'Outlet / Switch Issue'**
  String get tmSubOutletSwitch;

  /// No description provided for @tmSubBreakerTrip.
  ///
  /// In en, this message translates to:
  /// **'Breaker Trip Investigation'**
  String get tmSubBreakerTrip;

  /// No description provided for @tmSubLightingRepair.
  ///
  /// In en, this message translates to:
  /// **'Lighting Repair'**
  String get tmSubLightingRepair;

  /// No description provided for @tmSubWasherDryer.
  ///
  /// In en, this message translates to:
  /// **'Washer / Dryer Issue'**
  String get tmSubWasherDryer;

  /// No description provided for @tmSubRefrigerator.
  ///
  /// In en, this message translates to:
  /// **'Refrigerator Issue'**
  String get tmSubRefrigerator;

  /// No description provided for @tmSubSmallAppliance.
  ///
  /// In en, this message translates to:
  /// **'Small Appliance Repair'**
  String get tmSubSmallAppliance;

  /// No description provided for @tmSubQuickRepair.
  ///
  /// In en, this message translates to:
  /// **'Quick Repair Visit'**
  String get tmSubQuickRepair;

  /// No description provided for @tmSubDiagnostic.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic Visit'**
  String get tmSubDiagnostic;

  /// No description provided for @tmSubUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent Assistance'**
  String get tmSubUrgent;

  /// No description provided for @tmTabMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get tmTabMap;

  /// No description provided for @tmTabChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get tmTabChat;

  /// No description provided for @tmTabProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get tmTabProvider;

  /// No description provided for @tmDispatchServer.
  ///
  /// In en, this message translates to:
  /// **'Dispatch path: server-authoritative'**
  String get tmDispatchServer;

  /// No description provided for @tmDispatchFallback.
  ///
  /// In en, this message translates to:
  /// **'Dispatch path: fallback matcher'**
  String get tmDispatchFallback;

  /// No description provided for @tmDispatchPending.
  ///
  /// In en, this message translates to:
  /// **'Dispatch path: pending'**
  String get tmDispatchPending;

  /// No description provided for @tmEtaFormat.
  ///
  /// In en, this message translates to:
  /// **'ETA {min} min'**
  String tmEtaFormat(Object min);

  /// No description provided for @tmRadiusLabel.
  ///
  /// In en, this message translates to:
  /// **'{km} km radius'**
  String tmRadiusLabel(Object km);

  /// No description provided for @tmModeServer.
  ///
  /// In en, this message translates to:
  /// **'Server dispatch'**
  String get tmModeServer;

  /// No description provided for @tmModeFallback.
  ///
  /// In en, this message translates to:
  /// **'Fallback dispatch'**
  String get tmModeFallback;

  /// No description provided for @tmModePending.
  ///
  /// In en, this message translates to:
  /// **'Dispatch pending'**
  String get tmModePending;

  /// No description provided for @tmPmtCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get tmPmtCard;

  /// No description provided for @tmPmtCashCompletion.
  ///
  /// In en, this message translates to:
  /// **'Cash on Completion'**
  String get tmPmtCashCompletion;

  /// No description provided for @tmPmtCardDesc.
  ///
  /// In en, this message translates to:
  /// **'Visa, Mastercard, and debit cards'**
  String get tmPmtCardDesc;

  /// No description provided for @lmRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get lmRoute;

  /// No description provided for @lmReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get lmReference;

  /// No description provided for @ppFallbackCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get ppFallbackCustomer;

  /// No description provided for @ckPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get ckPlaceholder;

  /// No description provided for @spBookingRefPrefix.
  ///
  /// In en, this message translates to:
  /// **'Booking #'**
  String get spBookingRefPrefix;

  /// No description provided for @bsCalTitle.
  ///
  /// In en, this message translates to:
  /// **'Serbisyo booking'**
  String get bsCalTitle;

  /// No description provided for @bsCalDesc.
  ///
  /// In en, this message translates to:
  /// **'Booking {id} via Serbisyo'**
  String bsCalDesc(Object id);

  /// No description provided for @tmHwTitle.
  ///
  /// In en, this message translates to:
  /// **'Hardware Parts Required'**
  String get tmHwTitle;

  /// No description provided for @tmProviderDefault.
  ///
  /// In en, this message translates to:
  /// **'Service Provider'**
  String get tmProviderDefault;

  /// No description provided for @tmVehicleNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby service unit'**
  String get tmVehicleNearby;

  /// No description provided for @tmVehicleExpanded.
  ///
  /// In en, this message translates to:
  /// **'Expanded-area service unit'**
  String get tmVehicleExpanded;

  /// No description provided for @tmProviderFallback.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get tmProviderFallback;

  /// No description provided for @tmVehicleFallback.
  ///
  /// In en, this message translates to:
  /// **'Service unit'**
  String get tmVehicleFallback;

  /// No description provided for @bkPmtCOD.
  ///
  /// In en, this message translates to:
  /// **'COD'**
  String get bkPmtCOD;

  /// No description provided for @pfAddProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Add profile picture'**
  String get pfAddProfilePicture;

  /// No description provided for @pfChangeProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Change profile picture'**
  String get pfChangeProfilePicture;

  /// No description provided for @pfRemoveProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Remove profile picture'**
  String get pfRemoveProfilePicture;

  /// No description provided for @pfRemovePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove profile picture?'**
  String get pfRemovePhotoTitle;

  /// No description provided for @pfRemovePhotoMessage.
  ///
  /// In en, this message translates to:
  /// **'Your photo will be removed from your public profile.'**
  String get pfRemovePhotoMessage;

  /// No description provided for @pfPhotoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Profile picture removed.'**
  String get pfPhotoRemoved;

  /// No description provided for @emBadge.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emBadge;

  /// No description provided for @emTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Help'**
  String get emTitle;

  /// No description provided for @emSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Urgent services in your area, dispatched right now.'**
  String get emSubtitle;

  /// No description provided for @emEmpty.
  ///
  /// In en, this message translates to:
  /// **'No emergency services are available right now.'**
  String get emEmpty;

  /// No description provided for @emClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get emClose;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fil'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fil':
      return AppLocalizationsFil();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
