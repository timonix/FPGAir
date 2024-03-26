import math

for i in range(16):
    angle = 2**16*math.atan(1 / 2 ** i)/(2*math.pi)

    print(angle)
