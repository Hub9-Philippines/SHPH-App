import io
p = r'E:\Dev\SHPH\lib\pages\my_notifications\my_notifications_widget.dart'
ls = io.open(p, encoding='utf-8').read().splitlines()
kws = ['marking', 'Could not', 'Failed to load', 'Error loading',
       'You are all caught', 'Marking...', 'Mark all as read', 'Just now',
       'No notifications', 'Open this update', 'No destination']
for i, l in enumerate(ls, 1):
    if any(kw in l for kw in kws):
        print(f'{i}: {l.strip()}')
