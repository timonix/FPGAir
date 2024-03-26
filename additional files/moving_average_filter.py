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
num_samples = 2  # Number of samples for moving average

# Generate frequency points for bode plot
freq = np.linspace(0, fs / 2, 1000)

# Compute the frequency response of the moving average filter
h = np.zeros_like(freq, dtype=complex)
for i in range(len(freq)):
    omega = 2 * np.pi * freq[i] / fs
    h[i] = np.sum(np.exp(-1j * omega * np.arange(num_samples))) / num_samples

# Compute magnitude response in dB
mag_db = 20 * np.log10(np.abs(h))

# Compute phase response in degrees
phase_deg = np.angle(h, deg=True)

# Plot the magnitude response (bode plot)
plt.figure(figsize=(8, 4))
plt.subplot(2, 1, 1)
plt.semilogx(freq, mag_db)
plt.xlabel('Frequency (Hz)')
plt.ylabel('Magnitude (dB)')
plt.title('Bode Plot - Moving Average Filter')
plt.grid(True)

# Plot the phase response
plt.subplot(2, 1, 2)
plt.semilogx(freq, phase_deg)
plt.xlabel('Frequency (Hz)')
plt.ylabel('Phase (degrees)')
plt.title('Phase Response - Moving Average Filter')
plt.grid(True)

plt.tight_layout()
plt.show()