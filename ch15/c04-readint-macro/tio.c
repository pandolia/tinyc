#define BUFLEN 1024

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
