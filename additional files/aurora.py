import serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque
import time

from scipy.signal import firwin, lfilter

# Open serial port
ser = serial.Serial('COM6', 115200, timeout=1)

fig, ax = plt.subplots()
num_lines = 4  # Number of lines you want to plot
# data_queues = [deque(maxlen=100) for _ in range(num_lines)]  # List of deques, one for each line
# lines = [ax.plot([], [])[0] for _ in range(num_lines)]  # List of line objects
roll_data = []
plot_roll, = plt.plot([], [], 'r')
sampled_data = []
x_axis = []

# Initialize the plot
def init():
    ax.set_xlim(0, 100)  # Adjust x-axis limits
    ax.set_ylim(-180, 180)  # Adjust y-axis limits for your data range
    return plot_roll

# Update plot function
def read_serial():
    if ser.in_waiting > 0:
        raw_data = ser.read(1)
        delimiter = int.from_bytes(raw_data, byteorder='little')
        if chr(delimiter) == 'D':

            for i in range(num_lines):
                if i == 3:
                    raw_data = ser.read(2)
                    data = int.from_bytes(raw_data, byteorder='little')
                    if data > 2**15:
                        data = -(2**16 - data)
                    data /= 2**15
                    data *= 360
                    # data_queues[i].append(data)
                    # lines[i].set_data(range(len(data_queues[i])), data_queues[i])
                    roll_data.append(data)
                    print(data)
                    return data

def update_plot():
    global start_time
    current_time = time.time() - start_time

    if roll_data:
        sampled_data.append(roll_data[len(roll_data)-1])
        x_axis.append(len(sampled_data))
        plot_roll.set_data(x_axis, sampled_data)

        ax.set_xlim(x_axis[len(x_axis)-1]-50, x_axis[len(x_axis)-1])
    
    plt.show()
    plt.pause(0.001)

if __name__ == "__main__":
    start_time = time.time()
    plot_delay = 0.04
    last_time = time.time()

    plt.ion()
    init()

    try:
        while True:
            read_serial()

            if time.time() - last_time > plot_delay:
                print("-----------------------------------------------------------------------")
                update_plot()
                last_time = time.time()

    except KeyboardInterrupt:
        pass
    finally:
        print("Closing up for the day...")
        ser.close()
