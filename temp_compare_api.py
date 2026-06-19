from pathlib import Path
import re

text = Path('SHPH API.yaml').read_text(encoding='utf-8')
paths = []
for line in text.splitlines():
    m = re.match(r'^\s*(/[^:]+):\s*$', line)
    if m:
        paths.append(m.group(1).strip())

files = list(Path('lib/api').rglob('*.dart'))
endpoints = {}
pattern = re.compile(r"['\"](/api/[a-zA-Z0-9_\-/{}]+)/['\"]")
for f in files:
    txt = f.read_text(encoding='utf-8')
    for m in pattern.finditer(txt):
        endpoints.setdefault(m.group(1), []).append(str(f))

missing = [p for p in paths if p not in endpoints]
print('YAML endpoint count:', len(paths))
print('Implemented endpoint count:', len(endpoints))
print('Missing endpoint count:', len(missing))
print('--- Missing endpoints (first 120) ---')
for p in missing[:120]:
    print(p)
