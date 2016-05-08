%MACRO print 1
    [SECTION .DATA]
        %%STRING:   DB %1, 10, 0
    [SECTION .TEXT]
        PUSH DWORD %%STRING
        CALL PRINT
        SHL EAX, 2
        ADD ESP, EAX
%ENDMACRO

%MACRO exit 1
    MOV EAX, 1
    MOV EBX, %1
    INT 0x80
%ENDMACRO

EXTERN PRINT
GLOBAL _start

[SECTION .TEXT]
_start:
