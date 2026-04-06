# SCope creep:
# Realistic start values
# Check register contents
# Log?
# Send input in test case?
# Test cases in general?
#


# 128 memory area - 0-127
# A, B, X, Res, Ram registers
# PC - program counter

# MIRO - Master In RAM Out - 
# MORI - 

from pathlib import Path
import csv
from dataclasses import dataclass

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
        self.read_files(output_file_path, metadata_file_path, ram_file_path, instruction_map_path)
        
        self.RAM_reg_in = None
        self.RAM_reg_out = None
        self.RES_reg = None
        self.A_reg = None
        self.B_reg = None
        self.X_reg = None

        self.addr = None

        self.memory = [None] * 128

        self.PC = None


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
                self.ram_lines[i] = line.replace("\n", "")

        with open(instruction_map_path, newline='', encoding="utf-8") as f:
            self.instruction_map = {}
            instruction_map_file = csv.reader(f)
            for row in instruction_map_file:
                if len(row) < 2:
                    continue
                binary, command = row[0].strip(), row[1].strip().upper()
                self.instruction_map[binary] = command


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

        elif op == "NEG_X":
            self.X_reg = -self.X_reg

        elif op == "NEG_RES":
            self.RES_reg = -self.RES_reg

        elif op == "NEG_RAM":
            self.RAM_reg_in = -self.RAM_reg_in if self.RAM_reg_in is not None else None

        elif op == "MOV A A":
            self.A_reg = self.A_reg
        elif op == "MOV A B":
            self.A_reg = self.B_reg
        elif op == "MOV A X":
            self.A_reg = self.X_reg
        elif op == "MOV A RAM":
            self.A_reg = self.RAM_reg_out
        elif op == "MOV A RES":
            self.A_reg = self.RES_reg

        elif op == "MOV B A":
            self.B_reg = self.A_reg
        elif op == "MOV B B":
            self.B_reg = self.B_reg
        elif op == "MOV B X":
            self.B_reg = self.X_reg
        elif op == "MOV B RAM":
            self.B_reg = self.RAM_reg_out
        elif op == "MOV B RES":
            self.B_reg = self.RES_reg

        elif op == "MOV X A":
            self.X_reg = self.A_reg
        elif op == "MOV X B":
            self.X_reg = self.B_reg
        elif op == "MOV X X":
            self.X_reg = self.X_reg
        elif op == "MOV X RAM":
            self.X_reg = self.RAM_reg_out
        elif op == "MOV X RES":
            self.X_reg = self.RES_reg

        elif op == "MOV RAM A":
            self.RAM_reg_in = self.A_reg
        elif op == "MOV RAM B":
            self.RAM_reg_in = self.B_reg
        elif op == "MOV RAM X":
            self.RAM_reg_in = self.X_reg
        elif op == "MOV RAM RAM":
            self.RAM_reg_in = self.RAM_reg_out
        elif op == "MOV RAM RES":
            self.RAM_reg_in = self.RES_reg

        elif op == "MOV RES A":
            self.RES_reg = self.A_reg
        elif op == "MOV RES B":
            self.RES_reg = self.B_reg
        elif op == "MOV RES X":
            self.RES_reg = self.X_reg
        elif op == "MOV RES RAM":
            self.RES_reg = self.RAM_reg_out
        elif op == "MOV RES RES":
            self.RES_reg = self.RES_reg

        elif op == "MOV ZERO A":
            self.A_reg = 0
        elif op == "MOV ZERO B":
            self.B_reg = 0
        elif op == "MOV ZERO X":
            self.X_reg = 0
        elif op == "MOV ZERO RAM":
            self.RAM_reg_in = 0
        elif op == "MOV ZERO RES":
            self.RES_reg = 0

        elif op == "MOV ONE A":
            self.A_reg = 1
        elif op == "MOV ONE B":
            self.B_reg = 1
        elif op == "MOV ONE X":
            self.X_reg = 1
        elif op == "MOV ONE RAM":
            self.RAM_reg_in = 1
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

            except Exception as e:
                print(f"Error in program code in line: {self.PC}")
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
    
    print(simba.run_program(0))