import serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from matplotlib.widgets import TextBox
from collections import deque

#ser = serial.Serial('COM4', 115200, timeout=1)

class FPGAir_Plotter():

    serial_port = 'COM4'

    update_interval = 0.1

    pid_input = 0
    pid_signal = 0

    num_lines = 6

    def __init__(self):

        self.serial_connect()

        self.fig, self.ax = plt.subplot()

        text_box_position = plt.axes([0.12, 0.05, 0.8, 0.075])
        text_box = TextBox(text_box_position, 'PID Target')
        text_box.on_submit(self.submit)

        # Create the animation
        ani = animation.FuncAnimation(self.fig, self.update_plot, init_func=self.plot_init, blit=True, interval=0.1)
    
    def plot_init(self):
        self.ax.set_xlim(0, 100)  # Adjust x-axis limits
        self.ax.set_ylim(-1000, 1000)  # Adjust y-axis limits for your data range
        data_queues = [deque(maxlen=100) for _ in range(self.num_lines)]  # List of deques, one for each line
        lines = [self.ax.plot([], [])[0] for _ in range(self.num_lines)]  # List of line objects
        return lines

    def run(self):
        pass

    def submit(self):
        pass

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

    def send_serial_data(self):
        pass
 
    def update_plot(self):
        # Clear previous plot
        #plot.clear()

        self.ax.plot()

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
fpgair_plotter.run()

