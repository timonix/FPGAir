import numpy as np
from scipy import signal
import matplotlib.pyplot as plt
from fxpmath import Fxp

def low_pass_filter(input_data, prev_output, filter_coeff):
    output_data = (input_data * filter_coeff) >> (filter_coeff.n_word - 1) + prev_output
    prev_output = output_data
    return output_data, prev_output

# Filter parameters
DATA_WIDTH = 16
COEFF_WIDTH = 8
filter_coeff = Fxp(1, True, COEFF_WIDTH, COEFF_WIDTH - 1)  # Example coefficient (0.5 in Q8 format)

# Generate frequency response
w, h = signal.freqz([float(filter_coeff)], [1, -float(filter_coeff)], worN=8000)

# Convert frequency to Hz
freq = w * 0.5 / np.pi

# Plot magnitude response (Bode plot)
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(8, 6))

ax1.semilogx(freq, 20 * np.log10(abs(h)))
ax1.set_title('Magnitude Response')
ax1.set_xlabel('Frequency (Hz)')
ax1.set_ylabel('Magnitude (dB)')
ax1.grid(True)

# Plot phase response
angles = np.unwrap(np.angle(h))
ax2.semilogx(freq, angles * 180 / np.pi)
ax2.set_title('Phase Response')
ax2.set_xlabel('Frequency (Hz)')
ax2.set_ylabel('Phase (degrees)')
ax2.grid(True)

plt.tight_layout()
plt.show()