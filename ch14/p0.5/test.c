// tiny c test file

int main() {
    int a, b, c, d;

    c = 2;
    d = c * 2;

    a = sum(c, d);
    b = sum(a, d);
    print("c = %d, d = %d", c, d);
    print("a = sum(c, d) = %d, b = sum(a, d) = %d", a, b);

    return 0;
}

int sum(int a, int b) {
    int c, d;
    return a + b;
}