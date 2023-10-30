import math
import numpy as np
import matplotlib.pyplot as plt


def calculate_scale(iterations):
    res = 1
    for i in range(iterations):
        res *= math.sqrt(1 + 2 ** (-2 * i))
    return res


def get_next_state(x, y, z, i):
    d = 1 if y < 0 else -1
    x_new = x - y * d * 2 ** -i
    y_new = y + x * d * 2 ** -i
    z_new = z - d * math.atan(2 ** -i)
    return x_new, y_new, z_new


def vector_mode(initial_x, initial_y, initial_z, num_iterations):
    x, y, z = initial_x, initial_y, initial_z
    for i in range(num_iterations):
        x, y, z = get_next_state(x, y, z, i)
    return x, y, z


def atan2_est(x, y, iterations):
    scale = 1 / calculate_scale(iterations)

    mag, _, atan = vector_mode(abs(y), x, 0, iterations)

    if y < 0 and x > 0:
        atan = math.pi - atan

    if y < 0 and x < 0:
        atan = - atan - math.pi

    return atan

B = 1

X = np.arange(-15, 15, 0.01)
y0 = []
y1 = []
for x in X:
    y0.append(atan2_est(x, B, 8))
    y1.append(math.atan2(x, B))

print(len(y0))
y0 = np.array(y0)
y1 = np.array(y1)

plt.plot(X, y0, color='r', label='est')
plt.plot(X, y1, color='g', label='fac')
plt.legend()
plt.show()


a = 1.2
b = 2

facit = math.atan2(a, b)
est = atan2_est(a, b, 20)

print(facit)
print(est)
