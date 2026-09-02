import io
p = r'E:\Dev\SHPH\lib\pages\biometric_setup\biometric_setup_widget.dart'
ls = io.open(p, encoding='utf-8').read().splitlines()
print('--- lines 97-105 (placeholder) ---')
for i in range(96, 105):
    print(f'{i+1}: {ls[i]}')
print('--- lines 124-140 (snackbars) ---')
for i in range(123, 140):
    print(f'{i+1}: {ls[i]}')
