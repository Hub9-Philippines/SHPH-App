import io, re, json

for p in [r'E:\Dev\SHPH\lib\l10n\app_en.arb', r'E:\Dev\SHPH\lib\l10n\app_fil.arb']:
    t = io.open(p, encoding='utf-8').read()

    def fix(m):
        return m.group(1) + ' ' + json.dumps(m.group(2), ensure_ascii=False) + ','

    t2, n = re.subn(r'(\s*"[A-Za-z@]+":) (\{[a-z]+\}[^,"]*),', fix, t)
    io.open(p, 'w', encoding='utf-8', newline='').write(t2)
    print(p.split('\\')[-1], 'fixed lines:', n)
    d = json.load(open(p, encoding='utf-8'))
    print('  OK, keys:', len([k for k in d if k != '@@locale']))
