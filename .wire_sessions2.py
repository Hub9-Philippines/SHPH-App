import io

ROOT = r'E:\Dev\SHPH'


def load(f):
    p = ROOT + '\\' + f.replace('/', '\\')
    return io.open(p, encoding='utf-8').read(), p


def save(t, p):
    io.open(p, 'w', encoding='utf-8', newline='').write(t)


def apply(f, repls):
    t, p = load(f)
    ok = True
    for old, new in repls:
        if old not in t:
            print('  NOT FOUND:', repr(old[:60]))
            ok = False
            continue
        t = t.replace(old, new, 1)
    if ok:
        save(t, p)
    print('OK' if ok else 'FAIL', f)


apply('lib/pages/sessions/sessions_widget.dart', [
    ("import '/flutter_flow/flutter_flow_util.dart';\nimport '/theme/app_theme.dart';\nimport 'sessions_model.dart';",
     "import '/flutter_flow/flutter_flow_util.dart';\nimport '/l10n/app_localizations.dart';\nimport '/theme/app_theme.dart';\nimport 'sessions_model.dart';"),
    ("  late SessionsModel _model;\n",
     "  late SessionsModel _model;\n  AppLocalizations get _l10n => AppLocalizations.of(context)!;\n"),
    ("        title: const Text('Sign Out All Devices'),",
     "        title: Text(_l10n.snSignOutAllDevices),"),
    ("        content: const Text(\n          'This will sign you out of all active sessions except this one.',\n        ),",
     "        content: Text(\n          _l10n.snSignOutAllConfirm,\n        ),"),
    ("            child: const Text('Cancel'),",
     "            child: Text(_l10n.cancel),"),
    ("            child: const Text('Sign Out All'),",
     "            child: Text(_l10n.snSignOutAll),"),
    ("ScaffoldMessenger.of(context).showSnackBar(\n            const SnackBar(content: Text('All other sessions revoked')),\n          );",
     "ScaffoldMessenger.of(context).showSnackBar(\n            SnackBar(content: Text(_l10n.snAllRevoked)),\n          );"),
    ("ScaffoldMessenger.of(context).showSnackBar(\n            const SnackBar(content: Text('Failed to revoke sessions')),\n          );",
     "ScaffoldMessenger.of(context).showSnackBar(\n            SnackBar(content: Text(_l10n.snFailedRevokeAll)),\n          );"),
    ("ScaffoldMessenger.of(context).showSnackBar(\n            const SnackBar(content: Text('Session revoked')),\n          );",
     "ScaffoldMessenger.of(context).showSnackBar(\n            SnackBar(content: Text(_l10n.snRevoked)),\n          );"),
    ("ScaffoldMessenger.of(context).showSnackBar(\n            const SnackBar(content: Text('Failed to revoke session')),\n          );",
     "ScaffoldMessenger.of(context).showSnackBar(\n            SnackBar(content: Text(_l10n.snFailedRevoke)),\n          );"),
    ("title: Text('Active Sessions', style: theme.titleMedium),",
     "title: Text(_l10n.snTitle, style: theme.titleMedium),"),
    ("          tooltip: 'Sign Out All',",
     "          tooltip: _l10n.snSignOutAll,"),
    ("Text('No active sessions',",
     "Text(_l10n.snNoActiveSessions,"),
    ("session['device']?.toString() ?? 'Unknown';",
     "session['device']?.toString() ?? _l10n.snUnknown;"),
    ("Text('Current',",
     "Text(_l10n.snCurrent,"),
    ("tooltip: 'Revoke',",
     "tooltip: _l10n.snRevoke,"),
])
