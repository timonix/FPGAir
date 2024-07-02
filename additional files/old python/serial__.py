import serial
import time
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque
import numpy as np

from scipy.signal import firwin, lfilter, butter
from scipy import signal

cutoff_freq = 0.1  # Cutoff frequency as a fraction of the sampling rate
# FIR filter
num_taps = 60  # Number of filter taps
# Create the FIR filter coefficients
fir_coefficients = firwin(num_taps, cutoff_freq)

# IIR filter
order = 4  # Order of the filter



# Display thy filter coefficients
#print("FIR Coefficients:", fir_coefficients)

# Create the IIR filter coefficients
b, a = butter(order, cutoff_freq, btype='low', analog=False, output='ba')

acc_x_list = []

# Open serial port
ser = serial.Serial('COM4', 115200, timeout=1)

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

                #acc_x_list = [1]+[0]*999
                acc_x_list.append(gyro_x)

                #sys = signal.TransferFunction(b, a)
                #w, mag, phase = signal.bode(sys)
                #lt.figure(label="mag")
                #plt.semilogx(w, mag)    # Bode magnitude plot
                #lt.figure(label="phase")
                #lt.semilogx(w, phase)  # Bode phase plot
                #plt.show()

                if len(acc_x_list) >= 1000:
                    
                    fft_result = np.fft.fft(np.array(acc_x_list))
                    magnitudes = np.abs(fft_result)
                    freq = np.fft.fftfreq(len(acc_x_list), 1/5000)
                    plt.figure(figsize=(12, 6))
                    plt.plot(freq, magnitudes)  # Plot frequency vs magnitude
                    plt.title("FFT of the Data")
                    plt.xlabel("Frequency")
                    plt.ylabel("Magnitude")
                    plt.grid()
                    plt.show()
                    # Apply the FIR filter to the signal
                    filtered_acc_x = lfilter(b, a, acc_x_list)
                    #filtered_acc_x = lfilter(fir_coefficients, 1, acc_x_list)

                    fft_result = np.fft.fft(np.array(filtered_acc_x))
                    magnitudes = np.abs(fft_result)
                    freq = np.fft.fftfreq(len(filtered_acc_x), 1/5000)
                    plt.figure(figsize=(12, 6))
                    plt.plot(freq, magnitudes)  # Plot frequency vs magnitude
                    plt.title("FFT of the Data")
                    plt.xlabel("Frequency")
                    plt.ylabel("Magnitude")
                    plt.grid()
                    plt.show()

                    #print(f"acc_x:{filtered_acc_x},acc_y:{acc_y},acc_z:{acc_z},\t\t\tgyro_x:{gyro_x},gyro_y:{gyro_y},gyro_z:{gyro_z}")
                    t = np.linspace(0, 1, 1000, endpoint=False)
                    # Plot the original and filtered signals
                    plt.plot(t, acc_x_list, label='Original Signal')
                    plt.plot(t, filtered_acc_x, label='Filtered Signal')
                    plt.legend()
                    plt.title("Original and Filtered Signals")
                    plt.xlabel("Time")
                    plt.ylabel("Amplitude")
                    plt.grid(True)
                    plt.show()




        #time.sleep(0.01)  # Small delay to prevent overwhelming the CPU
except KeyboardInterrupt:
    pass

# Close the serial port
ser.close()