import math

E = 0.001

def richardson_formula(I_h, I_h2, k):
    return (I_h - I_h2) / (2 ** k - 1)


def trapezoid_method(f, n):
    h = (b - a) / n
    s = 0
    for i in range(1, n):
        s += f(a + i * h)
    result = h * ((f(a) + f(b)) / 2 + s)
    return result


def rectangle_method(f, n):
    h = (b - a) / n
    s = 0
    for i in range(1, n + 1):
        s += f(a + (i - 0.5) * h)
    result = h * s
    return result


def simpson_method(f, n):
    h = (b - a) / n
    s1, s2, s3 = 0, 0, 0
    for i in range(1, n + 2):
        if i == n:
            s2 += f(a + (i - 0.5) * h)
            s3 += f(a + (i - 1) * h)
        elif i == n + 1:
            s3 += f(a + (i - 1) * h)
        else:
            s1 += f(a + i * h)
            s2 += f(a + (i - 0.5) * h)
            s3 += f(a + (i - 1) * h)
    result = h / 6 * (s1 + 4 * s2 + s3)
    return result


def compute_until_accuracy(method, k):
    n_arr, I_h_arr, R_arr = [], [], []
    n = 1
    R = 1
    I_h = 0

    while abs(R) >= E:
        n *= 2
        I_h2 = I_h
        I_h = method(f, n)
        if I_h2 != 0:
            R = richardson_formula(I_h, I_h2, k)
            n_arr.append(n)
            I_h_arr.append(I_h)
            R_arr.append(R)
        else:
            n_arr.append(n)
            I_h_arr.append(I_h)
            R_arr.append(0)

    return n_arr, I_h_arr, R_arr

def print_results_table(rect_results, trap_results, simp_results):
    rect_n, rect_I, rect_R = rect_results
    trap_n, trap_I, trap_R = trap_results
    simp_n, simp_I, simp_R = simp_results

    print(f"EPS = {E}")
    print(f"Точное значение интеграла: {math.exp(1) - 1:.6f}")
    print()

    table_data = [
        {
            "Метод": "Прямоугольников",
            "n": rect_n[-1],
            "I*": rect_I[-1],
            "R": rect_R[-1],
            "I*+R": rect_I[-1] + rect_R[-1]
        },
        {
            "Метод": "Трапеций",
            "n": trap_n[-1],
            "I*": trap_I[-1],
            "R": trap_R[-1],
            "I*+R": trap_I[-1] + trap_R[-1]
        },
        {
            "Метод": "Симпсона",
            "n": simp_n[-1],
            "I*": simp_I[-1],
            "R": simp_R[-1],
            "I*+R": simp_I[-1] + simp_R[-1]
        }
    ]

    print("Метод             n       I*          R           I*+R")

    for row in table_data:
        print(f"{row['Метод']:<16} {row['n']:^5}   {row['I*']:^9.6f}   {row['R']:^9.6f}   {row['I*+R']:^8.6}")

a, b = 1, 0
f = math.exp

rect_results = compute_until_accuracy(rectangle_method, 2)
trap_results = compute_until_accuracy(trapezoid_method, 2)
simp_results = compute_until_accuracy(simpson_method, 4)

print_results_table(rect_results, trap_results, simp_results)