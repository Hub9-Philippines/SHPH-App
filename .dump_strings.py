import io, re, os

ROOT = r'E:\Dev\SHPH'
files = [
    'lib/pages/sessions/sessions_widget.dart',
    'lib/pages/biometric_setup/biometric_setup_widget.dart',
    'lib/pages/my_notifications/my_notifications_widget.dart',
    'lib/pages/call_permission/call_permission_widget.dart',
    'lib/pages/call_history_details_page/call_history_details_page_widget.dart',
]
for f in files:
    p = os.path.join(ROOT, f)
    t = io.open(p, encoding='utf-8').read()
    print('====', f)
    seen = []
    for m in re.finditer(r"'([^']*)'", t):
        s = m.group(1)
        if s and any(c.isupper() for c in s) and len(s) > 1 and s not in seen:
            seen.append(s)
            print(repr(s))
