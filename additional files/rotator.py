import numpy as np
import matplotlib.pyplot as plt

def rotate_vector(vector, angles):
    x, y, z = vector
    rx, ry, rz = angles
    # Small angle approximation
    x_new = x - y * rz + z * ry
    y_new = y - z * rx + x * rz
    z_new = z - x * ry + y * rx

    return [x_new, y_new, z_new]

    rot_x = np.array([[1, 0, 0],
                      [0, 1, -rx],
                      [0, rx, 1]])
    rot_y = np.array([[1, 0, ry],
                      [0, 1, 0],
                      [-ry, 0, 1]])
    rot_z = np.array([[1, -rz, 0],
                      [rz, 1, 0],
                      [0, 0, 1]])



    rotation_matrix = np.dot(rot_x, np.dot(rot_z, rot_y))
    rotation_matrix = np.array([[1, -rz, ry],
                                [rz, 1, -rx],
                                [-ry, rx, 1]])

    rotated_vector = np.dot(rotation_matrix, vector)
    return rotated_vector

    return [x_new, y_new, z_new]

def rotate_vector_actual(vector, angles):
    x, y, z = vector
    rx, ry, rz = angles
    # Rotation matrix
    rot_x = np.array([[1, 0, 0],
                      [0, np.cos(rx), -np.sin(rx)],
                      [0, np.sin(rx), np.cos(rx)]])
    rot_y = np.array([[np.cos(ry), 0, np.sin(ry)],
                      [0, 1, 0],
                      [-np.sin(ry), 0, np.cos(ry)]])
    rot_z = np.array([[np.cos(rz), -np.sin(rz), 0],
                      [np.sin(rz), np.cos(rz), 0],
                      [0, 0, 1]])
    rotation_matrix = np.dot(rot_z, np.dot(rot_y, rot_x))
    rotated_vector = np.dot(rotation_matrix, vector)
    return rotated_vector

# Set the vector and angles
vector = [1, 2, 5]
angles_deg = np.linspace(-3, 3, 100)  # Angles in degrees
angles_rad = np.deg2rad(angles_deg)  # Convert to radians

errors = []
for angle in angles_rad:
    rotated_approx = rotate_vector(vector, [angle, 0, 0])
    print(f"angle:{angle} ---{rotated_approx}")
    rotated_actual = rotate_vector_actual(vector, [angle, 0, 0])
    error = np.linalg.norm(np.array(rotated_approx) - rotated_actual)/np.linalg.norm(vector)
    errors.append(error)

plt.figure(figsize=(8, 6))
plt.plot(angles_deg, errors, linewidth=2)
plt.xlabel('Angle (degrees)')
plt.ylabel('Error')
plt.title('Error vs. Angle (Small Angle Approximation)')
plt.grid(True)
plt.show()