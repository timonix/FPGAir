# TODO make it work
# Limit Cum_error
# Map out what happens to the values
# Little or big endian?

from time import sleep
import serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque
from matplotlib.widgets import TextBox
import numpy as np
from scipy.signal import firwin, lfilter
from itertools import count

# Open serial port
ser = serial.Serial('COM4', 230400, timeout=1)

fig, ax = plt.subplots(figsize=(10, 6))

pid_setpoint = 0
pid_signal = 0
pid_signal_raw = 0
pid_feedback = 0

recorded_values = []

ax.set_xlim(0, 10000)  # Adjust x-axis limits
ax.set_ylim(-1100, 1100)  # Adjust y-axis limits for your data range

x_iter = count(0, 1)
x, y1, y2 = [], [], []

def read_serial_data():
    global pid_signal, pid_signal_raw, pid_feedback, running
    try:
        if ser.in_waiting > 0:
            raw_data = ser.read(1)
            delimiter = int.from_bytes(raw_data, byteorder='big')
            if chr(delimiter) == 'D':

                raw_data = ser.read(2)
                data = int.from_bytes(raw_data, byteorder='big')
                if data > 2**15:
                    data = -(2**16 - data)

                pid_feedback = pid_feedback+pid_signal
                pid_signal = float(data) / 2**5
                recorded_values.append(pid_signal)
    except Exception as e:
        print(f"Serial read error: {e}")

def send_serial_data(out_data):
    data = int(out_data * 2**5)
    try:
        ser.write(data.to_bytes(2, byteorder='little', signed=True))
    except Exception as e:
        print(f"Serial send error: {e}")

def update_plot(i):
    #print("----------")
        
    # Read/send data from/to FPGA
    read_serial_data()
    #print(f"PID_signal: {pid_signal}")
    #print(f"PID_feedback: {pid_feedback}")
    send_serial_data(pid_feedback)
    
    # Plot stuff
    current_x = next(x_iter)
    x.append(current_x)
    ax.set_xlim(current_x-1000, current_x)

    y1.append((pid_setpoint))
    y2.append((pid_signal))
 
    ax.plot(x, y1, color="red")
    ax.plot(x, y2, color="blue")


def submit(text):
    global pid_setpoint
    pid_setpoint = int(text)

def animate_plot():
    # Create the animation
    ani = animation.FuncAnimation(fig, update_plot, interval=0.01)

    text_box_position = plt.axes([0.12, 0, 0.5, 0.075])
    text_box = TextBox(text_box_position, 'PID Target')
    text_box.on_submit(submit)

    # Start the plot
    plt.show()

    # Close the serial port
    ser.close()

def start_plot():
    x = range(0, len(recorded_values))
    ax.set_xlim(0, len(recorded_values))
    ax.plot(x, recorded_values, color="red")
    plt.show()
    ser.close()

sleep(1)
print("GO!")
while True:
    read_serial_data()
    if len(recorded_values) >= 10000:
        start_plot()
        break
ser.close()
