for src in $(ls samples/*.c)
do
	filename=${src%.*}
	fileext=${src##*.}
	filenakedname=${filename##*/}
	objdir=$filename-$fileext-build

	clear
	echo build \"$src\" and run
	echo
	tcc "$src"
	"$objdir/$filenakedname"
	echo
	echo press any key to continue...
	read -n 1
done
