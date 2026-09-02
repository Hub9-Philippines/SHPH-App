import io, os
ROOT = r'E:\Dev\SHPH'
L10n = "import '/l10n/app_localizations.dart';\n"


def run(f, repls):
    p = os.path.join(ROOT, f.replace('/', '\\'))
    t = io.open(p, encoding='utf-8').read()
    ok = True
    for old, new in repls:
        if old not in t:
            print('  NOT FOUND:', repr(old[:55]))
            ok = False
            continue
        t = t.replace(old, new, 1)
    if ok:
        io.open(p, 'w', encoding='utf-8', newline='').write(t)
        print('OK:', f)
    else:
        print('FAIL (no save):', f)


run('lib/pages/my_notifications/my_notifications_widget.dart', [
    ("import '/flutter_flow/flutter_flow_util.dart';\nimport '/index.dart';",
     "import '/flutter_flow/flutter_flow_util.dart';\nimport '/index.dart';\n" + L10n),
    ("  final scaffoldKey = GlobalKey<ScaffoldState>();\n\n  @override\n  void initState()",
     "  final scaffoldKey = GlobalKey<ScaffoldState>();\n  AppLocalizations get _l10n => AppLocalizations.of(context)!;\n\n  @override\n  void initState()"),
    ("            title: 'Error loading notifications',", "            title: _l10n.errorLoadingNotifications,"),
    ("'Something went wrong while fetching your updates.'", "_l10n.errorLoadingSubtitle"),
    ("            title: 'No notifications',", "            title: _l10n.noNotifications,"),
    ("child: Text(\n                'Notification',", "child: Text(\n                _l10n.mnTitle,"),
    ("title: Text(\n                  'Notification settings',", "title: Text(\n                  _l10n.mnSettings,"),
    ("_isMarkingAllRead ? 'Marking...' : 'Mark all as read',", "_isMarkingAllRead ? _l10n.mnMarking : _l10n.mnMarkAllRead,"),
    ("'Granular controls live inside each service update.'", "_l10n.mnGranularHint,"),
    ("(NotificationFilter.all, 'All'),", "(NotificationFilter.all, _l10n.mnTabAll),"),
    ("(NotificationFilter.bookings, 'Bookings'),", "(NotificationFilter.bookings, _l10n.mnTabBookings),"),
    ("(NotificationFilter.offers, 'Offers'),", "(NotificationFilter.offers, _l10n.mnTabOffers),"),
    ("(NotificationFilter.system, 'System'),", "(NotificationFilter.system, _l10n.mnTabSystem),"),
    ("'Booking updates will land here as providers respond.',", "_l10n.mnEmptyBookings,"),
    ("'Promos and special offers will show up here.',", "_l10n.mnEmptyOffers,"),
    ("'System updates will appear here when available.'", "_l10n.mnEmptySystem,"),
    ("NotificationFilter.all => 'You are all caught up right now.'", "NotificationFilter.all => _l10n.noNotificationsSubtitle"),
    (": 'Open this update to see more details.'", ": _l10n.mnOpenDetails,"),
    ("return 'Just now';", "return _l10n.justNow;"),
    ("return '${difference.inMinutes}m ago';", "return _l10n.mnMinutesAgo(difference.inMinutes);"),
    ("return '${difference.inHours}h ago';", "return _l10n.mnHoursAgo(difference.inHours);"),
    ("return '${difference.inDays}d ago';", "return _l10n.mnDaysAgo(difference.inDays);"),
])

run('lib/pages/call_permission/call_permission_widget.dart', [
    ("import '/flutter_flow/flutter_flow_util.dart';\nimport '/theme/app_theme.dart';\nimport 'call_permission_model.dart';",
     "import '/flutter_flow/flutter_flow_util.dart';\n" + L10n + "import '/theme/app_theme.dart';\nimport 'call_permission_model.dart';"),
    ("  late CallPermissionModel _model;\n",
     "  late CallPermissionModel _model;\n  AppLocalizations get _l10n => AppLocalizations.of(context)!;\n"),
    ("title: isVideo ? 'Camera & Microphone' : 'Microphone',", "title: isVideo ? _l10n.callPermTitleVideo : _l10n.callPermTitleAudio,"),
    ("? 'Allow camera & microphone'\n                    : 'Allow microphone',", "? _l10n.callPermAllowBoth\n                    : _l10n.callPermAllowMic,"),
    ("'Calling ${widget.participantName}'", "_l10n.callPermCalling(widget.participantName!)"),
    ("child: const Row(\n                    mainAxisSize: MainAxisSize.min,\n                    children: [\n                      Icon(Icons.check),\n                      SizedBox(width: 8),\n                      Text('Allow'),\n                    ],\n                  ),",
     "child: Row(\n                    mainAxisSize: MainAxisSize.min,\n                    children: [\n                      Icon(Icons.check),\n                      SizedBox(width: 8),\n                      Text(_l10n.callPermAllow),\n                    ],\n                  ),"),
    ("child: const Text('Cancel')", "child: Text(_l10n.cancel)"),
])

run('lib/pages/call_history_details_page/call_history_details_page_widget.dart', [
    ("import '/flutter_flow/flutter_flow_util.dart';\nimport '/flutter_flow/flutter_flow_widgets.dart';",
     "import '/flutter_flow/flutter_flow_util.dart';\nimport '/flutter_flow/flutter_flow_widgets.dart';\n" + L10n),
    ("  final scaffoldKey = GlobalKey<ScaffoldState>();\n",
     "  final scaffoldKey = GlobalKey<ScaffoldState>();\n  AppLocalizations get _l10n => AppLocalizations.of(context)!;\n"),
    ("if (dateTime == null) return 'Unknown';", "if (dateTime == null) return _l10n.chdUnknown;"),
    ("title: 'Call Details',", "title: _l10n.chdTitle,"),
    ("widget.providerName ?? 'Unknown Provider',", "widget.providerName ?? _l10n.chdUnknownProvider,"),
    ("'Call Information',", "_l10n.chdInfoTitle,"),
    ("'Status',", "_l10n.chdStatus,"),
    ("'Duration',", "_l10n.chdDuration,"),
    ("'Date & Time',", "_l10n.chdDateTitle,"),
    ("text: 'Call Back',", "text: _l10n.chdCallBack,"),
    ("text: 'Message',", "text: _l10n.chdMessage,"),
])

print('DONE')
