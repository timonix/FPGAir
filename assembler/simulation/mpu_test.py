import pytest
from assembler.simulation.simBa_test import ASSEMBLER_DIR
from mpu6050Sim import mpu6060Sim
from SimBa import BeagleSim

# $GYRO_X_RAW = b1000000
# $GYRO_Y_RAW = b1000001
# $GYRO_Z_RAW = b1000010
# $ACC_X_RAW = b1000011
# $ACC_Y_RAW = b1000100
# $ACC_Z_RAW = b1000101

# $VECTOR_X = 40
# $VECTOR_Y = 41
# $VECTOR_Z = 42

# $VECTOR_NEXT_X = 43
# $VECTOR_NEXT_Y = 44
# $VECTOR_NEXT_Z = 45

GYRO_X_RAW_REG = 64
GYRO_Y_RAW_REG = 65
GYRO_Z_RAW_REG = 66
ACC_X_RAW_REG  = 67
ACC_Y_RAW_REG  = 68
ACC_Z_RAW_REG  = 69
VECTOR_X_REG = 40
VECTOR_Y_REG = 41
VECTOR_Z_REG = 42
VECTOR_NEXT_X_REG = 43
VECTOR_NEXT_Y_REG = 44
VECTOR_NEXT_Z_REG = 45

# $GYRO_X = 32
# $GYRO_Y = 33
# $GYRO_Z = 34
# $ACC_X = 35
# $ACC_Y = 36
# $ACC_Z = 37

GYRO_X_REG = 32
GYRO_Y_REG = 33
GYRO_Z_REG = 34
ACC_X_REG = 35
ACC_Y_REG = 36
ACC_Z_REG = 37

@pytest.fixture
def sim():
    sim = BeagleSim(
        output_file_path=ASSEMBLER_DIR / "output.rom",
        metadata_file_path=ASSEMBLER_DIR / "metadata.txt",
        ram_file_path=ASSEMBLER_DIR / "ram.ram",
        instruction_map_path=ASSEMBLER_DIR / "instruction_map.csv",
    )        
    sim.run_program("BOOT")
    return sim


@pytest.fixture
def mpu():
    return mpu6060Sim()


def check_mpu_memory_for_none(sim : BeagleSim):
    assert sim.memory[GYRO_X_RAW_REG] is not None, "GYRO_X_RAW_REG is None"
    assert sim.memory[GYRO_Y_RAW_REG] is not None, "GYRO_Y_RAW_REG is None"
    assert sim.memory[GYRO_Z_RAW_REG] is not None, "GYRO_Z_RAW_REG is None"
    assert sim.memory[ACC_X_RAW_REG] is not None, "ACC_X_RAW_REG is None"
    assert sim.memory[ACC_Y_RAW_REG] is not None, "ACC_Y_RAW_REG is None"
    assert sim.memory[ACC_Z_RAW_REG] is not None, "ACC_Z_RAW_REG is None"
    assert sim.memory[VECTOR_X_REG] is not None, "VECTOR_X_REG is None"
    assert sim.memory[VECTOR_Y_REG] is not None, "VECTOR_Y_REG is None"
    assert sim.memory[VECTOR_Z_REG] is not None, "VECTOR_Z_REG is None"
    assert sim.memory[VECTOR_NEXT_X_REG] is not None, "VECTOR_NEXT_X_REG is None"
    assert sim.memory[VECTOR_NEXT_Y_REG] is not None, "VECTOR_NEXT_Y_REG is None"
    assert sim.memory[VECTOR_NEXT_Z_REG] is not None, "VECTOR_NEXT_Z_REG is None"


@pytest.mark.parametrize("t, expected", [
    (0, (4915, 3276, 16384, 0, 0, 0)),
    (1, (4905, 3272, 16384, 19, -29, 0)),
    (2, (4875, 3264, 16384, 38, -58, 0)),
    (3, (4825, 3252, 16384, 57, -87, 0)),
    (4, (4755, 3236, 16384, 76, -116, 0)),
])
def test_get_value_at_time(t, expected):
    my_sim = mpu6060Sim(L=1.0, ax0=0.3, ay0=0.2)
    values = my_sim.getValuesAtTime(t)
    assert values == expected



def test_rotation(sim : BeagleSim, mpu : mpu6060Sim):
    mpu.pendulum(L=1.0, ax0=0.0, ay0=0.0)
    time_range = [0]


    for i in range(10000):
        t = 0
        sim.memory[ACC_X_RAW_REG] = mpu.getValuesAtTime(t)[0]
        sim.memory[ACC_Y_RAW_REG] = mpu.getValuesAtTime(t)[1]
        sim.memory[ACC_Z_RAW_REG] = mpu.getValuesAtTime(t)[2]
        sim.memory[GYRO_X_RAW_REG] = mpu.getValuesAtTime(t)[3]
        sim.memory[GYRO_Y_RAW_REG] = mpu.getValuesAtTime(t)[4]
        sim.memory[GYRO_Z_RAW_REG] = mpu.getValuesAtTime(t)[5]

        sim.run_program("SCALE_BIAS_MPU")
        sim.run_program("ROTATE_VECTOR")

        check_mpu_memory_for_none(sim)

    print(sim.memory[ACC_X_REG])
    print(sim.memory[ACC_Y_REG])
    print(sim.memory[ACC_Z_REG])