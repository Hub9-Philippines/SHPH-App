// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SerbisyoHub PH';

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
}
