MOV EBP, ESP
SUB ESP, 8
%define a [EBP-4]
%define b [EBP-8]

; a = readint("Please input an number `a`: ")
readint "Please input an number `a`: "
pop a       ; ==> POP DWORD [EBP-4]

; b = readint("Please input another number `b`: ")
readint "Please input another number `b`: "
pop b       ; ==> POP DWORD [EBP-8]

; print("a = %d", a)
push a      ; ==> PUSH DWORD [EBP-4]
print "a = %d"

; print("b = %d", b)
push b      ; ==> PUSH DWORD [EBP-8]
print "b = %d"

; print("a - b = %d", a - b)
push a
push b
sub
print "a - b = %d"

; if (a > b) { print("a > b"); } else { print("a <= b") }
push a
push b
cmpgt
jz _LESSEQUAL
print "a > b"
jmp _EXIT
_LESSEQUAL:
    print "a <= b"
_EXIT:
    exit 0