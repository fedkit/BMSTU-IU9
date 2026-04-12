#include <stdio.h>

int add(int a, int b) {
    return a + b;
}

int mul(int a, int b) {
    return a * b;
}

int max(int a, int b) {
    if (a > b)
        return a;
    return b;
}

int sum_array(int *arr, int n) {
    int s = 0;
    for (int i = 0; i < n; i++) {
        s = add(s, arr[i]);
    }
    return s;
}

int main() {
    int x = 3;
    int y = 7;

    int a = add(x, y);
    int b = mul(a, 2);

    int c = max(b, 10);

    int arr[5] = {1, 2, 3, 4, 5};
    int r1 = sum_array(arr, 5);

    int i, sum = 0;
    for (i = 0; i < 10; i++) {
        sum = add(sum, i);
    }

    int r2 = sum;

    int r3;
    if (x < 0) {
        r3 = -1;
    } else if (x == 0) {
        r3 = 0;
    } else {
        r3 = 1;
    }

    int a2 = x;
    int *p = &a2;
    *p = *p + 10;

    int r4 = a2;

    printf("%d %d %d %d\n", r1, r2, r3, r4);

    return 0;
}