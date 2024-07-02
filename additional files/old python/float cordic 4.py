import math
import numpy as np
from hypothesis import given, strategies as st, settings


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


def atan2_cordic(y, x, iterations):
    scale = 1 / calculate_scale(iterations)

    mag, _, atan = vector_mode(abs(y), x, 0, iterations)

    if x > 0:
        return mag * scale, atan

    if x < 0 and y >= 0:
        return mag * scale, atan + math.pi

    if x < 0 and y < 0:
        return mag * scale, atan - math.pi

    if x == 0.0 and y > 0.0:
        return mag * scale, math.pi/2

    if x == 0.0 and y < 0.0:
        return mag * scale, -math.pi/2

    if x == 0.0 and y == 0.0:
        return 0.0, 0.0

    return None


def mag(x,y):
    return math.sqrt(x*x+y*y)


@given(st.integers(max_value=2**32,min_value=0), st.integers(max_value=2**32,min_value=0))
@settings(max_examples=1000)
def test_atan2(ax, ay):
    x = ax / (2 ** 16)
    y = ay / (2 ** 16)
    vector_magnitude, atan_est = atan2_cordic(y, x, 15)
    true_atan = math.atan2(y, x)

    tolerance = 0.02
    assert math.isclose(atan_est, true_atan, abs_tol=tolerance), f"Expected atan {true_atan}, but got {atan_est}"
    assert math.isclose(vector_magnitude, mag(x,y), abs_tol=tolerance), f"Expected atan {mag(x,y)}, but got {vector_magnitude}"

    tolerance = 0.02
    #assert math.isclose(t_roll, a_roll, abs_tol=tolerance), f"Expected roll {t_roll}, but got {a_roll}"
    #assert math.isclose(t_pitch, a_pitch, abs_tol=tolerance), f"Expected pitch {t_pitch}, but got {a_pitch}"

if __name__ == "__main__":
    test_atan2()