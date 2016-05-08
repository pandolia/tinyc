void SYS_PRINT(char *string, int len);

#define BUFLEN 1024

int PRINT(char *fmt, ...)
{
    int *args = (int*)&fmt;
    char buf[BUFLEN];
    char *p1 = fmt, *p2 = buf + BUFLEN;
    int len = -1, argc = 1;

    while (*p1++) ;

    do {
        p1--;
        if (*p1 == '%' && *(p1+1) == 'd') {
            p2++; len--; argc++;
            int num = *(++args), negative = 0;

            if (num < 0) {
                negative = 1;
                num = -num;
            }

            do {
                *(--p2) = num % 10 + '0'; len++;
                num /= 10;
            } while (num);

            if (negative) {
                *(--p2) = '-'; len++;
            }
        } else {
            *(--p2) = *p1; len++;
        }
    } while (p1 != fmt);

    SYS_PRINT(p2, len);

    return argc;
}

void SYS_PRINT(char *string, int len)
{
    __asm__(
    ".intel_syntax noprefix\n\
        PUSH EAX\n\
        PUSH EBX\n\
        PUSH ECX\n\
        PUSH EDX\n\
        \n\
        MOV EAX, 4\n\
        MOV EBX, 1\n\
        MOV ECX, [EBP+4*2]\n\
        MOV EDX, [EBP+4*3]\n\
        INT 0X80\n\
        \n\
        POP EDX\n\
        POP ECX\n\
        POP EBX\n\
        POP EAX\n\
    .att_syntax"
    );
}

int STRLEN(char *s);
int SYS_READ(char *buf, int len);

int READINT(char *prompt) {
    char buf[BUFLEN], *p = buf, *p_end;
    SYS_PRINT(prompt, STRLEN(prompt));
    int len = SYS_READ(buf, BUFLEN-1), value = 0, negative = 0;

    p_end = buf + len + 1;

    while (p != p_end) {
        if (*p == ' ' || *p == '\t') {
            p++;
        } else {
            break;
        }
    }

    if (p != p_end && *p == '-') {
        negative = 1;
        p++;
    }
    
    while (p != p_end) {
        if (*p <= '9' && *p >= '0') {
            value = value * 10 + *p - '0';
            *p++;
        } else {
            break;
        }
    }

    if (negative) {
        value = -value;
    }

    return value;
}

int STRLEN(char *s) {
    int i = 0;
    while(*s++) i++;
    return i;
}

int SYS_READ(char *buf, int len) {
    __asm__(
    ".intel_syntax noprefix\n\
        PUSH EBX\n\
        PUSH ECX\n\
        PUSH EDX\n\
        \n\
        MOV EAX, 3\n\
        MOV EBX, 2\n\
        MOV ECX, [EBP+4*2]\n\
        MOV EDX, [EBP+4*3]\n\
        INT 0X80\n\
        \n\
        POP EDX\n\
        POP ECX\n\
        POP EBX\n\
    .att_syntax"
    );
}