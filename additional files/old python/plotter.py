import serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque

from scipy.signal import firwin, lfilter

# Open serial port
ser = serial.Serial('COM4', 115200, timeout=1)

fig, ax = plt.subplots()
num_lines = 6  # Number of lines you want to plot
data_queues = [deque(maxlen=100) for _ in range(num_lines)]  # List of deques, one for each line
lines = [ax.plot([], [])[0] for _ in range(num_lines)]  # List of line objects


# Initialize the plot
def init():
    ax.set_xlim(0, 100)  # Adjust x-axis limits
    ax.set_ylim(-16000, 16000)  # Adjust y-axis limits for your data range
    return lines

# Update plot function
def update_plot(frame):
    if ser.in_waiting > 0:
        raw_data = ser.read(1)
        delimiter = int.from_bytes(raw_data, byteorder='little')
        if chr(delimiter) == 'D':

            for i in range(num_lines):
                raw_data = ser.read(2)
                data = int.from_bytes(raw_data, byteorder='big')
                if data > 16384:
                    data = -(32768 - data)
                data_queues[i].append(data)
                lines[i].set_data(range(len(data_queues[i])), data_queues[i])

                
            #data_queue.append(data)
            #line.set_data(range(len(data_queue)), data_queue)
    return tuple(lines)

# Create the animation
ani = animation.FuncAnimation(fig, update_plot, init_func=init, blit=True, interval=0.1)

# Start the plot
plt.show()

# Close the serial port
ser.close()
