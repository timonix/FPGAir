import cocotb
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory
from cocotb.result import TestFailure
from cocotb.binary import BinaryValue

@cocotb.coroutine
def mixer_basic_test(dut):
    """ Basic test for the mixer """

    # Reset
    dut.rst <= 1
    dut.enable <= 0
    yield RisingEdge(dut.clk)
    dut.rst <= 0

    # Set inputs
    dut.enable <= 1
    dut.throttle_i <= BinaryValue("0000000000000")  # Example value
    dut.roll_pid_i <= BinaryValue("0000000000000")
    dut.pitch_pid_i <= BinaryValue("0000000000000")
    dut.yaw_pid_i <= BinaryValue("0000000000000")

    # Wait for a rising edge on the clock
    yield RisingEdge(dut.clk)

    # Check the outputs
    if dut.motor1_signal_o.value != "0000000000000":  # Replace expected_value with the correct one
        raise TestFailure("Motor1 signal output not as expected")

# Register the test
factory = TestFactory(mixer_basic_test)
factory.generate_tests()