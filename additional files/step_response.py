import control as ctrl
import matplotlib.pyplot as plt
import numpy as np

# Transfer function of the PID controller
# Transfer function of the PID controller
Kp = 1
Ki = 1
Kd = 0
pid_tf = ctrl.TransferFunction([Kd, Kp, Ki], [0, 1])


# Transfer function of the system
numerator = [1]
denominator = [1, 2, 1]  # Second-order system with poles at -1
sys_tf = ctrl.TransferFunction(numerator, denominator)

# Time range for simulation
time = np.linspace(0, 10, 1000)  # 0 to 10 seconds, 1000 points

# Get step responses
time, pid_response = ctrl.step_response(pid_tf, T=time)
time, sys_response = ctrl.step_response(sys_tf, T=time)

# Plotting the step responses
plt.figure(figsize=(10, 6))

#plt.subplot(2, 1, 1)
plt.plot(time, pid_response, label='PID Controller')
plt.plot(time, sys_response, label='System')
plt.title('Step Response of PID Controller')
plt.xlabel('Time')
plt.ylabel('Response')
plt.legend()
plt.grid()

plt.ylim(0, 1)

plt.tight_layout()
plt.show()
