% Лабораторная работа № 1.2. «Лексический анализатор
  на основе регулярных выражений»
% <лабораторная ещё не сдана>
% Фёдор Китанин, ИУ9-61Б

# Цель работы
Целью данной работы является приобретение навыка разработки простейших
 лексических анализаторов, работающих на основе поиска в тексте по образцу, 
заданному регулярным выражением.

# Индивидуальный вариант
Целые числа: последовательности десятичных цифр.
Вещественные числа: последовательности десятичных цифр, содержащие точку.
Идентификаторы: последовательности латинских букв, цифр и точек, 
содержащих как минимум одну букву.
Знаки операций: «+», «,», «.».
Строки: ограничены знаками «@», не могут пересекать границы строчек текста, 
для представления «@» внутри строки знак удваивается.


## Лексический домен для защиты
Ключевое слово, задающее целое число произвольного размера: int.32  
uint.65, int.1, uint.5, int.111

# Реализация

```python
import re

DOMAINS = (
    ('STRING', re.compile(r'^@([^@\n]|@@)*@')),
    ('FLOAT', re.compile(r'^(\d+\.\d*|\.\d+)')),
    ('INT', re.compile(r'^\d+')),
    ('KEY_WORD', re.compile(r'^u?int\.\d+')),
    ('IDENT', re.compile(r'^[A-Za-z0-9.]*[A-Za-z][A-Za-z0-9.]*')),
    ('OPER', re.compile(r'^[+,.]')),
)

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

```

# Тестирование

Входные данные

```
count+12
abc.1,5.3
1a
test.value
123
45.67
.242
+
,
.
@hello@
@hello@@world@
@a b c@
12+34.5,test
@notstring
int.32  uint.65, int.1, uint.5, int.111
```

Вывод на `stdout` (если необходимо)

```
IDENT (1, 1): count
OPER (1, 6): +
INT (1, 7): 12
IDENT (2, 1): abc.1
OPER (2, 6): ,
FLOAT (2, 7): 5.3
IDENT (3, 1): 1a
IDENT (4, 1): test.value
INT (5, 1): 123
FLOAT (6, 1): 45.67
FLOAT (7, 1): .242
OPER (8, 1): +
OPER (9, 1): ,
OPER (10, 1): .
STRING (11, 1): @hello@
STRING (12, 1): @hello@@world@
STRING (13, 1): @a b c@
INT (14, 1): 12
OPER (14, 3): +
FLOAT (14, 4): 34.5
OPER (14, 8): ,
IDENT (14, 9): test
syntax error (15,1)
IDENT (15, 2): notstring
KEY_WORD (16, 1): int.32
KEY_WORD (16, 9): uint.65
OPER (16, 16): ,
KEY_WORD (16, 18): int.1
OPER (16, 23): ,
KEY_WORD (16, 25): uint.5
OPER (16, 31): ,
KEY_WORD (16, 33): int.111
```

# Вывод
Я приобрёл навык разработки простейших лексических анализаторов, 
работающих на основе поиска в тексте по образцу, заданному регулярным выражением.import re
