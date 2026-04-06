# ----- Scope creep -----
# Realistic start values
# Check register contents
# Log?
# Send input in test case?
# Test cases in general?

# 128 memory area - 0-127
# A, B, X, Res, Ram registers
# PC - program counter

# TODO: Troubleshoot: printout of Gyro not working.
# TODO: Add log of all the executed instructions and register/memory changes for debugging purposes. Maybe also add a "verbose" mode that prints this log to the console.
# TODO: Make it possible to insert pre-set hardware data into the memory before running the program, to simulate sensor input. Maybe also add a "test case" mode that runs a predefined set of test cases with expected outputs for easier debugging.
# TODO: Add a happy and sad Simba face at the end of the program to indicate success or failure of the program execution, based on whether it halts successfully or encounters an error.

from pathlib import Path
import csv
from dataclasses import dataclass

@dataclass
class Word():
    value : int
    
    def word_from_bin_string(bin_str):
        return Word(int(bin_str, 2) if bin_str[0] == '0' else int(bin_str, 2) - (1 << len(bin_str)))
    
    def word_from_float(value, frac_bits=20, ram_bits=32):
        scaled_value = int(round(value * (1 << frac_bits)))
        mask = (1 << ram_bits) - 1
        fixed_val = scaled_value & mask
        return Word(fixed_val)
    
    def __str__(self):
        return str(self.value/2**20)
    
    def __mul__(self, other):
        return Word((self.value * other.value) >> 20)
    
    def __add__(self, other):
        return Word(self.value + other.value)
    
    def __neg__(self):
        return Word(-self.value)
    

@dataclass
class InstructionResult():
    program_finished : bool = False
    error : str | None = None
    
    @staticmethod
    def success():
        return InstructionResult(program_finished=False, error=None)
    
    @staticmethod
    def finished():
        return InstructionResult(program_finished=True, error=None)

    @staticmethod
    def failed(error_message):
        return InstructionResult(program_finished=False, error=error_message)


class SimBa():

    def __init__(self, output_file_path, metadata_file_path, ram_file_path, instruction_map_path):
        self.RES_reg = None
        self.A_reg = None
        self.B_reg = None
        self.X_reg = None

        self.addr = None

        self.memory = [None] * 128

        self.PC = None
        
        self.read_files(output_file_path, metadata_file_path, ram_file_path, instruction_map_path)


    def read_files(self, output_file_path, metadata_file_path, ram_file_path, instruction_map_path):
        with open(output_file_path, "r", encoding="utf-8") as f:
            self.output_lines = f.readlines()
            for i, line in enumerate(self.output_lines):
                self.output_lines[i] = line.replace("\n", "")

        with open(metadata_file_path, "r", encoding="utf-8") as f:
            self.metadata_lines = f.readlines()
            # TODO: clean up and create a metadata list referred to by name

        with open(ram_file_path, "r", encoding="utf-8") as f:
            self.ram_lines = f.readlines()
            for i, line in enumerate(self.ram_lines):
                self.memory[i] = Word.word_from_bin_string(line.replace("\n", ""))

            

        with open(instruction_map_path, newline='', encoding="utf-8") as f:
            self.instruction_map = {}
            instruction_map_file = csv.reader(f)
            for row in instruction_map_file:
                if len(row) < 2:
                    continue
                binary, command = row[0].strip(), row[1].strip().upper()
                self.instruction_map[binary] = command

    def uart_print(self, address):
        if address == int('1111111', 2):
            print(f"UART Output: {self.memory[address]}")

    def run_instruction(self, instruction) -> InstructionResult:
        
        # Must be an 8-bit binary string
        if not isinstance(instruction, str):
            return InstructionResult.failed(error="Error: Input not a string")

        instruction = instruction.strip()

        if len(instruction) != 8 or any(bit not in "01" for bit in instruction):
            return InstructionResult.failed(error="Error: Wrong length or not binary")

        # LD: top bit indicates load-address, lower 7 bits are the address
        if instruction[0] == "1":
            self.addr = int(instruction[1:], 2)
            return InstructionResult.success()

        # Look up instruction name from preloaded map
        op = self.instruction_map.get(instruction)
        if op is None:
            return InstructionResult.failed(error="Error: Instruction not found in list")

        if op == "HALT":
            return InstructionResult.finished()

        elif op == "NOP":
            return InstructionResult.success()

        elif op == "MULADD":
            self.RES_reg = self.A_reg * self.B_reg + self.X_reg

        elif op == "NEG_A":
            self.A_reg = -self.A_reg

        elif op == "NEG_B":
            self.B_reg = -self.B_reg

        elif op == "MOV A A":
            self.A_reg = self.A_reg
        elif op == "MOV A B":
            self.A_reg = self.B_reg
        elif op == "MOV A X":
            self.A_reg = self.X_reg
        elif op == "MOV A RAM":
            self.memory[self.addr] = self.A_reg
            self.uart_print(self.addr)
        elif op == "MOV A RES":
            self.A_reg = self.RES_reg

        elif op == "MOV B A":
            self.B_reg = self.A_reg
        elif op == "MOV B B":
            self.B_reg = self.B_reg
        elif op == "MOV B X":
            self.B_reg = self.X_reg
        elif op == "MOV B RAM":
            self.memory[self.addr] = self.B_reg
            self.uart_print(self.addr)
        elif op == "MOV B RES":
            self.B_reg = self.RES_reg

        elif op == "MOV X A":
            self.X_reg = self.A_reg
        elif op == "MOV X B":
            self.X_reg = self.B_reg
        elif op == "MOV X X":
            self.X_reg = self.X_reg
        elif op == "MOV X RAM":
            self.memory[self.addr] = self.X_reg
            self.uart_print(self.addr)
        elif op == "MOV X RES":
            self.X_reg = self.RES_reg

        elif op == "MOV RAM A":
            self.A_reg = self.memory[self.addr]
        elif op == "MOV RAM B":
            self.B_reg = self.memory[self.addr]
        elif op == "MOV RAM X":
            self.X_reg = self.memory[self.addr] 
        elif op == "MOV RAM RAM":
            self.memory[self.addr] = self.memory[self.addr]
            self.uart_print(self.addr)
        elif op == "MOV RAM RES":
            self.memory[self.addr] = self.RES_reg

        elif op == "MOV RES A":
            self.RES_reg = self.A_reg
        elif op == "MOV RES B":
            self.RES_reg = self.B_reg
        elif op == "MOV RES X":
            self.RES_reg = self.X_reg
        elif op == "MOV RES RAM":
            self.memory[self.addr] = self.RES_reg  
            self.uart_print(self.addr)          
        elif op == "MOV RES RES":
            self.RES_reg = self.RES_reg

        elif op == "MOV ZERO A":
            self.A_reg = 0
        elif op == "MOV ZERO B":
            self.B_reg = 0
        elif op == "MOV ZERO X":
            self.X_reg = 0
        elif op == "MOV ZERO RAM":
            self.memory[self.addr] = 0
            self.uart_print(self.addr)
        elif op == "MOV ZERO RES":
            self.RES_reg = 0

        elif op == "MOV ONE A":
            self.A_reg = 1
        elif op == "MOV ONE B":
            self.B_reg = 1
        elif op == "MOV ONE X":
            self.X_reg = 1
        elif op == "MOV ONE RAM":
            self.memory[self.addr] = 1
            self.uart_print(self.addr)
        elif op == "MOV ONE RES":
            self.RES_reg = 1

        else:
            return InstructionResult.failed(error="Error: No instruction case executed")

        return InstructionResult.success()


    def run_program(self, program_address):
        print(f"Running program with address: {program_address}")
        self.PC = program_address

        while True:
            program_instruction = self.output_lines[self.PC]
            try:
                result = self.run_instruction(program_instruction)
                self.PC = self.PC + 1

                if result.program_finished:
                    break

            except Exception as e:
                print(f"Error in program code in line {self.PC}. Error: {e}")
                break

if __name__ == "__main__":

    BASE_DIR = Path(__file__).parent

    output_file_path = BASE_DIR / "output.rom"
    metadata_file_path = BASE_DIR / "metadata.txt"
    ram_file_path = BASE_DIR / "ram.ram"
    instruction_map_path = BASE_DIR / "instruction_map.csv"

    simba = SimBa(output_file_path=output_file_path, 
                  metadata_file_path=metadata_file_path, 
                  ram_file_path=ram_file_path,
                  instruction_map_path=instruction_map_path)
    
    simba.run_program(0)
    simba.run_program(64)
    simba.run_program(32)
    simba.run_program(14)


    # for i in simba.memory:
    #     print(i)
    # print(simba.memory[2])