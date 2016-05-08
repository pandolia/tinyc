run: hello
	./hello

hello: hello.nasm
	nasm -f elf32 -o hello.o hello.nasm
	ld -m elf_i386 -o hello hello.o

clean:
	rm hello.o hello