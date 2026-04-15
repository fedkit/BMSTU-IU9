% Лабораторная работа № 1.3 «Объектно-ориентированный
  лексический анализатор»
% 31 марта 2026 г.
% Фёдор Китанин, ИУ9-61Б

# Цель работы
Целью данной работы является 
приобретение навыка реализации 
лексического анализатора на объектно-ориентированном 
языке без применения каких-либо средств автоматизации 
решения задачи лексического анализа.

# Индивидуальный вариант
Идентификаторы: последовательности заглавных латинских букв, 
за которыми могут располагаться последовательности знаков «+», «-» и «*».
Целочисленные литералы — числа в унарной системе счисления: 
знак «*» (представляющий 0) или последовательности, состоящие 
целиком либо из знаков «+», либо из знаков «-».
Ключевые слова: «ON», «OFF», «**».

## Лексический домен для защиты
# Строки, ограниченные знаками < и >, могут быть вложенными: <abc<!@#!@#>   23434 <9999>dfdf>

# Реализация

```python
class Fragment:
    def __init__(self, start, follow):
        self.start = start.copy()
        self.follow = follow.copy()

    def __str__(self):
        return f"{self.start}-{self.follow}"


class Message:
    def __init__(self, is_error, text):
        self.is_error = is_error
        self.text = text


class DomainTag:
    STRING = "STRING"
    IDENT = "IDENT"
    NUMBER = "NUMBER"
    KW_ON = "ON"
    KW_OFF = "OFF"
    KW_STAR = "**"
    END = "END_OF_PROGRAM"

class Position:
    def __init__(self, text, line=1, pos=1, index=0):
        self.text = text
        self.line = line
        self.pos = pos
        self.index = index

    def copy(self):
        return Position(self.text, self.line, self.pos, self.index)

    @property
    def cp(self):
        if self.index >= len(self.text):
            return -1
        return ord(self.text[self.index])

    @property
    def char(self):
        if self.index >= len(self.text):
            return None
        return self.text[self.index]

    @property
    def is_white_space(self):
        return self.index < len(self.text) and self.text[self.index].isspace()

    @property
    def is_new_line(self):
        if self.index >= len(self.text):
            return False
        return self.text[self.index] in "\r\n"

    def next(self):
        p = self.copy()
        if p.index < len(p.text):
            if p.text[p.index] == "\n":
                p.line += 1
                p.pos = 1
            else:
                p.pos += 1
            p.index += 1
        return p

    def __str__(self):
        return f"({self.line}, {self.pos})"

# Строки, ограниченные знаками < и >, могут быть вложенными: <abc<!@#!@#>   23434 <9999>dfdf>

class Token:
    def __init__(self, tag, start, follow):
        self.tag = tag
        self.coords = Fragment(start, follow)


class IdentToken(Token):
    def __init__(self, code, start, follow):
        super().__init__(DomainTag.IDENT, start, follow)
        self.code = code


class NumberToken(Token):
    def __init__(self, value, start, follow):
        super().__init__(DomainTag.NUMBER, start, follow)
        self.value = value


class SpecToken(Token):
    def __init__(self, tag, start, follow):
        super().__init__(tag, start, follow)

class StringToken(Token):
    def __init__(self, value, start, follow):
        super().__init__(DomainTag.STRING, start, follow)
        self.value = value


class Compiler:
    def __init__(self):
        self.messages = {}
        self.names = []
        self.name_codes = {}

    def add_name(self, name):
        if name in self.name_codes:
            return self.name_codes[name]
        code = len(self.names)
        self.names.append(name)
        self.name_codes[name] = code
        return code

    def get_name(self, code):
        return self.names[code]

    def add_error(self, pos, text):
        self.messages[(pos.line, pos.pos, pos.index)] = Message(True, text)


class Scanner:
    def __init__(self, program, compiler):
        self.program = program
        self.compiler = compiler
        self.cur = Position(program)

    def skip_ws(self):
        while self.cur.cp != -1 and self.cur.char.isspace():
            self.cur = self.cur.next()

    def read_ident(self, start):
        name = ""

        while self.cur.cp != -1 and self.cur.char.isupper():
            name += self.cur.char
            self.cur = self.cur.next()

        while self.cur.cp != -1 and self.cur.char in "+-*":
            name += self.cur.char
            self.cur = self.cur.next()

        code = self.compiler.add_name(name)
        return IdentToken(code, start, self.cur)
    

    def read_number(self, start):
        if self.cur.char == "*":
            self.cur = self.cur.next()
            return NumberToken(0, start, self.cur)

        sign = self.cur.char
        value = 0

        while self.cur.cp != -1 and self.cur.char == sign:
            value += 1
            self.cur = self.cur.next()

        return NumberToken(value, start, self.cur)

    def try_keyword(self, start):
        if self.program[self.cur.index:self.cur.index + 2] == "ON":
            self.cur = self.cur.next().next()
            return SpecToken(DomainTag.KW_ON, start, self.cur)

        if self.program[self.cur.index:self.cur.index + 3] == "OFF":
            for _ in range(3):
                self.cur = self.cur.next()
            return SpecToken(DomainTag.KW_OFF, start, self.cur)

        if self.program[self.cur.index:self.cur.index + 2] == "**":
            self.cur = self.cur.next().next()
            return SpecToken(DomainTag.KW_STAR, start, self.cur)

        return None
    
    def read_number(self, start):
        if self.cur.char == "*":
            self.cur = self.cur.next()
            return NumberToken(0, start, self.cur)

        sign = self.cur.char
        value = 0
        koeff = -1 if sign == '-' else 1

        while self.cur.cp != -1 and self.cur.char == sign:
            value += (1 * koeff)
            self.cur = self.cur.next()

        return NumberToken(value, start, self.cur)
    
    def read_string(self, start):
        self.cur = self.cur.next()
        count_brackets = 1
        value = '<'
        while self.cur.cp != -1 and count_brackets > 0:
            value += self.cur.char
            if self.cur.char == '<':
                count_brackets += 1
            elif self.cur.char == '>':
                count_brackets -= 1
            self.cur = self.cur.next()

        if self.cur.cp == -1 or count_brackets > 0:
            self.compiler.add_error(start, "unknown symbol")
        
        return StringToken(value, start, self.cur)

    def next_token(self):
        while True:
            self.skip_ws()

            if self.cur.cp == -1:
                return SpecToken(DomainTag.END, self.cur, self.cur)

            start = self.cur.copy()
            ch = self.cur.char

            kw = self.try_keyword(start)
            if kw:
                return kw
            
            if ch == '<':
                return self.read_string(start)

            if ch.isupper():
                return self.read_ident(start)

            if ch in "*+-":
                return self.read_number(start)

            self.compiler.add_error(start, "unknown symbol")
            self.cur = self.cur.next()


def print_token(tok, compiler):
    if isinstance(tok, IdentToken):
        print(f"{tok.tag} {tok.coords}: {compiler.get_name(tok.code)}")
    elif isinstance(tok, NumberToken) or isinstance(tok, StringToken):
        print(f"{tok.tag} {tok.coords}: {tok.value}")
    else:
        print(f"{tok.tag} {tok.coords}:")


def main():
    with open("input.txt", "r", encoding="utf-8") as f:
        program = f.read()

    compiler = Compiler()
    scanner = Scanner(program, compiler)

    while True:
        tok = scanner.next_token()
        print_token(tok, compiler)
        if tok.tag == DomainTag.END:
            break

    print()

    if compiler.messages:
        print("MESSAGES:")
        for k in sorted(compiler.messages):
            m = compiler.messages[k]
            print(f"Error ({k[0]}, {k[1]}): {m.text}")

    print()

    if compiler.names:
        print("NAMES:")
        for i, name in enumerate(compiler.names):
            print(f"{i}: {name}")


if __name__ == "__main__":
    main()
```



# Тестирование

Входные данные

```
ON ABC++ OFF
A+++ B--- *
**
XYZ*+--
ON OFF **

A @ B
++++++ ---- *

<abc<!@#!@#>   23434 <9999>dfdf>
```

Вывод на `stdout`

```
ON (1, 1)-(1, 3):
IDENT (1, 4)-(1, 9): ABC++
OFF (1, 10)-(1, 13):
IDENT (2, 1)-(2, 5): A+++
IDENT (2, 6)-(2, 10): B---
NUMBER (2, 11)-(2, 12): 0
** (3, 1)-(3, 3):
IDENT (4, 1)-(4, 8): XYZ*+--
ON (5, 1)-(5, 3):
OFF (5, 4)-(5, 7):
** (5, 8)-(5, 10):
IDENT (7, 1)-(7, 2): A
IDENT (7, 5)-(7, 6): B
NUMBER (8, 1)-(8, 7): 6
NUMBER (8, 8)-(8, 12): -4
NUMBER (8, 13)-(8, 14): 0
STRING (10, 1)-(10, 33): <abc<!@#!@#>   23434 <9999>dfdf>
END_OF_PROGRAM (10, 33)-(10, 33):

MESSAGES:
Error (7, 3): unknown symbol
Error (10, 1): unknown symbol

NAMES:
0: ABC++
1: A+++
2: B---
3: XYZ*+--
4: A
5: B
```

# Вывод
В данной лабораторной работе я 
приобрел навыки реализации лексического анализатора на 
объектно-ориентированном языке без применения каких-либо 
средств автоматизации решения задачи лексического анализа.
