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