CC = gcc
OBJ = lex.yy.o y.tab.o

calc: $(OBJ)
	$(CC) -o calc $(OBJ)

lex.yy.c: calc.l y.tab.c
	flex $<

y.tab.c: calc.y
	bison -vdty $<

clean:
	rm -f *.o lex.yy.c y.tab.c y.tab.h y.output calc