from pathlib import Path
import re

yaml_text = Path('SHPH API.yaml').read_text(encoding='utf-8')
paths = []
for line in yaml_text.splitlines():
    m = re.match(r'^\s*(/[^:]+):\s*$', line)
    if m:
        p = m.group(1).strip()
        if p.endswith('/'):
            p = p[:-1]
        paths.append(p)

files = list(Path('lib/api').rglob('*.dart'))
endpoints = {}
pattern = re.compile(r"['\"](/api/[a-zA-Z0-9_\-/{}]+)['\"]")
for f in files:
    txt = f.read_text(encoding='utf-8')
    for m in pattern.finditer(txt):
        p = m.group(1)
        if p.endswith('/'):
            p = p[:-1]
        endpoints.setdefault(p, []).append(str(f))

print('YAML endpoint count:', len(paths))
print('Extracted API endpoint count:', len(endpoints))
print('--- Extracted endpoints ---')
for p in sorted(endpoints):
    print(p)
missing = [p for p in paths if p not in endpoints]
print('--- Missing YAML endpoints count:', len(missing))
for p in missing[:120]:
    print(p)
