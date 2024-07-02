import numpy as np
import matplotlib.pyplot as plt


def filter(signal, coefficients):
    filtered_signal = np.zeros_like(signal)
    for i in range(len(signal)):
        for j in range(len(coefficients)):
            if i - j >= 0:
                filtered_signal[i] += signal[i - j] * coefficients[j]
    return filtered_signal


def moving_average_filter(signal, num_samples):
    coefficients = np.ones(num_samples) / num_samples
    filtered_signal = filter(signal, coefficients)
    return filtered_signal


def custom_filter(signal):
    filtered_signal = np.zeros_like(signal)
    last_value = signal[0]
    for i in range(len(signal)):
        current_value = signal[i]
        filtered_value = (last_value * 7 + current_value) / 8
        filtered_signal[i] = filtered_value
        last_value = filtered_value
    return filtered_signal

# Filter parameters
fs = 4000  # Sampling frequency (Hz)
cutoff = 250  # Cutoff frequency (Hz)
taps = 4  # Number of filter taps

# Normalize the cutoff frequency
nyquist_freq = 0.5 * fs
normalized_cutoff = cutoff / nyquist_freq

# Design the FIR filter coefficients
coefficients = [0.0008134345395110439,0.0040015525064583425,0.013721573617726253,0.03389544426018197,0.06441733429627058,0.10010488203795675,0.13205993914240877,0.15098583959948622,0.15098583959948622,0.13205993914240877,0.1001048820379568,0.06441733429627061,0.03389544426018197,0.013721573617726263,0.004001552506458345,0.0008134345395110439]


# Generate a test signal
t = np.linspace(0, 1, fs, endpoint=False)
signal = np.sin(2 * np.pi * 50 * t) + 0.5 * np.sin(2 * np.pi * 720 * t)

# Apply the filter to the signal
filtered_signal = filter(signal, coefficients)
filtered_signal = moving_average_filter(signal, 4)
filtered_signal = custom_filter(signal)

# Plot the original and filtered signals
plt.figure(figsize=(8, 4))
plt.plot(t, signal, label='Original Signal')
plt.plot(t, filtered_signal, label='Filtered Signal')
plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.title('Original and Filtered Signals')
plt.legend()
plt.grid(True)
plt.show()