import math
import random


def est(x, y):
    a = min(abs(x), abs(y)) / max(abs(x), abs(y))
    s = a*a
    r = ((-0.0464964749 * s + 0.15931422) * s - 0.327622764) * s * a + a

    if abs(y) > abs(x):
        r = 1.57079637 - r
    if x < 0:
        r = 3.14159274 - r
    if y < 0:
        r = -r
    return r

max_error = 0
for i in range(1000000):
    x = random.random()*160000
    y = random.random()*160000
    error = abs(math.atan2(y, x)-est(x, y))
    if error > max_error:
        max_error = error
print(max_error)

