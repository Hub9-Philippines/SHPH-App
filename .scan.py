import io, re, sys

ROOT = r'E:\Dev\SHPH'

for a in sys.argv[1:]:
    if a.startswith('d:'):
        _, p, x, y = a.split('|')
        ls = io.open(ROOT + '\\' + p, encoding='utf-8').read().splitlines()
        print('===' + p + ' lines ' + str(a and x) + '-' + str(y))
        for i in range(int(x) - 1, min(int(y), len(ls))):
            print(str(i + 1) + ': ' + ls[i])
    else:
        ls = io.open(ROOT + '\\' + a, encoding='utf-8').read().splitlines()
        print('===' + a + ' string literals ===')
        for i, l in enumerate(ls):
            for m in re.findall(r"'([^']{2,})'", l):
                if not re.match(r'^(package|/|\d)', m) and 'package:' not in m:
                    print(str(i + 1) + ': ' + m)
        for i, l in enumerate(ls):
            if re.search(r'Text\(\s*"', l):
                print(str(i + 1) + ' (dq): ' + l.strip())
