# Assume the PIDController class has been defined as before
import math
class PIDController:
    def __init__(self, Kp, Ki, Kd, setpoint=0.0):
        self.Kp = Kp  # Proportional gain
        self.Ki = Ki  # Integral gain
        self.Kd = Kd  # Derivative gain
        self.setpoint = setpoint  # Desired target value

        self.clear()

    def clear(self):
        self.P_term = 0.0  # Proportional term
        self.I_term = 0.0  # Integral term
        self.D_term = 0.0  # Derivative term

        self.last_error = 0.0  # Error at previous step
        self.output = 0.0  # Controller output

    def update(self, feedback_value):
        error = self.setpoint - feedback_value
        delta_error = error - self.last_error

        self.P_term = self.Kp * error
        self.I_term = self.I_term + self.Ki * error
        self.D_term = self.Kd * delta_error

        # Compute the final output
        self.output = self.P_term + self.I_term + self.D_term

        # Update last error
        self.last_error = error

        return self.output

    def set_setpoint(self, setpoint):
        self.setpoint = setpoint

    def set_tunings(self, Kp, Ki, Kd):
        self.Kp = Kp
        self.Ki = Ki
        self.Kd = Kd


# Initialize PID controller
pid = PIDController(Kp=2.0, Ki=0.1, Kd=1.0, setpoint=100.0)

# Assuming the PIDController class is already defined as provided earlier

# Time step
delta_time = 1.0  # Time interval between each update

# Number of time steps for the simulation
num_steps = 20

# Lists to store inputs and outputs
setpoint_list = []
measured_value_list = []
output_list = []

# Initial measured value
measured_value = 0.0

# Simulate process
for step in range(num_steps):
    # Setpoint can be constant or vary over time; here it's constant
    setpoint = 100
    pid.set_setpoint(setpoint)
    setpoint_list.append(setpoint)

    # Simulate measured value (for demonstration purposes)
    # In a real scenario, this would come from sensors or process feedback
    measured_value += 5.0  # Simulate a process that increases over time
    measured_value_list.append(measured_value)

    # Update the PID controller with the current measured value
    output = pid.update(feedback_value=measured_value)
    output_list.append(output)

# Print the results
print("Time Step\tSetpoint\tMeasured Value\tPID Output")
for i in range(num_steps):
    print(f"{i},{setpoint_list[i]:.2f},{measured_value_list[i]:.2f},{output_list[i]:.2f},")
