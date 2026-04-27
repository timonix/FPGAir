import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation


class mpu6060Sim:
    ACC_SCALE = 16384.0   # LSB/g
    GYRO_SCALE = 131.0    # LSB/(deg/s)

    def __init__(self, L=1.0, ax0=0.3, ay0=0.2, g=9.81):
        self.L = L
        self.ax0 = ax0   # initial angle x (rad)
        self.ay0 = ay0   # initial angle y (rad)
        self.g = g
        self.w = np.sqrt(g / L)

    def _state(self, t):
        # simple 2-axis harmonic motion
        x = self.ax0 * np.cos(self.w * t)
        y = self.ay0 * np.cos(self.w * t)

        vx = -self.ax0 * self.w * np.sin(self.w * t)
        vy = -self.ay0 * self.w * np.sin(self.w * t)

        ax = -self.w**2 * x
        ay = -self.w**2 * y

        z = np.sqrt(self.L**2 - x**2 - y**2)

        return x, y, z, vx, vy, ax, ay

    def getValuesAtTime(self, t):
        x, y, z, vx, vy, ax, ay = self._state(t)

        # accelerometer (in g)
        acc_x = ax / self.g
        acc_y = ay / self.g
        acc_z = (vx**2 + vy**2) / self.g + 1.0  # radial + gravity

        # gyro (deg/s)
        gyro_x = np.degrees(vy / self.L)
        gyro_y = np.degrees(-vx / self.L)
        gyro_z = 0.0

        # convert to raw int16
        return (
            int(acc_x * self.ACC_SCALE),
            int(acc_y * self.ACC_SCALE),
            int(acc_z * self.ACC_SCALE),
            int(gyro_x * self.GYRO_SCALE),
            int(gyro_y * self.GYRO_SCALE),
            int(gyro_z * self.GYRO_SCALE),
        )

    # -------- helpers --------

    def drawGraphs(self, t0=0, t1=5, n=1000):
        t = np.linspace(t0, t1, n)
        data = np.array([self.getValuesAtTime(tt) for tt in t])

        names = ["acc_x", "acc_y", "acc_z", "gyro_x", "gyro_y", "gyro_z"]

        plt.figure(figsize=(10, 8))
        for i in range(6):
            plt.subplot(6, 1, i+1)
            plt.plot(t, data[:, i])
            plt.ylabel(names[i])
            plt.grid()

        plt.xlabel("time (s)")
        plt.tight_layout()
        plt.show()

    def animate(self, t0=0, t1=5, frames=200):
        t = np.linspace(t0, t1, frames)

        fig = plt.figure()
        ax = fig.add_subplot(111, projection="3d")

        ax.set_xlim(-1, 1)
        ax.set_ylim(-1, 1)
        ax.set_zlim(-1, 0)

        line, = ax.plot([], [], [], marker="o")

        def update(i):
            x, y, z, *_ = self._state(t[i])
            line.set_data([0, x], [0, y])
            line.set_3d_properties([0, -z])
            return line,

        anim = FuncAnimation(fig, update, frames=frames, interval=20)
        plt.show()
        return anim
    
def main():
    sim = mpu6060Sim(L=1.0, ax0=0.3, ay0=0.2)
    sim.drawGraphs()
    sim.animate()

if __name__ == "__main__":    
    main()