% Лабораторная работа № 1.4 «Лексический распознаватель»
% 24 марта 2026 г.
% Фёдор Китанин, ИУ9-61Б

# Цель работы
Целью данной работы является изучение использования детерминированных конечных
 автоматов с размеченными заключительными состояниями (лексических распознавателей)
 для решения задачи лексического анализа.

# Индивидуальный вариант
plus, minus, >=, <=, ==, комментарии начинаются с апострофа и продолжаются до конца строки.

# Реализация

Лексическая структура языка — регулярные выражения для доменов:

IDENT = [a-zA-Z][a-zA-Z0-9]*
NUM = [0-9]+
COMMENT = '[^\\n]*\\n
PLUS  = plus
MINUS = minus
GE  = >=
LE  = <=
EQ  = ==



Граф детерминированного распознавателя:

![Граф детерминированного распознавателя](pics/det.png)

Реализация:

```python
from dataclasses import dataclass


class LexerAutomata:
    def __init__(self):
        self.final_states = {
            1: 'IDENT',
            2: 'NUM',
            3: 'COMMENT_BODY',
            4: 'COMMENT',
            6: 'IDENT',
            7: 'IDENT',
            8: 'IDENT',
            9: 'PLUS',
            10: 'IDENT',
            11: 'IDENT',
            12: 'IDENT',
            13: 'IDENT',
            14: 'MINUS',
            15: 'GT',
            16: 'GE',
            17: 'LT',
            18: 'LE',
            19: 'ASSIGN',
            20: 'EQ'
        }

        self.transitions = [
            [ 2, 1, 6, 1, 1, 1, 10, 1, 1, 3, 15,17,19,-1,-1,-1,-1,-1,-1,-1,-1],  # 0
            [ 1, 1, 1, 1, 1, 1,  1, 1, 1,-1, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],  # 1
            [ 2,-1,-1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],  # 2
            [ 3, 3, 3, 3, 3, 3,  3, 3, 3, 3,  3, 3, 3, 4, 3, 3, 3, 3, 3, 3, 3],  # 3
            [-1,-1,-1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],  # 4
            [-1,-1,-1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],  # 5
            [ 1, 1, 1, 7, 1, 1,  1, 1, 1,-1, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],  # 6
            [ 1, 1, 1, 1, 8, 1,  1, 1, 1,-1, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],  # 7
            [ 1, 1, 1, 1, 1, 9,  1, 1, 1,-1, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],  # 8
            [ 1, 1, 1, 1, 1, 1,  1, 1, 1,-1, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],  # 9
            [ 1, 1, 1, 1, 1, 1,  1,11, 1,-1, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],  # 10
            [ 1, 1, 1, 1, 1, 1,  1, 1,12,-1, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],  # 11
            [ 1, 1, 1, 1,13, 1,  1, 1, 1,-1, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],  # 12
            [ 1, 1, 1, 1, 1,14,  1, 1, 1,-1, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],  # 13
            [ 1, 1, 1, 1, 1, 1,  1, 1, 1,-1, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],  # 14
            [-1,-1,-1,-1,-1,-1, -1,-1,-1,-1, -1,-1,16,-1,-1,-1,-1,-1,-1,-1,-1],  # 15
            [-1,-1,-1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],  # 16
            [-1,-1,-1,-1,-1,-1, -1,-1,-1,-1, -1,-1,18,-1,-1,-1,-1,-1,-1,-1,-1],  # 17
            [-1,-1,-1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],  # 18
            [-1,-1,-1,-1,-1,-1, -1,-1,-1,-1, -1,-1,20,-1,-1,-1,-1,-1,-1,-1,-1],  # 19
            [-1,-1,-1,-1,-1,-1, -1,-1,-1,-1, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],  # 20
        ]

    def _char_to_col(self, ch):
        if ch.isdigit():
            return 0
        if ch == 'p':
            return 2
        if ch == 'l':
            return 3
        if ch == 'u':
            return 4
        if ch == 's':
            return 5
        if ch == 'm':
            return 6
        if ch == 'i':
            return 7
        if ch == 'n':
            return 8
        if ch == "'":
            return 9
        if ch == '>':
            return 10
        if ch == '<':
            return 11
        if ch == '=':
            return 12
        if ch == '\n':
            return 13
        if ch.isalpha():
            return 1
        return 14

    def next_state(self, state, ch):
        if state < 0 or state >= len(self.transitions):
            return -1
        return self.transitions[state][self._char_to_col(ch)]


@dataclass
class Token:
    tag: str
    lexeme: str
    line: int
    col: int


class Lexer:
    def __init__(self, text: str):
        self.text = text
        self.pos = 0
        self.line = 1
        self.col = 1
        self.a = LexerAutomata()

    def peek(self):
        if self.pos >= len(self.text):
            return None
        return self.text[self.pos]

    def advance(self):
        ch = self.peek()
        self.pos += 1

        if ch == '\n':
            self.line += 1
            self.col = 1
        else:
            self.col += 1

        return ch

    def error(self):
        print(f'Lexical error at ({self.line}, {self.col})')
        self.advance()

    def next_token(self):
        while True:
            ch = self.peek()
            if ch is None:
                return None

            if ch in [' ', '\t', '\n']:
                self.advance()
                continue

            start_line = self.line
            start_col = self.col

            state = 0
            lexeme = ''

            last_final_state = None
            last_final_lexeme = ''

            while True:
                ch = self.peek()
                if ch is None:
                    break

                next_state = self.a.next_state(state, ch)
                if next_state == -1:
                    break

                state = next_state
                lexeme += self.advance()

                if state in self.a.final_states:
                    last_final_state = state
                    last_final_lexeme = lexeme

            if self.peek() is None and state == 3 and lexeme.startswith("'"):
                last_final_state = 4
                last_final_lexeme = lexeme

            if last_final_state is not None:
                tag = self.a.final_states[last_final_state]
                return Token(tag, last_final_lexeme, start_line, start_col)

            self.error()


def main():
    with open('input.txt', 'r', encoding='ascii') as f:
        text = f.read()

    lexer = Lexer(text)

    while True:
        tok = lexer.next_token()
        if tok is None:
            break
        print(f'{tok.tag} ({tok.line}, {tok.col}): {tok.lexeme}')


if __name__ == '__main__':
    main()
```

…

# Тестирование

Входные данные

```
a ab abc1 123 007

plus minus
p1 pl plu plus
m mi min minu minus minuses

x >= y
a <= b
c == d

'this is a comment line
'second comment line continues here

sum123 = a plus b minus 42
result == sum123

invalid@token 999
123 abc
'wqefWAEAF
```

Вывод на `stdout`

```
IDENT (1, 1): a
IDENT (1, 3): ab
IDENT (1, 6): abc1
NUM (1, 11): 123
NUM (1, 15): 007
PLUS (3, 1): plus
MINUS (3, 6): minus
IDENT (4, 1): p1
IDENT (4, 4): pl
IDENT (4, 7): plu
PLUS (4, 11): plus
IDENT (5, 1): m
IDENT (5, 3): mi
IDENT (5, 6): min
IDENT (5, 10): minu
MINUS (5, 15): minus
IDENT (5, 21): minuses
IDENT (7, 1): x
GE (7, 3): >=
IDENT (7, 6): y
IDENT (8, 1): a
LE (8, 3): <=
IDENT (8, 6): b
IDENT (9, 1): c
EQ (9, 3): ==
IDENT (9, 6): d
COMMENT (11, 1): 'this is a comment line

COMMENT (12, 1): 'second comment line continues here

IDENT (14, 1): sum123
ASSIGN (14, 8): =
IDENT (14, 10): a
PLUS (14, 12): plus
IDENT (14, 17): b
MINUS (14, 19): minus
NUM (14, 25): 42
IDENT (15, 1): result
EQ (15, 8): ==
IDENT (15, 11): sum123
IDENT (17, 1): invalid
Lexical error at (17, 8)
IDENT (17, 9): token
NUM (17, 15): 999
NUM (18, 1): 123
IDENT (18, 5): abc
COMMENT (19, 1): 'wqefWAEAF

```

# Вывод
Я научился использовать детерминированный конечный автомат с размеченными 
заключительными состояниями (лексических распознавателей) для решения 
задачи лексического анализа.
