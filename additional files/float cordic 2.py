import math
import numpy as np


def jopp(x, y, z):
    acc_total_vector = math.sqrt((x * x) + (y * y) + (z * z))
    angle_roll_acc = math.asin(x / acc_total_vector) * -57.296
    angle_pitch_acc = math.asin(y / acc_total_vector) * 57.296
    return angle_roll_acc, angle_pitch_acc


def soom(x,y,z):
    roll = math.atan2(y, z)
    pitch = math.atan2((- x), math.sqrt(y * y + z * z))

    theta = math.atan2(y, x)
    phi = math.atan2(math.sqrt(x * x + y * y), z)  # pitch
    return roll* 57.296,pitch* 57.296


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

    return mag*scale, atan


def my_jopp_est(x, y, z, iterations):

    mag_yz, _ = atan2_est(y, z, iterations)
    mag_xz, _ = atan2_est(x, z, iterations)

    _, alpha = atan2_est(x, mag_yz, iterations)
    _,  beta = atan2_est(y, mag_xz, iterations)

    return -alpha * 57.296, beta * 57.296


def sample_spherical(npoints, ndim=3):
    vec = np.random.randn(ndim, npoints)
    vec /= np.linalg.norm(vec, axis=0)
    return vec.swapaxes(0, 1)

print(f"{my_jopp_est(1, 2, 3, 20)} : {jopp(1,2,3)}")
print(f"{my_jopp_est(4, 5, 3, 20)} : {jopp(4,5,3)}")
print(f"{my_jopp_est(-4, 5, 3, 20)} : {jopp(-4,5,3)}")
print(f"{my_jopp_est(-4, -8, 3, 20)} : {jopp(-4,-8,3)}")


#for x, y, z in sample_spherical(10):
#    print(f"{my_est(x, y, z, 20)} : {jopp(x,y,z)}")
