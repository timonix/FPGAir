import pytest
from mpu6050Sim import mpu6060Sim

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




def test_mpu():
    assert 1 == 2