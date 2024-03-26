from fxpmath import Fxp as FP
from hypothesis import given, strategies as st, settings
import math
from math import degrees

FRACTIONAL_BITS = 12
INTEGER_BITS = 12
TOTAL_BITS = FRACTIONAL_BITS+INTEGER_BITS

ITERATIONS = 13


def rotate(x, y, index, direction):
    if direction == "up":
        x_new = x - (y >> index)
        y_new = y + (x >> index)

    if direction == "down":
        x_new = x + (y >> index)
        y_new = y - (x >> index)

    return x_new, y_new


int_strategy = st.integers(min_value=2, max_value=2 ** (FRACTIONAL_BITS + INTEGER_BITS-1) - 1)


@given(int_strategy, int_strategy)
@settings(max_examples=1000)
def test_rotate_0(t_x, t_y):

    x = FP(t_x/2**FRACTIONAL_BITS, signed=True, n_frac=FRACTIONAL_BITS, n_int=INTEGER_BITS-1)
    y = FP(t_y/2**FRACTIONAL_BITS, signed=True, n_frac=FRACTIONAL_BITS, n_int=INTEGER_BITS-1)

    x_new, y_new = rotate(x, y, 0, "down")


    resulting_angle_change = math.atan2(y, x) - math.atan2(y_new, x_new)

    if x != 0.0 or y != 0.0:
        assert math.isclose(resulting_angle_change, math.pi/4, abs_tol=2**(-FRACTIONAL_BITS-1)), \
            f"Expected {math.pi/4}, but got {resulting_angle_change}, {x_new.bin()}"
    if x == 0.0 and y == 0.0:
        assert math.isclose(resulting_angle_change, 0, abs_tol=2**(-FRACTIONAL_BITS-1)), \
            f"Expected {0}, but got {resulting_angle_change}"


@given(int_strategy, int_strategy)
@settings(max_examples=1000)
def test_rotate_1(t_x, t_y):
    x = FP(t_x/2**FRACTIONAL_BITS, signed=True, n_frac=FRACTIONAL_BITS, n_int=INTEGER_BITS-1)
    y = FP(t_y/2**FRACTIONAL_BITS, signed=True, n_frac=FRACTIONAL_BITS, n_int=INTEGER_BITS-1)

    x_new, y_new = rotate(x, y, 1, "down")

    resulting_angle_change = math.atan2(y, x) - math.atan2(y_new, x_new)

    if x != 0.0 or y != 0.0:
        assert math.isclose(resulting_angle_change, math.atan(1/2), abs_tol=2**(-FRACTIONAL_BITS-1)), \
            f"Expected {math.atan(1/2)}, but got {resulting_angle_change}"
    if x == 0.0 and y == 0.0:
        assert math.isclose(resulting_angle_change, 0, abs_tol=2**(-FRACTIONAL_BITS-1)), \
            f"Expected {0}, but got {resulting_angle_change}"


@given(int_strategy, int_strategy)
@settings(max_examples=1000)
def test_rotate_towards_zero(t_x, t_y):
    x = FP(t_x/2**FRACTIONAL_BITS, signed=True, n_frac=FRACTIONAL_BITS, n_int=INTEGER_BITS-1)
    y = FP(t_y/2**FRACTIONAL_BITS, signed=True, n_frac=FRACTIONAL_BITS, n_int=INTEGER_BITS-1)

    x_new, y_new, angle = rotate_to_zero(x, y)

    target_angle = math.atan(y/x)/(math.pi*2)

    length = math.sqrt(x*x+y*y)

    #assert math.isclose(y_new, 0.0, abs_tol=0.001), f"Expected {0}, but got {y_new}"
    assert math.isclose(x_new, length*calculate_scale(), rel_tol=0.0001), f"Expected {length*calculate_scale()}, but got {x_new}"
    assert math.isclose(angle, target_angle, abs_tol=0.0001), f"Expected {target_angle}, but got {angle}"


def rotate_to_zero(x, y):
    angle = FP(0, signed=True, n_frac=FRACTIONAL_BITS+INTEGER_BITS, n_int=0)

    for i in range(ITERATIONS):

        if y >= 0:
            x, y = rotate(x, y, i, "down")
            angle += math.atan(1 / 2 ** i)/(2*math.pi)
        elif y < 0:
            x, y = rotate(x, y, i, "up")
            angle -= math.atan(1 / 2 ** i)/(2*math.pi)
        angle.resize(True, FRACTIONAL_BITS+INTEGER_BITS, FRACTIONAL_BITS+INTEGER_BITS-1)

    return x, y, angle


def calculate_scale():
    res = 1
    for i in range(ITERATIONS):
        res *= math.sqrt(1 + 2 ** (-2 * i))
    return res


def main():

    x = FP(0.0, signed=True, n_frac=FRACTIONAL_BITS, n_int=INTEGER_BITS - 1)
    y = FP(1.0, signed=True, n_frac=FRACTIONAL_BITS, n_int=INTEGER_BITS - 1)
    x = FP(2 / 2 ** FRACTIONAL_BITS, signed=True, n_frac=FRACTIONAL_BITS, n_int=INTEGER_BITS - 1)
    y = FP(103299 / 2 ** FRACTIONAL_BITS, signed=True, n_frac=FRACTIONAL_BITS, n_int=INTEGER_BITS - 1)
    rotate_to_zero(x, y)
    test_rotate_towards_zero()
    test_rotate_0()
    test_rotate_1()


if __name__ == "__main__":
    main()
