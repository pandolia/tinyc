%{
#define YYSTYPE char *
#include "y.tab.h"
int cur_line = 1;
void yyerror(const char *msg);
void unrecognized_char(char c);
%}

OPERATOR        [-/+*()=;]
INTEGER         [0-9]+
IDENTIFIER      [_a-zA-Z][_a-zA-Z0-9]*
WHITESPACE      [ \t]*

%%
{OPERATOR}      { return yytext[0]; }
{INTEGER}       { yylval = strdup(yytext); return T_IntConstant; }
{IDENTIFIER}    { yylval = strdup(yytext); return T_Identifier; }
{WHITESPACE}    { /* ignore every whitespcace */ }
\n              { cur_line++; }
.               { unrecognized_char(yytext[0]); }
%%

int yywrap(void) { 
    return 1;
}

void unrecognized_char(char c) {
    char buf[32] = "Unrecognized character: ?";
    buf[24] = c;
    yyerror(buf);
}

void yyerror(const char *msg) {
    printf("Error at line %d:\n\t%s\n", cur_line, msg);
    exit(1);
}
