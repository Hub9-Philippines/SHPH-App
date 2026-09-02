import io
p = r'E:\Dev\SHPH\lib\pages\sessions\sessions_widget.dart'
ls = io.open(p, encoding='utf-8').read().splitlines()
for i in range(112, 172):
    print(f'{i+1}: {ls[i]}')
