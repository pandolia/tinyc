FUNC @main:
var a, b, c, d

push 2
pop c

push c
push 2
mul
pop d

push c
push d
$sum
pop a

push a
push d
$sum
pop b

push c
push d
print "c = %d, d = %d"

push a
push b
print "a = sum(c, d) = %d, b = sum(a, d) = %d"

push 0
ret ~

ENDFUNC

FUNC @sum:
arg a, b

var c, d

push a
push b
add
ret ~

ENDFUNC

