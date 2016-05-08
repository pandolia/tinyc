run: word-spliter
	./word-spliter < word-spliter.l

word-spliter: lex.yy.c
	gcc -o $@ $<

lex.yy.c: word-spliter.l
	flex $<
