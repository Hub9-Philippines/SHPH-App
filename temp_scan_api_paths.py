from pathlib import Path
import re

paths = set()
for f in Path('lib').rglob('*.dart'):
    txt = f.read_text(encoding='utf-8', errors='ignore')
    for m in re.finditer(r'(/api/[A-Za-z0-9_\-/{}]+)', txt):
        paths.add(m.group(1).rstrip("'\""))
print('total unique /api/ strings:', len(paths))
for p in sorted(paths):
    print(p)
