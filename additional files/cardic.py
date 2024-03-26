import math
from math import degrees
from hypothesis import given, strategies as st, settings


def rotate_by_angle(x, y, angle):
    x_new = x - math.tan(angle) * y
    y_new = y + math.tan(angle) * x

    return x_new, y_new


int_strat = st.integers(min_value=0, max_value=2 ** 32)


@given(int_strat, int_strat, st.floats(min_value=0, max_value=math.pi / 2))
@settings(max_examples=1000)
def test_rotate(t_x, t_y, t_angle):
    x, y = rotate_by_angle(t_x, t_y, t_angle)

    resulting_angle_change = math.atan2(y, x) - math.atan2(t_y, t_x)

    if x != 0.0 and y != 0.0:
        assert math.isclose(resulting_angle_change, t_angle, abs_tol=0.00001), \
            f"Expected {t_angle}, but got {resulting_angle_change}"
    else:
        assert math.isclose(resulting_angle_change, 0, abs_tol=0.00001), \
            f"Expected {0}, but got {resulting_angle_change}"


def rotate_by_power(x, y, t_angle_as_exponent, direction):
    angle = math.atan(1 / 2 ** t_angle_as_exponent)

    if direction == "down":
        return rotate_by_angle(x, y, -angle)
    if direction == "up":
        return rotate_by_angle(x, y, angle)


def rotate_towards_zero(x, y):
    for i in range(16):
        print(f"X:{x},Y:{y}")
        if y > 0:
            x, y = rotate_by_power(x, y, i, "down")
        elif y < 0:
            x, y = rotate_by_power(x, y, i, "up")



def run_tests():
    test_rotate()


if __name__ == "__main__":
    rotate_towards_zero(0, 1)
