import math
import random

import numpy as np


def sample_spherical(npoints, ndim=3):
    vec = np.random.randn(ndim, npoints)
    vec /= np.linalg.norm(vec, axis=0)
    return vec


def facit(x, y, z):
    acc_total_vector = math.sqrt((x * x) + (y * y) + (z * z))
    angle_roll_acc = math.asin(x / acc_total_vector) * -57.296
    angle_pitch_acc = math.asin(y / acc_total_vector) * 57.296
    return angle_roll_acc, angle_pitch_acc


def est(x, y, z, m_consts, consts):
    ll = [x, y, z]
    ll.sort()
    mag_est = m_consts[2] * ll[2] + m_consts[1] * ll[1] + m_consts[0] * ll[0]

    ex = x * x * consts[0] + x * consts[1]
    ex += mag_est * mag_est * consts[2] + mag_est * consts[3]
    ex += mag_est * x * consts[4] + consts[5]

    ey = y * y * consts[0] + y * consts[1]
    ey += mag_est * mag_est * consts[2] + mag_est * consts[3]
    ey += mag_est * y * consts[4] + consts[5]

    return ex, ey


def mod_consts(const):
    new = []
    for c in const:
        new.append(c + random.random() * 0.001)
    return new


m_const = [0.0056217096766239694, 0.005458971958129721, 0.006251821401138835]
const = [0.006875934420521693, 0.0032448535841474633, 0.005214664359586263, 0.005035370987128177, 0.004801064225261093, 0.0049288196407989175]
best_err = 2**128

for loop_nr in range(4000000):
    err = 0
    test_const = mod_consts(const)
    test_m_const = mod_consts(m_const)
    for point in sample_spherical(10000).swapaxes(0, 1):
        i = point[0]
        j = point[1]
        k = point[2]

        err += abs(facit(i, j, k)[0] - est(i, j, k, test_m_const, test_const)[0])
        err += abs(facit(i, j, k)[1] - est(i, j, k, test_m_const, test_const)[1])

    if err < best_err:
        best_err = err
        const = test_const
        m_const = test_m_const
        print("---------")
        print(best_err)
        print(f"m_const={m_const}")
        print(f"const={const}")
