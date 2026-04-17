import numpy as np

N = 10
p, q = 0, -4
f = lambda x: 16 * x * np.exp(2 * x)

x_start, x_end = 0, 1
X = np.linspace(x_start, x_end, N + 1)

answer = lambda x: np.exp(2 * x) * (2 * x**2 - x - 1) + np.exp(-2 * x)

A = 0
B = np.exp(-2)

h = (x_end - x_start) / N


def solve_progonka(A_m, d):
    n = len(d)

    alpha = [0] * (n - 1)
    beta = [0] * (n - 1)

    alpha[0] = -A_m[0][1] / A_m[0][0]
    beta[0] = d[0] / A_m[0][0]

    for i in range(1, n - 1):
        ai = A_m[i][i - 1]
        bi = A_m[i][i]
        ci = A_m[i][i + 1]

        z = bi + ai * alpha[i - 1]

        alpha[i] = -ci / z
        beta[i] = (d[i] - ai * beta[i - 1]) / z

    x = [0] * n

    x[n - 1] = (d[n - 1] - A_m[n - 1][n - 2] * beta[n - 2]) / (
        A_m[n - 1][n - 1] + A_m[n - 1][n - 2] * alpha[n - 2]
    )

    for i in range(n - 2, -1, -1):
        x[i] = alpha[i] * x[i + 1] + beta[i]

    return x


def solve_diff_progonka():
    A_m = np.zeros((N - 1, N - 1))
    d = np.zeros(N - 1)

    for i in range(1, N):

        xi = X[i]

        ai = 1 - h * p / 2
        bi = h**2 * q - 2
        ci = 1 + h * p / 2

        if i - 2 >= 0:
            A_m[i - 1][i - 2] = ai

        A_m[i - 1][i - 1] = bi

        if i < N - 1:
            A_m[i - 1][i] = ci

        d[i - 1] = h**2 * f(xi)

    d[0] -= (1 - h * p / 2) * A
    d[N - 2] -= (1 + h * p / 2) * B

    y_inner = solve_progonka(A_m, d)

    y = [A]
    y.extend(y_inner)
    y.append(B)

    return np.array(y)


def solve_diff_shooting():
    y0 = np.zeros(N + 1)
    y1 = np.zeros(N + 1)

    D0 = A
    D1 = h

    y0[0] = A
    y0[1] = D0

    y1[0] = 0
    y1[1] = D1

    for i in range(1, N):
        xi = X[i]

        y0[i + 1] = (
            f(xi) * h**2
            + (2 - q * h**2) * y0[i]
            - (1 - p * h / 2) * y0[i - 1]
        ) / (1 + p * h / 2)

        y1[i + 1] = (
            (2 - q * h**2) * y1[i]
            - (1 - p * h / 2) * y1[i - 1]
        ) / (1 + p * h / 2)

    C1 = (B - y0[N]) / y1[N]

    y = y0 + C1 * y1

    return y


def main():
    y1 = solve_diff_progonka()
    y2 = solve_diff_shooting()

    print(f"{'x'} {'y':>12} {'y1':>15} {'y2':>15} {'|y-y1|':>20} {'|y-y2|':>17}")

    y = answer(X)

    for i in range(N + 1):
        print(f'{X[i]:.1f} {y[i]:15.6f} {y1[i]:15.6f} {y2[i]:15.6f} '
              f'{abs(y[i] - y1[i]):15.16f} {abs(y[i] - y2[i]):15.16f}')

if __name__ == '__main__':
    main()
