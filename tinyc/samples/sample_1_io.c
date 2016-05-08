#include "for_gcc_build.hh" // only for gcc, TinyC will ignore it.

int main() {
	int n;
	n = readint("Please input an integer: ");
	print("Your input number is: %d", n);

	return 0;
}
