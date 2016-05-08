    ; int a, b;
    var a, b

    ; a = 1 + 2;
    push 1
    push 2
    add
    pop a

    ; b = a * 2
    push a
    push 2
    mul
    pop b

    ; print("a = %d, b = %d", a, b);
    push a
    push b
    print "a = %d, b = %d"
