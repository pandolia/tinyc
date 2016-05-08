#include <stdio.h>
#include <string.h>
#include <stdarg.h>

void print(char *format, ...) {
	va_list args;
	va_start(args, format);
    vprintf(format, args);
    va_end(args);
    puts("");
}

int readint(char *prompt) {
	int i;
	printf(prompt);
	scanf("%d", &i);
	return i;
}

#define auto
#define short
#define long
#define float
#define double
#define char
#define struct
#define union
#define enum
#define typedef
#define const
#define unsigned
#define signed
#define extern
#define register
#define static
#define volatile
#define switch
#define case
#define for
#define do
#define goto
#define default
#define sizeof
