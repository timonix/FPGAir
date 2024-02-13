# TODO make it work
# Limit Cum_error
# Map out what happens to the values
# Little or big endian?


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

fig, ax = plt.subplots(figsize=(10, 6))

pid_target = 0
pid_signal = 1000
pid_signal_raw = 0

ax.set_xlim(0, 100)  # Adjust x-axis limits
ax.set_ylim(-5000, 5000)  # Adjust y-axis limits for your data range

x_iter = count(0, 1)
x, y1, y2 = [], [], []

def read_serial_data():
    global pid_signal, pid_signal_raw
    try:
        if ser.in_waiting > 0:
            raw_data = ser.read(1)
            delimiter = int.from_bytes(raw_data, byteorder='little')
            if chr(delimiter) == 'D':

                raw_data = ser.read(3)
                data = int.from_bytes(raw_data, byteorder='big')
                if data > 2**23:
                    data = -(2**24 - data)

                pid_signal_raw = data
                #pid_signal = float(data) / 2**13
    except Exception as e:
        print(f"Serial read error: {e}")

def send_serial_data(out_data):
    print(f"PID_Signal raw: {out_data}")
    out_data = out_data >> 8
    print(f"PID_Signal after: {out_data}")
    #print(float(data)/2**11)
    out_data = 1000 << 5
    try:
        ser.write(out_data.to_bytes(2, byteorder='little', signed=True))
    except Exception as e:
        print(f"Serial send error: {e}")

def update_plot(i):
    print("----------")
        
    # Read/send data from/to FPGA
    read_serial_data()
    print(f"PID_Signal from FPGA: {pid_signal_raw}")
    send_serial_data(pid_signal_raw)
    
    # Plot stuff
    draw_plot()


def submit(text):
    global pid_target
    pid_target = int(text)

def draw_plot():
    current_x = next(x_iter)
    x.append(current_x)
    ax.set_xlim(current_x-100, current_x)

    y1.append((pid_signal))
    y2.append((pid_target))
 
    ax.plot(x, y1, color="red")
    ax.plot(x, y2, color="blue")

    
# Create the animation
ani = animation.FuncAnimation(fig, update_plot, interval=0.1)

text_box_position = plt.axes([0.12, 0, 0.5, 0.075])
text_box = TextBox(text_box_position, 'PID Target')
text_box.on_submit(submit)

# Start the plot
plt.show()

# Close the serial port
ser.close()


# fpga -> python : 23 bitar
# 
# 
# 
# 