#include "for_gcc_build.hh" // only for gcc, TinyC will ignore it.

int main() {
	int x, y, z;

	x = 1;
	y = 2;
	z = x + y;

	print("x = %d, y = %d, z = %d", x, y, z);
	print("x + y = %d", x + y);
	print("x - y = %d", x - y);
	print("x * y = %d", x * y);
	print("x / y = %d", x / y);
	print("x %% y = %d", x % y);
	print("-x = %d, -y = %d", -x, -y);

	return 0;
}
