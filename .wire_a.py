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


run('lib/pages/sessions/sessions_widget.dart', [
    ("import '/flutter_flow/flutter_flow_util.dart';\nimport '/theme/app_theme.dart';\nimport 'sessions_model.dart';",
     "import '/flutter_flow/flutter_flow_util.dart';\n" + L10n + "import '/theme/app_theme.dart';\nimport 'sessions_model.dart';"),
    ("  late SessionsModel _model;\n",
     "  late SessionsModel _model;\n  AppLocalizations get _l10n => AppLocalizations.of(context)!;\n"),
    ("title: const Text('Sign Out All Devices'),", "title: Text(_l10n.snSignOutAllDevices),"),
    ("'This will sign you out of all active sessions except this one.'", "_l10n.snSignOutAllConfirm"),
    ("const Text('Cancel')", "Text(_l10n.cancel)"),
    ("const Text('Sign Out All')", "Text(_l10n.snSignOutAll)"),
    ("const SnackBar(content: Text('All other sessions revoked'))", "SnackBar(content: Text(_l10n.snAllRevoked))"),
    ("const SnackBar(content: Text('Failed to revoke sessions'))", "SnackBar(content: Text(_l10n.snFailedRevokeAll))"),
    ("const SnackBar(content: Text('Session revoked'))", "SnackBar(content: Text(_l10n.snRevoked))"),
    ("const SnackBar(content: Text('Failed to revoke session'))", "SnackBar(content: Text(_l10n.snFailedRevoke))"),
    ("Text('Active Sessions', style: theme.titleMedium)", "Text(_l10n.snTitle, style: theme.titleMedium)"),
    ("tooltip: 'Sign Out All',", "tooltip: _l10n.snSignOutAll,"),
    ("Text('No active sessions',", "Text(_l10n.snNoActiveSessions,"),
    ("session['device']?.toString() ?? 'Unknown';", "session['device']?.toString() ?? _l10n.snUnknown;"),
    ("Text('Current',", "Text(_l10n.snCurrent,"),
    ("tooltip: 'Revoke',", "tooltip: _l10n.snRevoke,"),
])

run('lib/pages/biometric_setup/biometric_setup_widget.dart', [
    ("import '/flutter_flow/flutter_flow_util.dart';\nimport '/theme/app_theme.dart';\nimport 'biometric_setup_model.dart';",
     "import '/flutter_flow/flutter_flow_util.dart';\n" + L10n + "import '/theme/app_theme.dart';\nimport 'biometric_setup_model.dart';"),
    ("  final _deviceNameCtrl = TextEditingController();\n",
     "  final _deviceNameCtrl = TextEditingController();\n  AppLocalizations get _l10n => AppLocalizations.of(context)!;\n"),
    ("title: 'Biometric Setup',", "title: _l10n.bioSetupTitle,"),
    ("'Use your fingerprint or face to sign in quickly and securely.'", "_l10n.bioSetupSubtitle"),
    ("Text('Register this device',", "Text(_l10n.bioSetupRegister,"),
    ("placeholder: 'Device name (e.g. My Phone)',", "placeholder: _l10n.bioSetupDeviceNameHint,"),
    ("? 'My Device'", "? _l10n.bioSetupDeviceNameDefault"),
    ("content: Text(\n                                            'Device registered'),", "content: Text(\n                                            _l10n.bioSetupRegistered),"),
    ("content: Text(\n                                            'Registration failed'),", "content: Text(\n                                            _l10n.bioSetupRegistrationFailed),"),
    ("const Text('Register this device')", "Text(_l10n.bioSetupRegister)"),
    ("Text('Registered Devices',", "Text(_l10n.bioSetupRegisteredDevices,"),
    ("cred['device_name']?.toString() ?? 'Unknown';", "cred['device_name']?.toString() ?? _l10n.bioSetupUnknown;"),
])

print('DONE')
