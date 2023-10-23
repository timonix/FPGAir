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
    print(math.atan(2 ** -i)/(2*math.pi))
    x_new = x - y * d * 2 ** -i
    y_new = y + x * d * 2 ** -i
    z_new = z - d * math.atan(2 ** -i)/(2*math.pi)
    return x_new, y_new, z_new


def vector_mode_next(x, y, z, i):
    d = 1 if y < 0 else -1
    return get_next_state(x, y, z, d, i)


def vector_mode(initial_x, initial_y, initial_z, num_iterations):
    x, y, z = initial_x, initial_y, initial_z
    for i in range(num_iterations):
        x, y, z = vector_mode_next(x, y, z, i)
        #print(z)

    return x, y, z


def find_pitch_roll_test(a_x, a_y, a_z, iterations):

    scale = 1 / calculate_scale(iterations)

    mag_yz, _, theta = vector_mode(a_y, a_z, 0, iterations)
    mag_yz *= scale

    mag_xyz, _, phi = vector_mode(-a_x, mag_yz, 0, iterations)
    mag_xyz *= scale

    return theta, phi


# sine_test_simple()
x, y, z = -0.1, 0.1, 0.01
ax, ay, az = 1, 1, 98


roll, pitch = find_pitch_roll_test(ax, ay, az, 20)
print(f"Roll: {math.degrees(roll*2*math.pi)} degrees")
print(f"Pitch: {math.degrees(pitch*2*math.pi)} degrees")

print(f"Roll: {roll} bin degrees")
print(f"Pitch: {pitch} bin degrees")


r = math.sqrt(x * x + y * y + z * z)
theta = math.atan2(y, x)
phi = math.atan2(math.sqrt(x * x + y * y), z)

print("................")
print(r)
print(theta)
print(phi)

