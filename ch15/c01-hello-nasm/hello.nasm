GLOBAL _start

[SECTION .TEXT]
_start:
    MOV EAX, 4          ; write
    MOV EBX, 1          ; stdout
    MOV ECX, msg
    MOV EDX, len
    INT 0x80            ; write(stdout, msg, len)

    MOV EAX, 1          ; exit
    MOV EBX, 0
    INT 0x80            ; exit(0)

[SECTION .DATA]
    msg: DB  "Hello, world!", 10
    len: EQU $-msg