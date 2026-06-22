import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SerbisyoHub PH'**
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
      <String>['en', 'es'].contains(locale.languageCode);

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
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
