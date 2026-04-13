KEYWORDS = {'define', 'if', 'else', 'endif', 'end'}

def parse_articles(tokens, step):
    functions = {}
    while step < len(tokens) and tokens[step] == 'define':
        step += 1
        if step >= len(tokens):
            return None, step
        name = tokens[step]
        if name in KEYWORDS:
            return None, step
        step += 1
        body, step = parse_body(tokens, step, {'end'})
        if body is None or step >= len(tokens) or tokens[step] != 'end':
            return None, step
        functions[name] = body
        step += 1
    return functions, step


def parse_body(tokens, step, stop_words=None):
    if stop_words is None:
        stop_words = set()
    body = []

    IF_STOP_WORDS = {'else', 'endif'}

    while step < len(tokens):
        token = tokens[step]

        if token in stop_words:
            return body, step

        if token == 'if':
            step += 1
            then_body, step = parse_body(tokens, step, IF_STOP_WORDS)
            if then_body is None or step >= len(tokens):
                return None, step

            if step < len(tokens) and tokens[step] == 'else':
                step += 1
                else_body, step = parse_body(tokens, step, {'endif'})
                if else_body is None or step >= len(tokens) or tokens[step] != 'endif':
                    return None, step
                step += 1
                body.append(['if', then_body, else_body])
            elif step < len(tokens) and tokens[step] == 'endif':
                step += 1
                body.append(['if', then_body])
            else:
                return None, step

        elif token.lstrip('-').isdigit():
            body.append(int(token))
            step += 1
        else:
            body.append(token)
            step += 1

    return body, step


def parse(text):
    tokens = text.split()
    step = 0

    functions, step = parse_articles(tokens, step)
    if functions is None:
        return False

    body, step = parse_body(tokens, step)
    if body is None or step != len(tokens):
        return False

    return [functions, body]


print(parse('1 2 +'))
# [{}, [1, 2, '+']]

print(parse('x dup 0 swap if drop -1 endif'))
# [{}, ['x', 'dup', 0, 'swap', ['if', ['drop', -1]]]]

print(parse('x dup 0 swap if drop -1 else swap 1 + endif'))
# [{}, ['x', 'dup', 0, 'swap', ['if', ['drop', -1], ['swap', 1, '+']]]]

print(parse('define abs dup 0 < if -1 * endif end 10 abs -10 abs'))
# [{'abs': ['dup', 0, '<', ['if', [-1, '*']]]}, [10, 'abs', -10, 'abs']]

print(parse('define f1 1 end define f2 2 end f1 f2'))
# [{'f1':[1], 'f2':[2]}, ['f1','f2']]

print(parse('if 1 if 2 endif endif'))
# [{}, [['if', [1, ['if', [2]]]]]]

print(parse('''define -- 1 - end
         define =0? dup 0 = end
         define =1? dup 1 = end
         define factorial
             =0? if
                 drop 1
             else =1? if
                 drop 1
             else
                 dup --
                 factorial
                 *
             endif
             endif
         end
         0 factorial
         1 factorial
         2 factorial
         3 factorial
         4 factorial'''))

print(parse('define f1 1'))
# False

print(parse('if 1'))
# False