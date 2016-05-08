#include "for_gcc_build.hh" // only for gcc, TinyC will ignore it.

int main() {
	int n;
	n = 10;

	while (n != 0) {
		print("n = %d", n);
		if (n == 5) {
			break;
		}
		n = n - 1;
	}

	return 0;
}