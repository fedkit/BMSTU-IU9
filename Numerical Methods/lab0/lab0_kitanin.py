def solve(A, d):
    n = len(d)
    if n == 0:
        return []
    if n == 1:
        return [d[0] / A[0][0]]

    alpha = [0] * (n - 1)
    alpha[0] = -A[0][1] / A[0][0]
    beta  = [0] * (n - 1)
    beta[0] = d[0] / A[0][0]

    for i in range(1, n - 1):
        bi = A[i][i]
        ai = A[i][i - 1]
        ci = A[i][i + 1]

        z = bi + ai * alpha[i - 1]
        if z == 0:
            print('Деление на 0')
            return None

        alpha[i] = -ci / z
        beta[i]  = (d[i] - ai * beta[i - 1]) / z

    a_last = A[n - 1][n - 2]
    b_last = A[n - 1][n - 1]
    alpha_last = alpha[n - 2]
    beta_last  = beta[n - 2]

    x = [0] * n
    x[n - 1] = (d[n - 1] - a_last * beta_last) / (a_last * alpha_last + b_last)
    for i in range(n - 2, -1, -1):
        x[i] = alpha[i] * x[i + 1] + beta[i]
    return x

A = [[4, 1, 0, 0],
     [1, 4, 1, 0],
     [0, 1, 4, 1],
     [0, 0, 1, 4]]
d = [5, 6, 6, 5]

solution = solve(A, d)
print(solve(A, d))