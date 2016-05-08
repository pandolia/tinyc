mkdir -p release
flex sources/scanner.l
bison -vdty sources/parser.y
gcc -o release/tcc-frontend lex.yy.c y.tab.c
rm -f y.* lex.*
gcc -m32 -c -o tio.o sources/tio.c
ar -crv release/libtio.a tio.o > /dev/null
rm -f tio.o
cp sources/macro.inc sources/pysim.py sources/tcc sources/pysimulate release/
chmod u+x release/tcc release/pysimulate
export PATH=$PATH:$PWD/release
echo "export PATH=\$PATH:$PWD/release" >> ~/.bashrc

