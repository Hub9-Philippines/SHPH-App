import io
p = r'E:\Dev\SHPH\lib\pages\call_history_details_page\call_history_details_page_widget.dart'
ls = io.open(p, encoding='utf-8').read().splitlines()
for i in range(103, 222):
    print(f'{i+1}: {ls[i]}')
