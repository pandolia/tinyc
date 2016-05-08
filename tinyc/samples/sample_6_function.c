#include "for_gcc_build.hh" // only for gcc, TinyC will ignore it.

int main() {
	int n;
	n = 1;

	print("The first 10 number of the fibonacci sequence:");
	while (n <= 10) {
		print("fib(%d)=%d", n, fib(n));
		n = n + 1;
	}

	return 0;
}

int fib(int n) {
	if (n <= 2) {
		return 1;
	}
	return fib(n - 1) + fib(n - 2);
}