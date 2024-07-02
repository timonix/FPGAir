import numpy as np
import matplotlib.pyplot as plt
from scipy import signal

# Define the filter function
last_value = 0

def filter(x):
    global last_value
    r = last_value*0.5 + x * 1/256
    last_value = r
    return r

# Generate input signal
t = np.linspace(0, 1, 1000)
x = np.sin(2 * np.pi * 10 * t)

# Apply the filter to the input signal
y = np.zeros_like(x)
for i in range(len(x)):
    y[i] = filter(x[i])

# Calculate the frequency response
w, h = signal.freqz(0.05, [1, -0.95], worN=1024)

# Plot the Bode diagram
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(8, 6))

# Magnitude plot
ax1.semilogx(w, 20 * np.log10(abs(h)))
ax1.set_title('Bode Diagram')
ax1.set_xlabel('Frequency [rad/sample]')
ax1.set_ylabel('Magnitude [dB]')
ax1.grid(True)

# Phase plot
ax2.semilogx(w, np.angle(h, deg=True))
ax2.set_xlabel('Frequency [rad/sample]')
ax2.set_ylabel('Phase [deg]')
ax2.grid(True)

plt.tight_layout()
plt.show()