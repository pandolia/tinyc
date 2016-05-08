%{

#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>

void init_parser(int argc, char *argv[]);
void quit_parser();

extern FILE* yyin;
FILE *asmfile, *incfile;
#define BUFSIZE 256

#define out_asm(fmt, ...) \
    {fprintf(asmfile, fmt, ##__VA_ARGS__); fprintf(asmfile, "\n");}

#define out_inc(fmt, ...) \
    {fprintf(incfile, fmt, ##__VA_ARGS__); fprintf(incfile, "\n");}

void file_error(char *msg);

int ii = 0, itop = -1, istack[100];
int ww = 0, wtop = -1, wstack[100];

#define _BEG_IF     (istack[++itop] = ++ii)
#define _END_IF     (itop--)
#define _i          (istack[itop])

#define _BEG_WHILE  (wstack[++wtop] = ++ww)
#define _END_WHILE  (wtop--)
#define _w          (wstack[wtop])

int argc = 0, varc = 0;
char *cur_func_name, *args[128], *vars[128];
void write_func_head();
void write_func_tail();

#define _BEG_FUNCDEF(name)  (cur_func_name = (name))
#define _APPEND_ARG(arg)    (args[argc++] = (arg))
#define _APPEND_VAR(var)    (vars[varc++] = (var))
#define _WRITE_FUNCHEAD     write_func_head
#define _END_FUNCDEF        write_func_tail

#define YYSTYPE char *

%}

%token T_Void T_Int T_While T_If T_Else T_Return T_Break T_Continue
%token T_Print T_ReadInt T_Le T_Ge T_Eq T_Ne T_And T_Or
%token T_IntConstant T_StringConstant T_Identifier

%left '='
%left T_Or
%left T_And
%left T_Eq T_Ne
%left '<' '>' T_Le T_Ge
%left '+' '-'
%left '*' '/' '%'
%left '!'

%%

Start:
    Program                         { /* empty */ }
;

Program:
    /* empty */                     { /* empty */ }
|   Program FuncDef                 { /* empty */ }
;

FuncDef:
    T_Int  FuncName Args Vars Stmts EndFuncDef
|   T_Void FuncName Args Vars Stmts EndFuncDef
;

FuncName:
    T_Identifier                    { _BEG_FUNCDEF($1); }
;

Args:
    '(' ')'                         { /* empty */ }
|   '(' _Args ')'                   { /* empty */ }
;

_Args:
    T_Int T_Identifier              { _APPEND_ARG($2); }
|   _Args ',' T_Int T_Identifier    { _APPEND_ARG($4); }
;

Vars:
    _Vars                           { _WRITE_FUNCHEAD(); }
;

_Vars:
    '{'                             { /* empty */ }
|   _Vars Var ';'                   { /* empty */ }
;

Var:
    T_Int T_Identifier              { _APPEND_VAR($2); }
|   Var ',' T_Identifier            { _APPEND_VAR($3); }
;

Stmts:
    /* empty */                     { /* empty */ }
|   Stmts Stmt                      { /* empty */ }
;

EndFuncDef:
    '}'                             { _END_FUNCDEF(); }
;

Stmt:
    AssignStmt                      { /* empty */ }
|   CallStmt                        { /* empty */ }
|   IfStmt                          { /* empty */ }
|   WhileStmt                       { /* empty */ }
|   BreakStmt                       { /* empty */ }
|   ContinueStmt                    { /* empty */ }
|   ReturnStmt                      { /* empty */ }
|   PrintStmt                       { /* empty */ }
;

AssignStmt:
    T_Identifier '=' Expr ';'       { out_asm("\tpop %s", $1); }
;

CallStmt:
    CallExpr ';'                    { out_asm("\tpop"); }
;

IfStmt:
    If '(' Expr ')' Then '{' Stmts '}' EndThen EndIf
                                    { /* empty */ }
|   If '(' Expr ')' Then '{' Stmts '}' EndThen T_Else '{' Stmts '}' EndIf
                                    { /* empty */ }
;

If:
    T_If            { _BEG_IF; out_asm("_begIf_%d:", _i); }
;

Then:
    /* empty */     { out_asm("\tjz _elIf_%d", _i); }
;

EndThen:
    /* empty */     { out_asm("\tjmp _endIf_%d\n_elIf_%d:", _i, _i); }
;

EndIf:
    /* empty */     { out_asm("_endIf_%d:", _i); _END_IF; }
;

WhileStmt:
    While '(' Expr ')' Do '{' Stmts '}' EndWhile
                    { /* empty */ }
;

While:
    T_While         { _BEG_WHILE; out_asm("_begWhile_%d:", _w); }
;

Do:
    /* empty */     { out_asm("\tjz _endWhile_%d", _w); }
;

EndWhile:
    /* empty */     { out_asm("\tjmp _begWhile_%d\n_endWhile_%d:", 
                                                _w, _w); _END_WHILE; }
;

BreakStmt:
    T_Break ';'     { out_asm("\tjmp _endWhile_%d", _w); }
;

ContinueStmt:
    T_Continue ';'  { out_asm("\tjmp _begWhile_%d", _w); }
;

ReturnStmt:
    T_Return ';'            { out_asm("\tret"); }
|   T_Return Expr ';'       { out_asm("\tret ~"); }
;

PrintStmt:
    T_Print '(' T_StringConstant PrintIntArgs ')' ';'
                            { out_asm("\tprint %s", $3); }
;

PrintIntArgs:
    /* empty */             { /* empty */ }
|   PrintIntArgs ',' Expr   { /* empty */ }
;

Expr:
    T_IntConstant           { out_asm("\tpush %s", $1); }
|   T_Identifier            { out_asm("\tpush %s", $1); }
|   Expr '+' Expr           { out_asm("\tadd"); }
|   Expr '-' Expr           { out_asm("\tsub"); }
|   Expr '*' Expr           { out_asm("\tmul"); }
|   Expr '/' Expr           { out_asm("\tdiv"); }
|   Expr '%' Expr           { out_asm("\tmod"); }
|   Expr '>' Expr           { out_asm("\tcmpgt"); }
|   Expr '<' Expr           { out_asm("\tcmplt"); }
|   Expr T_Ge Expr          { out_asm("\tcmpge"); }
|   Expr T_Le Expr          { out_asm("\tcmple"); }
|   Expr T_Eq Expr          { out_asm("\tcmpeq"); }
|   Expr T_Ne Expr          { out_asm("\tcmpne"); }
|   Expr T_Or Expr          { out_asm("\tor"); }
|   Expr T_And Expr         { out_asm("\tand"); }
|   '-' Expr %prec '!'      { out_asm("\tneg"); }
|   '!' Expr                { out_asm("\tnot"); }
|   ReadInt                 { /* empty */ }
|   CallExpr                { /* empty */ }
|   '(' Expr ')'            { /* empty */ }
;

ReadInt:
    T_ReadInt '(' T_StringConstant ')'
                            { out_asm("\treadint %s", $3); }
;

CallExpr:
    T_Identifier Actuals
                            { out_asm("\t$%s", $1); }
;

Actuals:
    '(' ')'
|   '(' _Actuals ')'
;

_Actuals:
    Expr
|   _Actuals ',' Expr
;

%%

int main(int argc, char *argv[]) {
    init_parser(argc, argv);
    yyparse();
    quit_parser();
}

void init_parser(int argc, char *argv[]) {
    if (argc < 2) {
        file_error("Must provide an input source file!");
    }

    if (argc > 2) {
        file_error("Too much command line arguments!");
    }

    char *in_file_name = argv[1];
    int len = strlen(in_file_name);

    if (len <= 2 || in_file_name[len-1] != 'c' \
            || in_file_name[len-2] != '.') {
        file_error("Must provide an '.c' source file!");
    }

    if (!(yyin = fopen(in_file_name, "r"))) {
        file_error("Input file open error");
    }

    char out_file_name[BUFSIZE];
    strcpy(out_file_name, in_file_name);

    out_file_name[len-1] = 'a';
    out_file_name[len]   = 's';
    out_file_name[len+1] = 'm';
    out_file_name[len+2] = '\0';
    if (!(asmfile = fopen(out_file_name, "w"))) {
        file_error("Output 'asm' file open error");
    }

    out_file_name[len-1] = 'i';
    out_file_name[len]   = 'n';
    out_file_name[len+1] = 'c';
    if (!(incfile = fopen(out_file_name, "w"))) {
        file_error("Output 'inc' file open error");
    }
}

void file_error(char *msg) {
    printf("\n*** Error ***\n\t%s\n", msg);
    puts("");
    exit(-1);
}

char *cat_strs(char *buf, char *strs[], int strc) {
    int i;
    strcpy(buf, strs[0]);
    for (i = 1; i < strc; i++) {
        strcat(strcat(buf, ", "), strs[i]);
    }
    return buf;
}

#define _fn (cur_func_name)

void write_func_head() {
    char buf[BUFSIZE];
    int i;

    out_asm("FUNC @%s:", _fn);
    if (argc > 0) {
        out_asm("\t%s.arg %s", _fn, cat_strs(buf, args, argc));
    }
    if (varc > 0) {
        out_asm("\t%s.var %s", _fn, cat_strs(buf, vars, varc));
    }

    out_inc("; ==== begin function `%s` ====", _fn);
    out_inc("%%define %s.argc %d", _fn, argc);
    out_inc("\n%%MACRO $%s 0\n"
            "   CALL @%s\n"
            "   ADD ESP, 4*%s.argc\n"
            "   PUSH EAX\n"
            "%%ENDMACRO",
            _fn, _fn, _fn);
    if (argc) {
        out_inc("\n%%MACRO %s.arg %s.argc", _fn, _fn);
        for (i = 0; i < argc; i++) {
            out_inc("\t%%define %s [EBP + 8 + 4*%s.argc - 4*%d]",
                        args[i], _fn, i+1);
        }
        out_inc("%%ENDMACRO");
    }
    if (varc) {
        out_inc("\n%%define %s.varc %d", _fn, varc);
        out_inc("\n%%MACRO %s.var %s.varc", _fn, _fn);
        for (i = 0; i < varc; i++) {
            out_inc("\t%%define %s [EBP - 4*%d]",
                        vars[i], i+1);
        }
        out_inc("\tSUB ESP, 4*%s.varc", _fn);
        out_inc("%%ENDMACRO");
    }
}

void write_func_tail() {
    int i;

    out_asm("ENDFUNC@%s\n", _fn);

    out_inc("\n%%MACRO ENDFUNC@%s 0\n\tLEAVE\n\tRET", _fn);
    for (i = 0; i < argc; i++) {
        out_inc("\t%%undef %s", args[i]);
    }
    for (i = 0; i < varc; i++) {
        out_inc("\t%%undef %s", vars[i]);
    }
    out_inc("%%ENDMACRO");
    out_inc("; ==== end function `%s`   ====\n", _fn);

    argc = 0;
    varc = 0;
}

void quit_parser() {
    fclose(yyin); fclose(asmfile); fclose(incfile);
}
