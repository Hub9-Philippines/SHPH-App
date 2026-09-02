import io, re, os
ROOT = r'E:\Dev\SHPH'
f = 'lib/pages/my_notifications/my_notifications_widget.dart'
t = io.open(os.path.join(ROOT, f), encoding='utf-8').read()
for kw in ['mark', 'Mark', 'read', 'Read', 'load', 'Load', 'caught', 'Could']:
    for m in re.finditer(r"[^\n]*" + re.escape(kw) + r"[^\n]*", t):
        print(m.group())
