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