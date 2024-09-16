import serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque
import time
import math

from scipy.signal import firwin, lfilter

# Open serial port
ser = serial.Serial('COM6', 115200, timeout=1)

fig, ax = plt.subplots()
num_lines = 4  # Number of lines you want to plot
# data_queues = [deque(maxlen=100) for _ in range(num_lines)]  # List of deques, one for each line
# lines = [ax.plot([], [])[0] for _ in range(num_lines)]  # List of line objects
x_data = []
y_data = []
z_data = []
roll_data = []

pid_setpoint_data = []
pid_measured_data = []
pid_output_data = []

sampled_pid_setpoint_data = []
sampled_pid_measured_data = []
sampled_pid_output_data = []

sampled_calculated_roll = []
plot_roll, = plt.plot([], [], 'yellow', label="Roll")
plot_calculated_roll, = plt.plot([], [], 'purple', label="Calculated Roll")

plot_x, = plt.plot([], [], 'blue', label="X")
plot_y, = plt.plot([], [], 'red', label="Y")
plot_z, = plt.plot([], [], 'green', label="Z")

plot_pid_setpoint, = plt.plot([], [], 'yellow', label="Setpoint")
plot_pid_measured, = plt.plot([], [], 'green', label="Measured")
plot_pid_output, = plt.plot([], [], 'red', label="Output")

sampled_x_data = []
sampled_y_data = []
sampled_z_data = []
sampled_roll_data = []
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
            print("-----------------------------------------------------------------------")
            for i in range(num_lines):
                
                if i == 0:
                    raw_data = ser.read(2)
                    data = int.from_bytes(raw_data, byteorder='little')
                    if data > 2**15:
                        data = -(2**16 - data)
                    # if i == 0:
                    #     data /= 2**16
                    #     data *= 360
                else:
                    raw_data = ser.read(3)
                    data = int.from_bytes(raw_data, byteorder='little')
                    if data > 2**23:
                        data = -(2**24 - data)
                    # if i == 0:
                    #     data /= 2**16
                    #     data *= 360
                # data_queues[i].append(data)
                # lines[i].set_data(range(len(data_queues[i])), data_queues[i])

                if i == 3: pid_setpoint_data.append(data)
                if i == 2: pid_output_data.append(data)
                if i == 1: pid_measured_data.append(data)
                if i == 0: roll_data.append(data)

                print(data)

def update_plot():
    global start_time
    current_time = time.time() - start_time

    if roll_data and pid_setpoint_data and pid_measured_data and pid_output_data:
        sampled_roll_data.append(roll_data[len(roll_data)-1])
        # sampled_x_data.append(x_data[len(x_data)-1])
        # sampled_y_data.append(y_data[len(y_data)-1])
        # sampled_z_data.append(z_data[len(z_data)-1])
        sampled_pid_setpoint_data.append(pid_setpoint_data[len(pid_setpoint_data)-1])
        sampled_pid_measured_data.append(pid_measured_data[len(pid_measured_data)-1])
        sampled_pid_output_data.append(pid_output_data[len(pid_output_data)-1])
        x_axis.append(len(sampled_roll_data))

        # sampled_calculated_roll.append(-math.degrees(math.atan2(-y_data[len(y_data)-1], z_data[len(z_data)-1])))

        plot_roll.set_data(x_axis, sampled_roll_data)
        # plot_calculated_roll.set_data(x_axis, sampled_calculated_roll)
        # plot_x.set_data(x_axis, sampled_x_data)
        # plot_y.set_data(x_axis, sampled_y_data)
        # plot_z.set_data(x_axis, sampled_z_data)
        plot_pid_setpoint.set_data(x_axis, sampled_pid_setpoint_data)
        plot_pid_measured.set_data(x_axis, sampled_pid_measured_data)
        plot_pid_output.set_data(x_axis, sampled_pid_output_data)
        

        ax.set_xlim(x_axis[len(x_axis)-1]-50, x_axis[len(x_axis)-1])
        ax.set_ylim(-1000000, 1000000)
    
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
                
                update_plot()
                last_time = time.time()

    except KeyboardInterrupt:
        pass
    finally:
        print("Closing up for the day...")
        ser.close()
