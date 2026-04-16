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
