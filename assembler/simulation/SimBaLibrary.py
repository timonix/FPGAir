from SimBa import Word, BeagleSim
from mpu6050Sim import mpu6060Sim


class SimBaLibrary:
    def create_word_from_float(self, value, frac_bits=20, ram_bits=32):
        """Convert a float to the simulator fixed-point Word representation."""
        return Word.word_from_float(float(value), int(frac_bits), int(ram_bits)).value

    def run_instruction_and_return_error(self, instruction):
        """Run a single instruction and return the error message or OK."""
        sim = self._make_minimal_sim()
        result = sim.run_instruction(str(instruction))
        return result.error or "OK"

    def run_instruction_and_return_status(self, instruction):
        """Run a single instruction and return OK, FINISHED, or ERROR."""
        sim = self._make_minimal_sim()
        result = sim.run_instruction(str(instruction))
        if result.program_finished:
            return "FINISHED"
        if result.error:
            return f"ERROR: {result.error}"
        return "OK"
    
    def get_value_at_time(self, t):
        """Get the simulated sensor values at time t."""
        sim = mpu6060Sim(L=1.0, ax0=0.3, ay0=0.2)
        return sim.getValuesAtTime(float(t))
