import re

def replace_every_20th(text):
    # Паттерн: begin, если после него пробел; end, если после пробел, точка или точка с запятой.
    # Перед словом обязательно должен быть пробел.
    pattern = r'(?<=\s)(?:begin(?=\s)|end(?=\s|\.|\;))'
    matches = list(re.finditer(pattern, text))

    replacements = []      # (позиция, старое_слово, новое_слово)
    cnt_begin = 0
    cnt_end = 0

    for match in matches:
        word = match.group()
        start = match.start()
        if word == 'begin':
            cnt_begin += 1
            if cnt_begin % 20 == 0:          # 20-й, 40-й, 60-й ...
                replacements.append((start, 'begin', '{{'))
        else:  # 'end'
            cnt_end += 1
            if cnt_end % 20 == 0:
                replacements.append((start, 'end', '}}'))

    # Выполняем замены с конца, чтобы не сбивались позиции
    replacements.sort(reverse=True)
    for start, old, new in replacements:
        text = text[:start] + new + text[start+len(old):]

    return text

# Чтение файла
with open('btpc64-3.pas', 'r', encoding='utf-8') as f:
    content = f.read()

# Обработка
modified = replace_every_20th(content)

# Запись обратно
with open('btpc64-3.pas', 'w', encoding='utf-8') as f:
    f.write(modified)
