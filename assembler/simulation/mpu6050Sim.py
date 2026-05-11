import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation


import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation


class mpu6060Sim:
    Xaxis = 0
    Yaxis = 1

    ACC_SCALE = 16384.0   # LSB/g
    GYRO_SCALE = 131.0    # LSB/(deg/s)

    def __init__(self, g=9.81):
        self.g = g
        self.mode = "idle"
        self.sweeps = []
        self.total_duration = 0.0

        self.L = 1.0
        self.ax0 = 0.0
        self.ay0 = 0.0
        self.w = np.sqrt(self.g / self.L)

    def pendulum(self, L=1.0, ax0=0.3, ay0=0.2):
        """Old behavior. Angles are in radians."""
        self.mode = "pendulum"
        self.L = L
        self.ax0 = ax0
        self.ay0 = ay0
        self.w = np.sqrt(self.g / L)
        self.sweeps.clear()
        self.total_duration = 0.0
        return self

    def sweep(self, axis, start_angle, stop_angle, start_time, stop_time):
        """
        Add an overlapping sweep.

        Angles are degrees.
        Times are seconds.
        """
        self.mode = "sweep"

        duration = stop_time - start_time
        if duration <= 0:
            raise ValueError("stop_time must be greater than start_time")

        self.sweeps.append({
            "axis": axis,
            "start": np.radians(start_angle),
            "stop": np.radians(stop_angle),
            "t0": float(start_time),
            "t1": float(stop_time),
            "duration": float(duration),
        })

        self.total_duration = max(self.total_duration, float(stop_time))
        return self

    def _smooth_sweep(self, u, start, stop, duration):
        """
        Smooth cubic sweep:
        position starts and ends with zero velocity.
        """
        delta = stop - start

        s = 3*u**2 - 2*u**3
        ds = 6*u - 6*u**2
        dds = 6 - 12*u

        angle = start + delta * s
        omega = delta * ds / duration
        alpha = delta * dds / duration**2

        return angle, omega, alpha

    def _state_pendulum(self, t):
        ax = self.ax0 * np.cos(self.w * t)
        ay = self.ay0 * np.cos(self.w * t)

        wx = -self.ax0 * self.w * np.sin(self.w * t)
        wy = -self.ay0 * self.w * np.sin(self.w * t)

        alphax = -self.w**2 * ax
        alphay = -self.w**2 * ay

        return ax, ay, wx, wy, alphax, alphay

    def _state_sweep(self, t):
        ax = ay = 0.0
        wx = wy = 0.0
        alphax = alphay = 0.0

        for sw in self.sweeps:
            axis = sw["axis"]

            if t < sw["t0"]:
                continue

            if t > sw["t1"]:
                angle = sw["stop"]
                omega = 0.0
                alpha = 0.0
            else:
                u = (t - sw["t0"]) / sw["duration"]
                angle, omega, alpha = self._smooth_sweep(
                    u,
                    sw["start"],
                    sw["stop"],
                    sw["duration"]
                )

            # Overlapping sweeps are additive
            if axis == self.Xaxis:
                ax += angle
                wx += omega
                alphax += alpha
            elif axis == self.Yaxis:
                ay += angle
                wy += omega
                alphay += alpha

        return ax, ay, wx, wy, alphax, alphay

    def _state(self, t):
        if self.mode == "pendulum":
            return self._state_pendulum(t)
        elif self.mode == "sweep":
            return self._state_sweep(t)
        else:
            return 0, 0, 0, 0, 0, 0

    def getValuesAtTime(self, t):
        ax, ay, wx, wy, alphax, alphay = self._state(t)

        # Accelerometer in g
        acc_x = self.L * alphax / self.g
        acc_y = self.L * alphay / self.g
        acc_z = 1.0 + self.L * (wx**2 + wy**2) / self.g

        # Gyro in deg/s
        gyro_x = np.degrees(wy)
        gyro_y = np.degrees(-wx)
        gyro_z = 0.0

        return (
            int(acc_x * self.ACC_SCALE),
            int(acc_y * self.ACC_SCALE),
            int(acc_z * self.ACC_SCALE),
            int(gyro_x * self.GYRO_SCALE),
            int(gyro_y * self.GYRO_SCALE),
            int(gyro_z * self.GYRO_SCALE),
        )

    def drawGraphs(self, t0=0, t1=None, n=1000):
        if t1 is None:
            t1 = self.total_duration if self.mode == "sweep" else 5

        t = np.linspace(t0, t1, n)
        data = np.array([self.getValuesAtTime(tt) for tt in t])

        names = ["acc_x", "acc_y", "acc_z", "gyro_x", "gyro_y", "gyro_z"]

        plt.figure(figsize=(10, 8))
        for i in range(6):
            plt.subplot(6, 1, i + 1)
            plt.plot(t, data[:, i])
            plt.ylabel(names[i])
            plt.grid()

        plt.xlabel("time (s)")
        plt.tight_layout()
        plt.show()

    def animate(self, t0=0, t1=None, frames=200):
        if t1 is None:
            t1 = self.total_duration if self.mode == "sweep" else 5

        t = np.linspace(t0, t1, frames)

        fig = plt.figure()
        ax3d = fig.add_subplot(111, projection="3d")

        ax3d.set_xlim(-1, 1)
        ax3d.set_ylim(-1, 1)
        ax3d.set_zlim(-1, 0)

        line, = ax3d.plot([], [], [], marker="o")

        def update(i):
            axang, ayang, *_ = self._state(t[i])

            x = self.L * np.sin(axang)
            y = self.L * np.sin(ayang)

            z_sq = self.L**2 - x**2 - y**2
            z = np.sqrt(max(z_sq, 0.0))

            line.set_data([0, x], [0, y])
            line.set_3d_properties([0, -z])
            return line,

        anim = FuncAnimation(fig, update, frames=frames, interval=20)
        plt.show()
        return anim
    
def main():
    my_sim = mpu6060Sim(g=9.81)

    my_sim.sweep(mpu6060Sim.Xaxis, 0, 90, start_time=0, stop_time=5)
    #my_sim.sweep(mpu6060Sim.Yaxis, -45, 45, start_time=0, stop_time=5)

    print(my_sim.getValuesAtTime(2.5))
    print(my_sim.getValuesAtTime(6.0))

    my_sim.drawGraphs()
    my_sim.animate()

if __name__ == "__main__":    
    main()