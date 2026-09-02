import io, re

p = r'E:\Dev\SHPH\lib\pages\sessions\sessions_widget.dart'
t = io.open(p, encoding='utf-8').read()
for m in re.finditer(r"'[^']*'", t):
    s = m.group()
    inner = s[1:-1]
    if any(c.isupper() for c in inner) and len(inner) > 4:
        print(repr(inner), '->', m.start())
