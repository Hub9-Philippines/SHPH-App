import io
p = r'E:\Dev\SHPH\lib\pages\sessions\sessions_widget.dart'
ls = io.open(p, encoding='utf-8').read().splitlines()
print('total lines', len(ls))
for i, l in enumerate(ls, 1):
    if '_l10n' in l or ('Active Sessions' in l) or ('Sign Out All' in l and "'" in l):
        print(f'{i}: {l}')
