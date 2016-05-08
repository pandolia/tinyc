for src in $(ls samples/*.c)
do
	clear
	file=${src%%.c}
	echo build with tcc
	./tcc < $file.c > $file.asm
	python pysim.py $file.asm -a
	echo
	echo build with gcc
	gcc -o $file $file.c
	./$file
	echo
	echo press any key to continue...
	read -n 1
done