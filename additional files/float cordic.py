import math

def rot_mode_next(x, y, z, i):
    d = -1 if z < 0 else 1
    return get_next_state(x, y, z, d, i)


def calculate_scale(iterations):
    res = 1
    for i in range(iterations):
        res *= math.sqrt(1 + 2 ** (-2 * i))
    return res


def sine_test_simple():
    test_angle = 0.3
    target = math.sin(test_angle)

    iterations = 12
    initial_x = 1 / calculate_scale(iterations)
    initial_y = 0
    initial_z = test_angle

    x, y, z = initial_x, initial_y, initial_z
    for i in range(iterations):
        x, y, z = rot_mode_next(x, y, z, i)

    error = abs(target - y)
    print(error)
    print(math.log2(error))
    return x, y, z


def get_next_state(x, y, z, d, i):
    #print(math.atan(2 ** -i)/(2*math.pi))
    x_new = x - y * d * 2 ** -i
    y_new = y + x * d * 2 ** -i
    z_new = z - d * math.atan(2 ** -i)
    return x_new, y_new, z_new


def vector_mode_next(x, y, z, i):
    d = 1 if y < 0 else -1
    return get_next_state(x, y, z, d, i)


def vector_mode(initial_x, initial_y, initial_z, num_iterations):
    x, y, z = initial_x, initial_y, initial_z
    for i in range(num_iterations):
        x, y, z = vector_mode_next(x, y, z, i)

    return x, y, z


def atan2_est(x, y, iterations):
    scale = 1 / calculate_scale(iterations)

    mag, _, atan = vector_mode(abs(y), x, 0, iterations)

    if y < 0 and x > 0:
        atan = math.pi - atan

    if y < 0 and x < 0:
        atan = - atan - math.pi

    return mag*scale, atan


def find_pitch_roll_test(a_x, a_y, a_z, iterations):

    mag_yz, theta = atan2_est(a_y, a_z, iterations)
    mag_xyz, phi = atan2_est(a_x, mag_yz, iterations)

    return theta, phi


# sine_test_simple()
x, y, z = 1, 2, 3


r = math.sqrt(x * x + y * y + z * z)
theta = math.atan2(y, x)
phi = math.atan2(math.sqrt(x * x + y * y), z) # pitch

roll = math.atan2(y, z)
pitch = math.atan2((- x), math.sqrt(y * y + z * z))

print("................")
#print(r)
print(theta * 57.3)
print(phi * 57.3)

print("---------")
print(roll*57.3)
print(pitch* 57.3)

print("----JOPP---")
acc_total_vector = math.sqrt((x * x) + (y * y) + (z * z))
angle_roll_acc = math.asin(x/acc_total_vector) * -57.296
angle_pitch_acc = math.asin(y/acc_total_vector) * 57.296

print(angle_roll_acc)
print(angle_pitch_acc)
print("CORDIC")

iterations = 20
scale = 1 / calculate_scale(iterations)

mag_yz, _, _ = vector_mode(y, z, 0, iterations)
mag_yz *= scale

mag_xz, _, _ = vector_mode(x, z, 0, iterations)
mag_xz *= scale

_, _, theta = vector_mode(x, mag_yz, 0, iterations)
_, _, phi = vector_mode(y, mag_xz, 0, iterations)


print(theta)
print(phi)


