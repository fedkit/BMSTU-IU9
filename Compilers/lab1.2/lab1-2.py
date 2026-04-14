import re

DOMAINS = (
    ('STRING', re.compile(r'^@([^@\n]|@@)*@')),
    ('FLOAT', re.compile(r'^(\d+\.\d*|\.\d+)')),
    ('INT', re.compile(r'^\d+')),
    ('KEY_WORD', re.compile(r'^u?int\.\d+')),
    ('IDENT', re.compile(r'^[A-Za-z0-9.]*[A-Za-z][A-Za-z0-9.]*')),
    ('OPER', re.compile(r'^[+,.]')),
)
  # Ключевое слово, задающее целое число произвольного размера: int.32  uint.65, int.1, uint.5, int.111

WHITESPACE = re.compile(r'\s+')


def NexToken(text):
    pos = 0
    line = 1
    col = 1
    
    while pos < len(text):
        m = WHITESPACE.match(text[pos:])
        if m:
            value = m.group(0)
            for i in value:
                if i == '\n':
                    line += 1
                    col = 1
                else:
                    col += 1
            pos += len(value)

        fragment = text[pos:]
        best_match = None
        best_domain = None
        
        for name, pattern in DOMAINS:
            m = pattern.match(fragment)
            if m:
                value = m.group(0)
                if best_match is None or len(value) > len(best_match):
                    best_match = value
                    best_domain = name
        
        if best_match:
            yield (best_domain, line, col, best_match)
            col += len(best_match)
            pos += len(best_match)
        else:
            yield ('syntax error', line, col, text[pos])
            col += 1
            pos += 1


def main():
    with open('input.txt', encoding='utf-8') as f:
        text = f.read()
    
    for token in NexToken(text):
        if token[0] == 'syntax error':
            print(f'syntax error ({token[1]},{token[2]})')
        else:
            print(f'{token[0]} ({token[1]}, {token[2]}): {token[3]}')


if __name__ == '__main__':
    main()
