import serial
import struct
import matplotlib.pyplot as plt
import numpy as np

# Configure the serial port
ser = serial.Serial(
    port='COM6',  # Replace with your COM port
    baudrate=115200,  # Replace with your baud rate
    bytesize=serial.EIGHTBITS,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE
)


def parse_word(word):
    data = int.from_bytes(word, byteorder='little')
    if data > 2 ** 23:
        data = -(2 ** 24 - data)
    return data/2**12


def read_data():
    # Wait for the delimiter 'D'
    while True:
        if ser.read(1) == b'D':
            break

    # Read 9 bytes (3 words, each 3 bytes long)

    word1 = parse_word(ser.read(3))
    word2 = parse_word(ser.read(3))
    word3 = parse_word(ser.read(2))
    word4 = parse_word(ser.read(2))
    word5 = parse_word(ser.read(2))
    word6 = parse_word(ser.read(2))

    return word1, word2, word3, word4, word5, word6

try:
    # Initialize arrays to store data
    data_points = 15000
    word1_data = np.zeros(data_points)
    word2_data = np.zeros(data_points)
    word3_data = np.zeros(data_points)
    word4_data = np.zeros(data_points)

    print(f"Collecting {data_points} data points...")

    # Collect data
    for i in range(data_points):
        word1, word2, word3, word4, word5, word6 = read_data()
        word1_data[i] = word1
        word2_data[i] = word2
        word3_data[i] = word3
        word4_data[i] = word4

        if (i + 1) % 1000 == 0:
            print(f"Collected {i + 1} data points")

    print("Data collection complete. Plotting...")

    # Create a figure with three subplots
    fig, (ax1, ax2, ax3, ax4) = plt.subplots(4, 1, figsize=(10, 15))

    # Plot data
    ax1.plot(word1_data[100:])
    ax1.set_title('roll')
    ax1.set_xlabel('Sample')
    ax1.set_ylabel('Value')

    ax2.plot(word2_data[100:])
    ax2.set_title('output')
    ax2.set_xlabel('Sample')
    ax2.set_ylabel('Value')

    ax3.plot(word3_data[100:])
    ax3.set_title('Motor 1')
    ax3.set_xlabel('Sample')
    ax3.set_ylabel('Value')

    ax4.plot(word4_data[100:])
    ax4.set_title('Motor 2')
    ax4.set_xlabel('Sample')
    ax4.set_ylabel('Value')

    plt.tight_layout()
    ser.close()
    plt.show()

except KeyboardInterrupt:
    print("Stopping...")
finally:
    ser.close()