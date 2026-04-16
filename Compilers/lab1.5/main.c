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