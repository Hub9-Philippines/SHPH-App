import io, os
ROOT = r'E:\Dev\SHPH'
for p in [r'lib\pages\biometric_setup\biometric_setup_widget.dart',
          r'lib\pages\my_notifications\my_notifications_widget.dart']:
    ls = io.open(os.path.join(ROOT, p), encoding='utf-8').read().splitlines()
    print('====', p)
    for i, l in enumerate(ls, 1):
        if ('Device registered' in l or 'Registration failed' in l
                or 'Notification settings' in l):
            print(i, repr(l))
