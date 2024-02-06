import serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque
from matplotlib.widgets import TextBox
import numpy as np
from scipy.signal import firwin, lfilter
from itertools import count

# Open serial port
ser = serial.Serial('COM4', 115200, timeout=1)

fig, ax = plt.subplots()

pid_target = 0
pid_signal = 0

ax.set_xlim(0, 100)  # Adjust x-axis limits
ax.set_ylim(-16000, 16000)  # Adjust y-axis limits for your data range

x_iter = count(0, 1)
x, y1, y2 = [], [], []

def read_serial_data():
    global pid_signal
    try:
        if ser.in_waiting > 0:
            raw_data = ser.read(1)
            delimiter = int.from_bytes(raw_data, byteorder='little')
            if chr(delimiter) == 'D':

                raw_data = ser.read(2)
                data = int.from_bytes(raw_data, byteorder='big')
                #if data > 16384:
                #    data = -(32768 - data)

                pid_signal = data
    except Exception as e:
        print(f"Serial read error: {e}")

def update_plot(i):

    read_serial_data()

    current_x = next(x_iter)
    x.append(current_x)
    ax.set_xlim(current_x-100, current_x)

    y1.append((pid_signal))
    y2.append((pid_target))
 
    ax.plot(x, y1, color="red")
    ax.plot(x, y2, color="blue")

def submit(text):
    global pid_target
    pid_target = int(text)

# Create the animation
ani = animation.FuncAnimation(fig, update_plot, interval=0.1)

text_box_position = plt.axes([0.12, 0.05, 0.8, 0.075])
text_box = TextBox(text_box_position, 'PID Target')
text_box.on_submit(submit)

# Start the plot
plt.show()

# Close the serial port
ser.close()
