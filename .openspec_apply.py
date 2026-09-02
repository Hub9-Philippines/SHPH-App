import io, json
import importlib.util

ROOT = r'E:\Dev\SHPH'

spec = importlib.util.spec_from_file_location('keys', ROOT + r'\.openspec_keys.py')
keys = importlib.util.module_from_spec(spec)
spec.loader.exec_module(keys)


def json_value(raw):
    if raw.startswith('{"'):
        return raw
    return json.dumps(raw, ensure_ascii=False)


def append_keys(path, entries):
    text = io.open(path, encoding='utf-8').read()
    stripped = text.rstrip()
    assert stripped.endswith('}'), path
    body = stripped[:-1].rstrip()
    if not body.endswith(','):
        body += ','
    block = ''
    added = 0
    for key, val in entries:
        if '"%s":' % key in body:
            print('skip (exists):', key)
            continue
        block += '\n  "%s": %s,' % (key, json_value(val))
        added += 1
    if block.endswith(','):
        block = block[:-1]
    io.open(path, 'w', encoding='utf-8', newline='').write(body + '\n' + block + '\n}\n')
    print('appended', added, 'keys to', path.split('\\')[-1])


append_keys(ROOT + r'\lib\l10n\app_en.arb', keys.EN_KEYS_312)
append_keys(ROOT + r'\lib\l10n\app_fil.arb', keys.FIL_KEYS_312)

en = json.load(open(ROOT + r'\lib\l10n\app_en.arb', encoding='utf-8'))
fil = json.load(open(ROOT + r'\lib\l10n\app_fil.arb', encoding='utf-8'))
ek = {k for k in en if k != '@@locale'}
fk = {k for k in fil if k != '@@locale'}
print('en:', len(ek), 'fil:', len(fk))
print('missing in fil:', sorted(ek - fk))
print('missing in en:', sorted(fk - ek))
