run: print
	./print

print: print.o libtio.a
	ld -m elf_i386 -o print print.o -L. -ltio

print.o: print.nasm print-macro.inc
	nasm -f elf32 -P"print-macro.inc" -o print.o print.nasm

libtio.a: tio.c
	gcc -m32 -c -o tio.o tio.c
	ar -crv libtio.a tio.o

clean:
	rm print.o print tio.o libtio.a
