import io, os
ROOT = r'E:\Dev\SHPH'
L10n = "import '/l10n/app_localizations.dart';\n"


def run(f, repls):
    p = os.path.join(ROOT, f.replace('/', '\\'))
    t = io.open(p, encoding='utf-8').read()
    ok = True
    for old, new in repls:
        if old not in t:
            print('  NOT FOUND:', repr(old[:60]))
            ok = False
            continue
        t = t.replace(old, new, 1)
    if ok:
        io.open(p, 'w', encoding='utf-8', newline='').write(t)
        print('OK:', f)
    else:
        print('FAIL (no save):', f)


# biometric_setup (full set, with corrected SnackBar indent + const strip)
run('lib/pages/biometric_setup/biometric_setup_widget.dart', [
    ("import '/flutter_flow/flutter_flow_util.dart';\nimport '/theme/app_theme.dart';\nimport 'biometric_setup_model.dart';",
     "import '/flutter_flow/flutter_flow_util.dart';\n" + L10n + "import '/theme/app_theme.dart';\nimport 'biometric_setup_model.dart';"),
    ("  final _deviceNameCtrl = TextEditingController();\n",
     "  final _deviceNameCtrl = TextEditingController();\n  AppLocalizations get _l10n => AppLocalizations.of(context)!;\n"),
    ("title: 'Biometric Setup',", "title: _l10n.bioSetupTitle,"),
    ("'Use your fingerprint or face to sign in quickly and securely.'", "_l10n.bioSetupSubtitle"),
    ("Text('Register this device',", "Text(_l10n.bioSetupRegister,'" if False else "Text(_l10n.bioSetupRegister,"),
    ("placeholder: 'Device name (e.g. My Phone)',", "placeholder: _l10n.bioSetupDeviceNameHint,"),
    ("? 'My Device'", "? _l10n.bioSetupDeviceNameDefault"),
    ("'Device registered'", "_l10n.bioSetupRegistered"),
    ("'Registration failed'", "_l10n.bioSetupRegistrationFailed"),
    ("const SnackBar(", "SnackBar("),  # strip const (both snackbars)
    ("const Text('Register this device')", "Text(_l10n.bioSetupRegister)"),
    ("Text('Registered Devices',", "Text(_l10n.bioSetupRegisteredDevices,"),
    ("cred['device_name']?.toString() ?? 'Unknown';", "cred['device_name']?.toString() ?? _l10n.bioSetupUnknown;"),
])

# my_notifications (full set, corrected Notification settings line)
run('lib/pages/my_notifications/my_notifications_widget.dart', [
    ("import '/flutter_flow/flutter_flow_util.dart';\nimport '/index.dart';",
     "import '/flutter_flow/flutter_flow_util.dart';\nimport '/index.dart';\n" + L10n),
    ("  final scaffoldKey = GlobalKey<ScaffoldState>();\n\n  @override\n  void initState()",
     "  final scaffoldKey = GlobalKey<ScaffoldState>();\n  AppLocalizations get _l10n => AppLocalizations.of(context)!;\n\n  @override\n  void initState()"),
    ("title: 'Error loading notifications',", "title: _l10n.errorLoadingNotifications,"),
    ("'Something went wrong while fetching your updates.'", "_l10n.errorLoadingSubtitle"),
    ("title: 'No notifications',", "title: _l10n.noNotifications,"),
    ("child: Text(\n                'Notification',", "child: Text(\n                _l10n.mnTitle,"),
    ("'Notification settings',", "_l10n.mnSettings,"),
    ("_isMarkingAllRead ? 'Marking...' : 'Mark all as read',", "_isMarkingAllRead ? _l10n.mnMarking : _l10n.mnMarkAllRead,"),
    ("'Granular controls live inside each service update.'", "_l10n.mnGranularHint,"),
    ("(NotificationFilter.all, 'All'),", "(NotificationFilter.all, _l10n.mnTabAll),"),
    ("(NotificationFilter.bookings, 'Bookings'),", "(NotificationFilter.bookings, _l10n.mnTabBookings),"),
    ("(NotificationFilter.offers, 'Offers'),", "(NotificationFilter.offers, _l10n.mnTabOffers),"),
    ("(NotificationFilter.system, 'System'),", "(NotificationFilter.system, _l10n.mnTabSystem),"),
    ("'Booking updates will land here as providers respond.',", "_l10n.mnEmptyBookings,"),
    ("'Promos and special offers will show up here.'", "_l10n.mnEmptyOffers,"),
    ("'System updates will appear here when available.'", "_l10n.mnEmptySystem,"),
    ("NotificationFilter.all => 'You are all caught up right now.'", "NotificationFilter.all => _l10n.noNotificationsSubtitle"),
    (": 'Open this update to see more details.'", ": _l10n.mnOpenDetails,"),
    ("return 'Just now';", "return _l10n.justNow;"),
    ("return '${difference.inMinutes}m ago';", "return _l10n.mnMinutesAgo(difference.inMinutes);"),
    ("return '${difference.inHours}h ago';", "return _l10n.mnHoursAgo(difference.inHours);"),
    ("return '${difference.inDays}d ago';", "return _l10n.mnDaysAgo(difference.inDays);"),
])

print('DONE')
