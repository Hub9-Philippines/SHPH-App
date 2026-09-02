import io, json, re

for p in [r'E:\Dev\SHPH\lib\l10n\app_en.arb', r'E:\Dev\SHPH\lib\l10n\app_fil.arb']:
    t = io.open(p, encoding='utf-8').read()
    ls = [l for l in t.splitlines() if 'localize-app-global' not in l]
    t = '\n'.join(ls).rstrip()
    assert t.endswith('}'), p
    t = t[:-1].rstrip()
    if t.endswith(','):
        t = t[:-1]
    out = t + '\n}\n'
    io.open(p, 'w', encoding='utf-8', newline='').write(out)
    d = json.load(open(p, encoding='utf-8'))
    print(p.split('\\')[-1], 'OK keys:', len([k for k in d if k != '@@locale']))

en = json.load(open(r'E:\Dev\SHPH\lib\l10n\app_en.arb', encoding='utf-8'))
fil = json.load(open(r'E:\Dev\SHPH\lib\l10n\app_fil.arb', encoding='utf-8'))
ek = {k for k in en if k != '@@locale'}
fk = {k for k in fil if k != '@@locale'}
print('en:', len(ek), 'fil:', len(fk))
print('missing in fil:', sorted(ek - fk))
print('missing in en:', sorted(fk - ek))
