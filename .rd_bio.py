import io
p = r'E:\Dev\SHPH\lib\pages\biometric_setup\biometric_setup_widget.dart'
ls = io.open(p, encoding='utf-8').read().splitlines()
for i in range(96, 144):
    print(f'{i+1}: {ls[i]}')
