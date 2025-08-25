import csv
import sys
from pathlib import Path
from decimal import Decimal

BASE_DIR = Path(__file__).parent
variable_dict = {}
instruction_mapping = {}
ram_dict = {}

def load_instruction_map(csv_file):
    
    mapping = {}
    with open(csv_file, newline='', encoding="utf-8") as f:
        reader = csv.reader(f)
        for row in reader:
            if len(row) < 2:
                continue
            binary, command = row[0].strip(), row[1].strip().upper()
            mapping[command] = binary
    return mapping

def create_RAM_file(input_file, ram_file):
    with open(input_file, "r", encoding="utf-8") as f:
        lines = f.readlines()

    ram_lines = []
    address_counter = 0

    for line in lines:
        if line.startswith("LD "):
            dummy, value = line.split('$')
            value_bin = format(int(value.strip()), "032b")    # TODO: Convert float to binary with correct fractionals
            ram_dict[value_bin] = address_counter
            address_counter += 1
            ram_lines.append(value_bin)

    with open(ram_file, "w", encoding="utf-8") as f:
        f.write("\n".join(ram_lines))
        

def read_variables(input_file):
    with open(input_file, "r", encoding="utf-8") as f:
        lines = f.readlines()
    
    for line in lines:
        if line.startswith("$"):
            name, value = line.split('=')
            name = name.strip()
            value_bin = format(int(value.strip()), "08b")
            variable_dict[name] = value_bin

def assemble(input_file, output_file):
   
    with open(input_file, "r", encoding="utf-8") as f:
        lines = f.readlines()

    output_lines = []
    for line in lines:
        line = line.strip()
        if not line or line.startswith("//"):  # skip empty/comment lines
            continue
        # if line in instruction_mapping:

        instruction_bin_str = instruction_assembler(line)
        if instruction_bin_str:
            output_lines.append(instruction_bin_str)
        # else:
        #     print(f"⚠️ Unknown incantation: {line}")
        #     output_lines.append("????????")  # placeholder

    with open(output_file, "w", encoding="utf-8") as f:
        f.write("\n".join(output_lines))

def instruction_assembler(instruction : str):

    if instruction in instruction_mapping:
        return instruction_mapping[instruction]

    if "LDADDR" in instruction:
        instruction_name, variable_name = instruction.split(" ")
        instruction_name.strip()
        variable_name.strip()
        bin_instr = int(instruction_mapping[instruction_name], 2)
        bin_value = int(variable_dict[variable_name], 2)
        return bin(bin_instr | bin_value)[2:]
    
    elif "LD " in instruction:
        instruction_name, value = instruction.split("$")
        value.strip()
        value = format(int(value), "032b")
        bin_instr = int(instruction_mapping["LDADDR"], 2)
        bin_value = ram_dict[value]
        return bin(bin_instr | bin_value)[2:]
        
    return False

def main(csv_path, input_path, output_path, ram_path):
    # if len(sys.argv) < 4:
    #     print("Usage: python assembler.py <instruction_map.csv> <input.txt> <output.rom>")
    #     return
    
    # csv_file = Path(sys.argv[1])
    # input_file = Path(sys.argv[2])
    # output_file = Path(sys.argv[3])

    csv_file = Path(csv_path)
    input_file = Path(input_path)
    output_file = Path(output_path)
    ram_file = Path(ram_path)

    global instruction_mapping
    instruction_mapping = load_instruction_map(csv_file)
    create_RAM_file(input_file, ram_file)
    read_variables(input_file)
    assemble(input_file, output_file)
    print(f"✨ Assembling complete. Behold thy ROM: {output_file}")

if __name__ == "__main__":
    
    csv_file_path = BASE_DIR / "instruction_map.csv"
    input_file_path = BASE_DIR / "input.txt"
    output_file_path = BASE_DIR / "output.rom"
    ram_file_path = BASE_DIR / "ram.ram"
    
    main(csv_file_path, input_file_path, output_file_path, ram_file_path)


# TODO
# -Create LD instrsuctuino
#   1. Create .ram file
#       Create dict with [value][address]
#       write to file
#   2. "Translate" LD to LDADDR #x in the code