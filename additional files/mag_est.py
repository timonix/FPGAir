import random
import math
from tqdm import tqdm


def est(x, y, a, b):
    return a * abs(y) + b * abs(x)


def generate_random_vector():
    # Generate a random angle between -10 and 10 degrees
    angle_degrees = random.uniform(-15, 15)

    # Convert the angle to radians
    angle_radians = math.radians(angle_degrees)

    # Calculate the x and y components
    # The negative sign for y ensures the vector points downwards
    x = math.sin(angle_radians)
    y = -math.cos(angle_radians)

    return (x, y)


best_a = 0.947543
best_b = 0.392485
best_err = 999999999999999999999999999

for i in tqdm(range(1000)):
    total_err = 0
    test_a = best_a+(random.random()-0.5)*0.001
    test_b = best_b+(random.random()-0.5)*0.001
    for _ in range(50000):
        vector = generate_random_vector()
        total_err += 1-abs(est(vector[0], vector[1], test_a, test_b))

    if total_err < best_err:
        best_a = test_a
        best_b = test_b

print(total_err)
print(best_a)
print(best_b)