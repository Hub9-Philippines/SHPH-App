import io

p = r'E:\Dev\SHPH\lib\pages\sessions\sessions_widget.dart'
t = io.open(p, encoding='utf-8').read()
repl = [
    ("                              title: _l10n.snSignOutAllDevices,\n      message:\n          _l10n.snSignOutAllConfirm,\n      confirmText: _l10n.snSignOutAll,",
     "      title: _l10n.snSignOutAllDevices,\n      message:\n          _l10n.snSignOutAllConfirm,\n      confirmText: _l10n.snSignOutAll,"),
    ("'All other sessions have been revoked.'", "_l10n.snAllRevoked"),
    ("'Failed to revoke all sessions.'", "_l10n.snFailedRevokeAll"),
    ("'Session revoked.'", "_l10n.snRevoked"),
    ("'Failed to revoke session.'", "_l10n.snFailedRevoke"),
    ("'Active Sessions'", "_l10n.snTitle"),
    ("'No active sessions.'", "_l10n.snNoActiveSessions"),
    ("'Unknown'", "_l10n.snUnknown"),
    ("'Current'", "_l10n.snCurrent"),
    ("'Revoke'", "_l10n.snRevoke"),
    ("'Sign Out All Devices'", "_l10n.snSignOutAllDevices"),
    ("'Sign Out All'", "_l10n.snSignOutAll"),
]
for a, b in repl:
    if a in t:
        t = t.replace(a, b, 1)
    else:
        print('NOT FOUND:', repr(a[:40]))
io.open(p, 'w', encoding='utf-8', newline='').write(t)
print('sessions done')
