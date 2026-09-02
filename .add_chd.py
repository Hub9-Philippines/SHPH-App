import io, json

p = r'E:\Dev\SHPH\lib\l10n\app_fil.arb'
t = io.open(p, encoding='utf-8').read()
body = t.rstrip()[:-1].rstrip()
if not body.endswith(','):
    body += ','
add = '\n  "chdMessage": "Mensahe"'
io.open(p, 'w', encoding='utf-8', newline='').write(body + add + '\n}\n')
d = json.load(open(p, encoding='utf-8'))
ek = {k for k in d if k != '@@locale'}
en = json.load(open(r'E:\Dev\SHPH\lib\l10n\app_en.arb', encoding='utf-8'))
enk = {k for k in en if k != '@@locale'}
print('fil keys:', len(ek), 'chdMessage present:', 'chdMessage' in d)
print('missing in fil (non-meta):', sorted(ek - enk - {k for k in enk if k.startswith('@')}))
print('missing in en:', sorted(enk - ek))
