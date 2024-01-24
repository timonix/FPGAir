import serial
import time
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque

# Open serial port
ser = serial.Serial('COM6', 1000000, timeout=1)


# Read data from the serial port
try:
    data = 0
    while True:

        if ser.in_waiting > 0:
            raw_data = ser.read(1)
            delimiter = int.from_bytes(raw_data, byteorder='little')
            if chr(delimiter) == 'D':

                raw_data = ser.read(2)
                acc_z = int.from_bytes(raw_data, byteorder='big')
                if acc_z > 16384:
                    acc_z = -(32768-acc_z)
                raw_data = ser.read(2)
                acc_y = int.from_bytes(raw_data, byteorder='big')
                if acc_y > 16384:
                    acc_y = -(32768 - acc_y)
                raw_data = ser.read(2)
                acc_x = int.from_bytes(raw_data, byteorder='big')
                if acc_x > 16384:
                    acc_x = -(32768 - acc_x)

                raw_data = ser.read(2)
                gyro_z = int.from_bytes(raw_data, byteorder='big')
                if gyro_z > 16384:
                    gyro_z = -(32768 - gyro_z)
                raw_data = ser.read(2)
                gyro_y = int.from_bytes(raw_data, byteorder='big')
                if gyro_y > 16384:
                    gyro_y = -(32768 - gyro_y)
                raw_data = ser.read(2)
                gyro_x = int.from_bytes(raw_data, byteorder='big')
                if gyro_x > 16384:
                    gyro_x = -(32768 - gyro_x)

                print(f"acc_x:{acc_x},acc_y:{acc_y},acc_z:{acc_z},\t\t\tgyro_x:{gyro_x},gyro_y:{gyro_y},gyro_z:{gyro_z}")


        #time.sleep(0.01)  # Small delay to prevent overwhelming the CPU
except KeyboardInterrupt:
    pass

# Close the serial port
ser.close()