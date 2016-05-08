#include "for_gcc_build.hh" // only for gcc, TinyC will ignore it.

int main() {
	print("1 == 2 is %d", 1 == 2);
	print("2 == 2 is %d", 2 == 2);
	print("2 == 3 is %d", 2 == 3);

	print("1 != 2 is %d", 1 != 2);
	print("2 != 2 is %d", 2 != 2);
	print("2 != 3 is %d", 2 != 3);

	print("1 >  2 is %d", 1 >  2);
	print("2 >  2 is %d", 2 >  2);
	print("2 >  3 is %d", 2 >  3);

	print("1 <  2 is %d", 1 <  2);
	print("2 <  2 is %d", 2 <  2);
	print("2 <  3 is %d", 2 <  3);

	print("1 >= 2 is %d", 1 >= 2);
	print("2 >= 2 is %d", 2 >= 2);
	print("2 >= 3 is %d", 2 >= 3);

	print("1 <= 2 is %d", 1 <= 2);
	print("2 <= 2 is %d", 2 <= 2);
	print("2 <= 3 is %d", 2 <= 3);

	return 0;
}
