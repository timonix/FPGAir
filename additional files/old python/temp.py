import serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import tkinter as tk
from tkinter import ttk
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg


#ser = serial.Serial('COM4', 115200, timeout=1)

class FPGAir_Plotter():

    serial_port = 'COM4'

    update_interval = 0.1

    pid_input = 0
    pid_signal = 0

    def __init__(self):

        self.serial_connect()

        # Create main window
        self.root = tk.Tk()
        self.root.title("PID tester")

        # Create a frame for the menu
        self.menu_frame = tk.Frame(self.root, width=200, bg='lightgrey')
        self.menu_frame.pack(side=tk.LEFT,  fill=tk.Y)

        # Create a frame for the plots
        self.plot_frame = tk.Frame(self.root)
        self.plot_frame.pack(side=tk.RIGHT)

        # Create a label for the menu
        self.label = tk.Label(self.menu_frame, text="Menu", bg='lightgrey', font=('Helvetica', 12, 'bold'))
        self.label.grid(column=0, row=0)

        # PID Input
        self.label = tk.Label(self.menu_frame, text="PID Input", bg='lightgrey', font=('Helvetica', 10, 'bold'))
        self.label.grid(column=0, row=1)
        self.pid_input_entry = tk.Entry(self.menu_frame)
        self.pid_input_entry.grid(column=0, row=2)
        # Create a button to send pid data
        self.pid_button = ttk.Button(self.menu_frame, text="Send", command=self.send_pid_value)
        self.pid_button.grid(column=0, row=3)

        # Initialize update loop
        self.root.after(self.update_interval, self.update)

    def update(self):
        print("Updating...")
        #self.read_serial_data()
        #self.plot_graph()
        self.root.after(self.update_interval, self.update)

    def serial_connect(self):
        try:
            self.ser = serial.Serial(self.serial_port, 115200, timeout=1)
        except Exception as e:
            print(f"Cant connect to serial port: {e}")

    def read_serial_data(self):
        try:
            if self.ser.in_waiting > 0:
                raw_data = self.ser.read(1)
                delimiter = int.from_bytes(raw_data, byteorder='little')
                if chr(delimiter) == 'D':

                    raw_data = self.ser.read(2)
                    self.pid_signal = int.from_bytes(raw_data, byteorder='big')
                    #if self.pid_signal > 16384:
                    #    self.pid_signal = -(32768-self.pid_signal)
        except:
            print("Error when reading serial data")
 
    def plot_graph(self):
        # Clear previous plot
        #plot.clear()

        # Plot the updated data
        #plot.plot(x, y, color='lightblue', linewidth=3)
        #plot.set_title('Animated Plot')
        #plot.set_xlabel('X-axis')
        #plot.set_ylabel('Y-axis')

        # Display the plot on canvas
        #canvas = FigureCanvasTkAgg(fig, master=plot_frame)
        #canvas.draw()
        #anvas.get_tk_widget().pack(side=tk.TOP, fill=tk.BOTH, expand=True)
        pass

    def send_pid_value(self):
        pass

fpgair_plotter = FPGAir_Plotter()
# Run the application
fpgair_plotter.root.mainloop()


