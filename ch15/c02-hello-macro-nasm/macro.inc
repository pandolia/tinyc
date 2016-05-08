%MACRO print 1
    [SECTION .DATA]
        %%STRING:   DB %1, 10
        %%LEN:      EQU $-%%STRING
    [SECTION .TEXT]
        MOV EAX, 4          ; write
        MOV EBX, 1          ; stdout
        MOV ECX, %%STRING
        MOV EDX, %%LEN
        INT 0x80            ; write(stdout, %%STRING, %%LEN)
%ENDMACRO

%MACRO exit 1
    MOV EAX, 1
    MOV EBX, %1
    INT 0x80
%ENDMACRO

GLOBAL _start

[SECTION .TEXT]
_start:
