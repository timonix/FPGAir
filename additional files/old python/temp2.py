import serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque
from matplotlib.widgets import TextBox
import numpy as np
from scipy.signal import firwin, lfilter
from itertools import count

# Open serial port
#ser = serial.Serial('COM4', 115200, timeout=1)

fig, ax = plt.subplots()
num_lines = 6  # Number of lines you want to plot
data_queues_signal = [deque(maxlen=100) for _ in range(num_lines)]  # List of deques, one for each line
lines_signal = [ax.plot([], [])[0] for _ in range(num_lines)]  # List of line objects

data_queues_target = [deque(maxlen=100) for _ in range(num_lines)]  # List of deques, one for each line
lines_target = [ax.plot([], [])[0] for _ in range(num_lines)]  # List of line objects

pid_target = None

ax.set_xlim(0, 100)  # Adjust x-axis limits
ax.set_ylim(-16000, 16000)  # Adjust y-axis limits for your data range

current_x = count(0, 1)
x = [] 
y_signal = 0
y_target = 0

# Initialize the plot
def init_signal():
    
    return lines_signal

def init_target():
    return lines_target

# Update plot function
def update_plot_signal(frame):
    #if ser.in_waiting > 0:
    #raw_data = ser.read(1)
    #delimiter = int.from_bytes(raw_data, byteorder='little')
    #if chr(delimiter) == 'D':

    for i in range(num_lines):
        #raw_data = ser.read(2)
        data = 10
        #data = int.from_bytes(raw_data, byteorder='big')
        #if data > 16384:
        #    data = -(32768 - data)
        data_queues_signal[i].append(data)
        lines_signal[i].set_data(range(len(data_queues_signal[i])), data_queues_signal[i])

        ax.plot(1, 1000)
            
        #data_queue.append(data)
        #line.set_data(range(len(data_queue)), data_queue)
    return tuple(lines_signal)

def update_plot_target(frame):
    global pid_target
    for i in range(num_lines):
        data_queues_target[i].append(pid_target)
        lines_target[i].set_data(range(len(data_queues_target[i])), data_queues_target[i])
    return tuple(lines_target)

def update_plot(i):
    pid_signal = 100

    x.append(next(current_x))
    #y_signal.append((pid_signal))
    #y_target.append(pid_target)
 
    ax.plot(x, pid_signal, color="red")
    ax.plot(x, pid_target, color="blue")

def submit(text):
    global pid_target
    pid_target = int(text)

# Create the animation
ani = animation.FuncAnimation(fig, update_plot, interval=0.1)
#ani1 = animation.FuncAnimation(fig, update_plot_signal, init_func=init_signal, blit=True, interval=0.1)
#ani2 = animation.FuncAnimation(fig, update_plot_target, init_func=init_target, blit=True, interval=0.1)

text_box_position = plt.axes([0.12, 0.05, 0.8, 0.075])
text_box = TextBox(text_box_position, 'PID Target')
text_box.on_submit(submit)
from matplotlib.widgets import TextBox

# Start the plot
plt.show()

# Close the serial port
ser.close()
