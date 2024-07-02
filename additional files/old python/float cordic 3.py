import math
from hypothesis import given, strategies as st, settings
import matplotlib.pyplot as plt
import numpy as np


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


def calculate_scale(iterations):
    res = 1
    for i in range(iterations):
        res *= math.sqrt(1 + 2 ** (-2 * i))
    return res


def jopp(x, y, z):
    acc_total_vector = math.sqrt((x * x) + (y * y) + (z * z))
    angle_roll_acc = math.asin(x / acc_total_vector) * -57.296
    angle_pitch_acc = math.asin(y / acc_total_vector) * 57.296
    return angle_roll_acc, angle_pitch_acc


def atan_y_over_x(y, x, iterations):
    scale = 1 / calculate_scale(iterations)
    mag, _, atan = vector_mode(abs(x), y, 0, iterations)
    if y == 0:
        return mag * scale, 0
    if x < 0:
        return mag * scale, -atan
    return mag * scale, atan


def atan2_est(y, x, iterations):
    if x > 0:
        return atan_y_over_x(y, x, iterations)
    if x < 0 and y >= 0:
        return atan_y_over_x(y, x, iterations)[0], atan_y_over_x(y, x, iterations)[1] + math.pi
    if x < 0 and y < 0:
        return atan_y_over_x(y, x, iterations)[0], atan_y_over_x(y, x, iterations)[1] - math.pi
    if x == 0 and y > 0:
        return atan_y_over_x(y, x, iterations)
    if x == 0 and y < 0:
        return atan_y_over_x(y, x, iterations)
    if x == 0 and y == 0:
        return 0, 0


def my_jopp_est(x, y, z, iterations, debug=False):
    mag_yz, _ = atan2_est(y, z, iterations)
    mag_xz, _ = atan2_est(x, z, iterations)

    _, alpha = atan2_est(x, mag_yz, iterations)
    _, beta = atan2_est(y, mag_xz, iterations)

    if debug:
        print(f"roll:{-alpha * 57.296}")
        print(f"pitch:{beta * 57.296}")
        print(f"mag_yz:{mag_yz}")
        print(f"mag_xz:{mag_xz}")

    return -alpha * 57.296, beta * 57.296


def my_rp_est(x, y, z, iterations, debug=False):
    mag_yz, theta = atan2_est(y, z, iterations)
    mag_xyz, phi = atan2_est(-x, mag_yz, iterations)

    if debug:
        print(f"roll:{theta * 57.296}")
        print(f"pitch:{phi * 57.296}")
        print(f"mag_yz:{mag_yz}")
        print(f"mag_xyz:{mag_xyz}")

    return theta * 57.296, phi * 57.296


def rp(x, y, z, debug = False):
    roll = math.atan2(y, z) * 57.3
    pitch = math.atan2((- x), math.sqrt(y * y + z * z)) * 57.3
    if debug:
        print(f"roll:{roll}")
        print(f"pitch:{pitch}")
        print(f"mag_yz:{math.sqrt(y * y + z * z)}")
        print(f"mag_xyz:{math.sqrt(x*x+y * y + z * z)}")

    return roll, pitch


@given(st.integers(), st.integers())
@settings(max_examples=500)
def test_y_over_x(ax, ay):
    if ax != 0:
        target = math.atan(ay / ax)
        actual = atan_y_over_x(ay, ax, 100)[1]
        tolerance = 0.001
        assert math.isclose(target, actual, abs_tol=tolerance), f"Expected {target}, but got {actual}"


@given(st.integers(), st.integers(), st.integers())
@settings(max_examples=500)
def test_rp(ax, ay, az):
    t_roll, t_pitch = rp(ax, ay, az)
    a_roll, a_pitch = my_jopp_est(ax, ay, az, 15)
    tolerance = 0.02
    assert math.isclose(t_roll, a_roll, abs_tol=tolerance), f"Expected roll {t_roll}, but got {a_roll}"
    assert math.isclose(t_pitch, a_pitch, abs_tol=tolerance), f"Expected pitch {t_pitch}, but got {a_pitch}"


@given(st.integers(), st.integers(), st.integers())
@settings(max_examples=500)
def test_jopp(ax, ay, az):
    t_roll, t_pitch = jopp(ax, ay, az)
    a_roll, a_pitch = my_rp_est(ax, ay, az, 15)
    tolerance = 0.01
    assert math.isclose(t_roll, a_roll, abs_tol=tolerance), f"Expected roll {t_roll}, but got {a_roll}"
    assert math.isclose(t_pitch, a_pitch, abs_tol=tolerance), f"Expected pitch {t_pitch}, but got {a_pitch}"

if __name__ == "__main__":
    # print(math.atan2(0, 0.0) * 57.3)
    my_jopp_est(0,0,-1,15,True)
    # print(atan2_est(0, 0.0, 20)[1] * 57.3)
    test_y_over_x()
    # test_rp()
    test_jopp()
