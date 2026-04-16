% Лабораторная работа № 1.5 «Порождение лексического анализатора с помощью flex»
% 7 апреля 2026 г.
% Фёдор Китанин, ИУ9-61Б

# Цель работы
Целью данной работы является изучение генератора лексических анализаторов flex.

# Индивидуальный вариант
Строковые литералы: ограничены обратными кавычками, 
могут занимать несколько строчек текста, для включения 
обратной кавычки она удваивается.
Числовые литералы: десятичные литералы представляют собой 
последовательности десятичных цифр, двоичные — последовательности нулей 
и единиц, оканчивающиеся буквой «b».
Идентификаторы: последовательности десятичных цифр и знаков 
«?», «*» и «|», не начинающиеся с цифры.

## Лексический домен для защиты
Внутри строковых констант можно записывать символы их шестнадцатеричным кодом:
`hello{A}world` (перевод строки, символ newline),
`digits {30} {31}` — своего рода escape-последовательности.

# Реализация

```c
#include "scanner.h"

extern int yylex(YYSTYPE* yylval, YYLTYPE* yylloc);

ErrorMessage errors[MAX_ERRORS];
int error_count = 0;

void add_error(Position p, const char* text) {
    errors[error_count].coord = p;
    strncpy(errors[error_count].text, text, 255);
    errors[error_count].text[255] = '\0';
    error_count++;
}

static void print_pos(Position p) {
    printf("(%d, %d)", p.line, p.pos);
}

static void print_frag(YYLTYPE f) {
    print_pos(f.starting);
    printf("-");
    print_pos(f.following);
}

void print_token(int tag, YYSTYPE yylval, YYLTYPE yylloc) {
    switch (tag) {
        case TOK_IDENT:
            printf("IDENT ");
            print_frag(yylloc);
            printf(": %s\n", yylval.str_value);
            free(yylval.str_value);
            break;

        case TOK_STRING:
            printf("STRING ");
            print_frag(yylloc);
            printf(": %s\n", yylval.str_value);
            free(yylval.str_value);
            break;

        case TOK_INT_DEC:
            printf("INT_DEC ");
            print_frag(yylloc);
            printf(": %lld\n", yylval.int_value);
            break;

        case TOK_INT_BIN:
            printf("INT_BIN ");
            print_frag(yylloc);
            printf(": %lld\n", yylval.int_value);
            break;
    }
}

void print_errors() {
    if (error_count == 0) return;

    printf("\nERRORS:\n");
    for (int i = 0; i < error_count; i++) {
        printf("Error ");
        print_pos(errors[i].coord);
        printf(": %s\n", errors[i].text);
    }
}

int main() {
    FILE* f = fopen("input.txt", "rb");

    fseek(f, 0, SEEK_END);
    long size = ftell(f);
    rewind(f);

    char* text = malloc(size + 1);
    fread(text, 1, size, f);
    text[size] = '\0';
    fclose(f);

    init_scanner(text);

    YYSTYPE yylval;
    YYLTYPE yylloc;

    int tag;
    do {
        tag = yylex(&yylval, &yylloc);
        if (tag != 0) {
            print_token(tag, yylval, yylloc);
        }
    } while (tag != 0);

    print_errors();

    free(text);
    return 0;
}
```

```c
#ifndef SCANNER_H
#define SCANNER_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int line;
    int pos;
    int index;
} Position;

typedef struct {
    Position starting;
    Position following;
} Fragment;

typedef struct {
    Position coord;
    char text[256];
} ErrorMessage;

typedef struct {
    long long int_value;
    char* str_value;
} YYSTYPE;

typedef Fragment YYLTYPE;

enum TokenTag {
    TOK_IDENT = 256,
    TOK_STRING,
    TOK_INT_DEC,
    TOK_INT_BIN
};

#define MAX_ERRORS 1000

extern ErrorMessage errors[MAX_ERRORS];
extern int error_count;

void add_error(Position p, const char* text);

void init_scanner(const char* text);

#endif

```


```lex
%option noyywrap bison-bridge bison-locations

%{
#include "scanner.h"

#define YYSTYPE YYSTYPE
#define YYLTYPE YYLTYPE

static Position cur = {1,1,0};

#define YY_USER_ACTION \
{ \
    yylloc->starting = cur; \
    for (int i = 0; i < yyleng; i++) { \
        if (yytext[i] == '\n') { \
            cur.line++; cur.pos = 1; \
        } else { \
            cur.pos++; \
        } \
        cur.index++; \
    } \
    yylloc->following = cur; \
}

void init_scanner(const char* text) {
    cur.line = 1;
    cur.pos = 1;
    cur.index = 0;
    yy_scan_string(text);
}

// Внутри строковых констант можно записывать символы их шестнадцатеричным
// кодом: `hello{A}world` (перевод строки, \n) `digits {30} {31}`,
// своего рода escape-последовательности
%}

DIGIT      [0-9]
BINDIGIT   [01]
IDENT      [\?\*\|]([\?\*\|0-9])*
DEC        {DIGIT}+
BIN        {BINDIGIT}+b
WS         [ \t\r\n]+


%x STR

%%

{WS} ;

{DEC} {
    yylval->int_value = atoll(yytext);
    return TOK_INT_DEC;
}

{BIN} {
    long long val = 0;
    for (int i = 0; i < yyleng - 1; i++) {
        val = val * 2 + (yytext[i] - '0');
    }
    yylval->int_value = val;
    return TOK_INT_BIN;
}

{IDENT} {
    yylval->str_value = strdup(yytext);
    return TOK_IDENT;
}

"`" {
    BEGIN(STR);
    yylval->str_value = malloc(1024);
    yylval->str_value[0] = '\0';
}

<STR>"``" {
    strcat(yylval->str_value, "`");
}

<STR>"`" {
    BEGIN(INITIAL);
    return TOK_STRING;
    cur.pos++;  
    cur.index++;

    return TOK_STRING;
}

<STR>"{"[0-9a-fA-F]+"}" {
    int code;
    sscanf(yytext, "{%x}", &code);
    char tmp[2] = {code, 0};
    strcat(yylval->str_value, tmp);
}

<STR>\n {
    strcat(yylval->str_value, "\n");
    cur.line++;
    cur.pos = 1;
    cur.index++;
}

<STR>. {
    char tmp[2] = {yytext[0], 0};
    strcat(yylval->str_value, tmp);
    cur.pos++;
    cur.index++;
}

. {
    add_error(cur, "unexpected character");
}

<<EOF>> return 0;

%%
```

# Тестирование

Входные данные

```
123
00123
101b
111b

?*|
?|12
*??123

`hello`
`multi
line string`

a

`hello{A}world`
`digits {30} {31}`,
```

Вывод на `stdout`

```
INT_DEC (1, 1)-(1, 4): 123
INT_DEC (2, 1)-(2, 6): 123
INT_BIN (3, 1)-(3, 5): 5
INT_BIN (4, 1)-(4, 5): 7
IDENT (6, 1)-(6, 4): ?*|
IDENT (7, 1)-(7, 5): ?|12
IDENT (8, 1)-(8, 7): *??123
STRING (10, 12)-(10, 13): hello
STRING (13, 23)-(13, 24): multi
line string
STRING (17, 25)-(17, 26): hello
world
STRING (18, 26)-(18, 27): digits 0 1

ERRORS:
Error (15, 2): unexpected character
Error (18, 28): unexpected character

```

# Вывод
В этой лабораторной работе я изучил генератор лексических анализаторов flex.
