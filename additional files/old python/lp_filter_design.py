import numpy as np
import scipy.signal as signal
import matplotlib.pyplot as plt

# Filter parameters
fs = 4000  # Sampling frequency (Hz)
cutoff = 250  # Cutoff frequency (Hz)
taps = 16  # Number of filter taps

# Normalize the cutoff frequency
nyquist_freq = 0.5 * fs
normalized_cutoff = cutoff / nyquist_freq

# Design the FIR filter
b = signal.firwin(taps, normalized_cutoff)

print("[", end="")
for bb in b:
    print(bb, end="")
    print(",", end="")
print("]", end="")


# Compute the frequency response
w, h = signal.freqz(b)

# Convert frequency to Hz
freq = w * fs / (2 * np.pi)

# Compute magnitude response in dB
mag_db = 20 * np.log10(np.abs(h))

# Compute phase response in degrees
phase_deg = np.angle(h, deg=True)

# Plot the magnitude response (bode plot)
plt.figure(figsize=(8, 4))
plt.subplot(2, 1, 1)
plt.plot(freq, mag_db)
plt.xlabel('Frequency (Hz)')
plt.ylabel('Magnitude (dB)')
plt.title('Bode Plot')
plt.grid(True)

# Plot the phase response
plt.subplot(2, 1, 2)
plt.plot(freq, phase_deg)
plt.xlabel('Frequency (Hz)')
plt.ylabel('Phase (degrees)')
plt.title('Phase Response')
plt.grid(True)

plt.tight_layout()
plt.show()
